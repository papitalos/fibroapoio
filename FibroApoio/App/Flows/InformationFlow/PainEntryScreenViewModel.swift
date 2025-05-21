import Foundation
import Combine
import FirebaseFirestore

class PainEntryScreenViewModel: ObservableObject {
    @Published var entries: [PainEntry] = []

    @Service var firebaseService: FirebaseService
    @Service var appCoordinator: AppCoordinatorService

    private var cancellables = Set<AnyCancellable>()

    func addEntry(_ entry: PainEntry) {
        if !entries.contains(where: { $0.zone == entry.zone }) {
            entries.append(entry)
        }
    }

    func savePainEntries() {
        guard let userId = appCoordinator.user?.id else { return }

        let dores = entries.map {
            Dor(
                id: nil,
                has_pain: true,
                id_usuario: userId,
                local_dor: $0.zone.rawValue,
                nivel_dor: $0.level,
                createdAt: nil,
                updatedAt: nil,
                deletedAt: nil
            )
        }

        guard !dores.isEmpty else { return }

        let publishers = dores.map { dor in
            firebaseService.create(collection: "dores", data: dor)
        }

        Publishers.MergeMany(publishers)
            .collect()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.appCoordinator.goToPage(.dashboard)
                case .failure(let error):
                    print("Erro ao salvar dores: \(error.localizedDescription)")
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }
}
