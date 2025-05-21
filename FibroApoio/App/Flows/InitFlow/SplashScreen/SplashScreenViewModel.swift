import SwiftUI
import Combine
import FirebaseAuth

class SplashScreenViewModel: ObservableObject {
    @Published var isLoading: Bool = true

    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService
    @Service var userService: UserService
    @Service var gamificationService: GamificationService
    @Service var localStorageService: LocalStorageService

    private var cancellables = Set<AnyCancellable>()

    //MARK: - Load
    init() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.checkUserState()
        }
    }

    private func checkUserState() {
        if authenticationService.isUserLoggedIn() {
            loadUserAndContinue()
        } else {
            goToInitialPage()
        }
    }

    private func goToInitialPage() {
        isLoading = false
        if localStorageService.hasSeenWelcomeScreen() {
            appCoordinator.goToPage(.register)
        } else {
            appCoordinator.goToPage(.welcome)
        }
    }

    private func loadUserAndContinue() {
        userService.loadUser()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false
                if case .failure(let error) = completion {
                    print("‼️ Falha ao carregar usuário: \(error.localizedDescription)")
                    self.goToInitialPage()
                }
            }, receiveValue: {
                self.postLoadActions()
            })
            .store(in: &cancellables)
    }

    
    //MARK: - Post Load
    private func postLoadActions() {
        // garante streak vazio do dia
        gamificationService.ensureEmptyStreakForToday()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                self.isLoading = false

                if case let .failure(error) = completion {
                    print("🟥 Erro ao garantir streak vazio: \(error)")
                }

                self.appCoordinator.goToPage(.dashboard)
            }, receiveValue: {
                print("✅ Empty streak verificado ou criado")
            })
            .store(in: &cancellables)

    }
}
