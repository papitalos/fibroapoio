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
        @Service var userService: UserService
        @Service var gamificationService: GamificationService

        let points = [500, 600, 700]
        
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
            guard let userId = userService.currentUser?.id else { return }

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

            userService.findDocumentsByDate(
                collection: "checkin",
                from: today,
                to: nil
            )
            .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
                if checkins.contains(where: { $0.status_streak == -1 }) {
                    print("✅ Checkin vazio encontrado, completando streak...")
                    return self.gamificationService.addStreakCompletion()
                        .flatMap { _ in self.gamificationService.incrementStreakAtualForCurrentUser() }
                        .eraseToAnyPublisher()
                } else {
                    print("⚠️ Check-in já feito hoje, não registrando streak.")
                    return Just(())
                        .setFailureType(to: Error.self)
                        .eraseToAnyPublisher()
                }
            }
            .flatMap { _ -> AnyPublisher<Void, Error> in
                self.userService.persistWeeklyData { weekly in
                    let novos = dores.filter { nova in
                        !weekly.dores.contains(where: { $0.local_dor == nova.local_dor && $0.nivel_dor == nova.nivel_dor })
                    }
                    weekly.dores.append(contentsOf: novos)
                }

            }
            .flatMap {
                self.gamificationService.addPointsToCurrentUser(self.selectedPoints)
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("‼️ Erro ao processar entradas: \(error.localizedDescription)")
                case .finished:
                    self.entries = []
                    self.appCoordinator.goToPage(.dashboard)
                    print("✅ Entradas de dor, streak e pontuação processados com sucesso")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
        }
    }
