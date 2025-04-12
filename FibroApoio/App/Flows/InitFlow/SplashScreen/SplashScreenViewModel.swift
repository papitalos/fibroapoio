//
//  SplashScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 21/03/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class SplashScreenViewModel: ObservableObject {
    @Published var isLoading: Bool = true

    @Service var appCoordinator: AppCoordinatorService
    @Service var userService: UserService
    @Service var authenticationService: AuthenticationService

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var cancellables: Set<AnyCancellable> = []

    init() {
        print("WelcomeScreenViewModel AppCoordinator ID: \(ObjectIdentifier(appCoordinator))")
        checkCurrentUser()
    }

    func checkCurrentUser() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if let user = user {
                    Task {
                        await self.fetchUserData(userId: user.uid)
                    }
                } else {
                    self.isLoading = false
                    self.appCoordinator.goToPage(.welcome)
                }
            }
        }
    }
    
    @MainActor
        func fetchUserData(userId: String) async {
            do {
                let userData = try await withCheckedThrowingContinuation { continuation in
                    userService.fetchUser(userId: userId)
                        .sink(
                            receiveCompletion: { completion in
                                switch completion {
                                case .finished:
                                    break
                                case .failure(let error):
                                    continuation.resume(throwing: error)
                                }
                            },
                            receiveValue: { user in
                                continuation.resume(returning: user)
                            }
                        )
                        .store(in: &cancellables)
                }

                appCoordinator.currentUser = userData
                isLoading = false
                appCoordinator.goToPage(.dashboard)
            } catch {
                print("Erro ao buscar dados do usuário: $$error)")
                isLoading = false
                appCoordinator.goToPage(.welcome)
            }
        }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
