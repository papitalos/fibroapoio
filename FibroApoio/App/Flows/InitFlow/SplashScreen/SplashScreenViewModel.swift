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
    @Service var localStorageService: LocalStorageService
    @Service var userService: UserService

    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private var cancellables: Set<AnyCancellable> = []

    init() { checkCurrentUser() }

    func checkCurrentUser() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if user != nil {
                    Task {
                        await self.fetchUserData()
                    }
                } else {
                    self.isLoading = false
                    if(self.localStorageService.hasSeenWelcomeScreen()) {
                        self.appCoordinator.goToPage(.register)
                    }else{
                        self.appCoordinator.goToPage(.welcome)
                    }
                }
            }
        }
    }
    
    @MainActor
        func fetchUserData() async {
            do {
                _ = try await withCheckedThrowingContinuation {  (continuation: CheckedContinuation<User?, Error>)  in
                    userService.fetchUser()
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
                                print("2 \(String(describing: user))")

                                self.appCoordinator.loadUser(user: user)

                                continuation.resume(returning: user)
                            }
                        )
                        .store(in: &cancellables)
                }

                isLoading = false
                appCoordinator.goToPage(.dashboard)
            } catch {
                isLoading = false
                if(localStorageService.hasSeenWelcomeScreen()) {
                    appCoordinator.goToPage(.register)
                }else{
                    appCoordinator.goToPage(.welcome)
                }
            }
        }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}
