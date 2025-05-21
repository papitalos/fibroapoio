//
//  PainEntryScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 02/05/2025.
//

import SwiftUI
import Foundation
import Combine
import FirebaseFirestore

class PainEntryScreenViewModel: ObservableObject {
    @Published var entries: [PainEntry] = []
    @Published var selectedPoints = 0
    @Published var showPoints = false

    @Service var firebaseService: FirebaseService
    @Service var appCoordinator: AppCoordinatorService
    @Service var rankService: RankService

    let points = [500,600,700]
    
    private var cancellables = Set<AnyCancellable>()

    func addEntry(_ entry: PainEntry) {
        if !entries.contains(where: { $0.zone == entry.zone }) {
            entries.append(entry)
        }
    }
    
    func openDialog() {
        self.selectedPoints = self.points.randomElement()!
        self.showPoints = true
    }

    func savePainEntries() {
        guard let userId = appCoordinator.user?.id else { return }
        
        let dores = entries.map {
            Dor(
                id: nil,
                has_pain: true,
                id_usuario: userId,
                local_dor: $0.zone.displayName(for: $0.side),
                nivel_dor: $0.level,
                createdAt: nil,
                updatedAt: nil,
                deletedAt: nil
            )
        }
        
        let today = Calendar.current.startOfDay(for: Date())
        
        // Verifica se o usuário já fez check-in hoje
        self.firebaseService.findMyDocumentsByDate(
            collection: "checkin",
            fieldName: "createdAt",
            from: today,
            to: nil
        )
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            if checkins.isEmpty {
                print("✅ Nenhum check-in encontrado hoje, registrando streak...")
                return self.rankService.addStreakCompletion()
            } else {
                print("⚠️ Check-in já feito hoje, não registrando streak.")
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        .flatMap { _ -> AnyPublisher<Void, Error> in
            if dores.isEmpty {
                return self.rankService.addPointsToCurrentUser(self.selectedPoints)
            } else {
                let publishers = dores.map { dor in
                    self.firebaseService.create(collection: "dores", data: dor)
                }

                return Publishers.MergeMany(publishers)
                    .collect()
                    .flatMap { _ in
                        self.rankService.addPointsToCurrentUser(self.selectedPoints)
                    }
                    .eraseToAnyPublisher()
            }
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("‼️ Erro ao salvar entrada de dor ou registrar streak: \(error.localizedDescription)")
            case .finished:
                self.appCoordinator.goToPage(.dashboard)
                print("✅ Entradas de dor e streak processados com sucesso")
            }
        }, receiveValue: { _ in })
        .store(in: &cancellables)
    }

}
