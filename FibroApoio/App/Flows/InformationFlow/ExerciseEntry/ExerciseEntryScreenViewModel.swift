//
//  ExerciseEntryScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import Combine
import FirebaseFirestore
import Foundation
import SwiftUI

class ExerciseEntryScreenViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var exerciseName: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var notes: String = ""

    // MARK: - UI Control
    @Published var showStartTimePicker: Bool = false
    @Published var showEndTimePicker: Bool = false
    @Published var showPoints: Bool = false
    @Published var selectedPoints: Int = 0
    @Published var errorMessage: String? = nil
    let points = [300, 400, 500]

    // MARK: - Services
    @Service var appCoordinator: AppCoordinatorService
    @Service var userService: UserService

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Métodos Públicos
    func openDialog() {
        guard
            !exerciseName.trimmingCharacters(in: .whitespacesAndNewlines)
                .isEmpty
        else {
            errorMessage = "Por favor, preencha o nome do exercício."
            return
        }

        guard endTime > startTime else {
            errorMessage = "A hora de fim deve ser depois da hora de início."
            return
        }

        self.errorMessage = nil
        self.selectedPoints = self.points.randomElement()!
        self.showPoints = true
    }

    func saveExercise() {
        guard let userId = userService.currentUser?.id else {
            print("‼️ Usuário não encontrado")
            return
        }

        let duration = Int(endTime.timeIntervalSince(startTime) / 60)

        guard duration >= 10 else {
            self.errorMessage = "O exercício deve ter pelo menos 10 minutos."
            self.showPoints = false
            return
        }
        
        let exercicio = Exercicio(
            id: nil,
            id_usuario: userId,
            tipo: exerciseName,
            duracao_inicio: Timestamp(date: startTime),
            duracao_fim: Timestamp(date: endTime),
            duracao_minutos: duration,
            observacoes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil
        )

        userService.persistWeeklyData { weekly in
            weekly.exercicios.append(exercicio)
        }
        .receive(on: DispatchQueue.main)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print(
                        "❌ Erro ao salvar exercício: \(error.localizedDescription)"
                    )
                case .finished:
                    print("✅ Exercício salvo com sucesso.")
                    self.appCoordinator.goToPage(.dashboard)
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)
    }

}
