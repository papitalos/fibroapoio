import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class ExerciseEntryScreenViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var exerciseName: String = ""
    @Published var exerciseType: String = "Aerobico"
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var notes: String = ""

    // MARK: - UI Control
    @Published var showStartTimePicker: Bool = false
    @Published var showEndTimePicker: Bool = false
    @Published var showPoints: Bool = false
    let points = [200, 300, 400]
    @Published var selectedPoints: Int = 0

    // MARK: - Services
    @Service var appCoordinator: AppCoordinatorService
    @Service var firebaseService: FirebaseService
    @Service var localStorageService: LocalStorageService

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Métodos Públicos
    func openDialog() {
        self.selectedPoints = self.points.randomElement()!
        self.showPoints = true
    }

    func saveExercise() {
        guard let userId = localStorageService.loadUser()?.id else {
            print("‼️ Usuário não encontrado")
            return
        }

        let duration = Int(endTime.timeIntervalSince(startTime) / 60)

        let exercicio = Exercicio(
            id: nil,
            duracao_inicio: Timestamp(date: startTime),
            duracao_fim: Timestamp(date: endTime),
            duracao_minutos: duration,
            id_usuario: userId,
            observacoes: notes.trimmingCharacters(in: .whitespacesAndNewlines),
            tipo_exercicio: exerciseType,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil
        )

        firebaseService.create(collection: "exercicios", data: exercicio)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("❌ Erro ao salvar exercício: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] in
                print("✅ Exercício salvo com sucesso.")
                self?.appCoordinator.goToPage(.dashboard)
            })
            .store(in: &cancellables)
    }
}
