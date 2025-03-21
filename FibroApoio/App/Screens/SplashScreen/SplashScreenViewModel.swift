//
//  SplashScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 21/03/2025.
//

import SwiftUI
import FirebaseAuth

class SplashScreenViewModel: ObservableObject {
    @ObservedObject var appCoordinator: AppCoordinator
    @Published var isLoading: Bool = true
    private var authStateHandle: AuthStateDidChangeListenerHandle?

    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
        checkCurrentUser()
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    func checkCurrentUser() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            // Simula um pequeno delay para exibir a SplashScreen por um tempo mínimo
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if user != nil {
                    self.appCoordinator.goToPage("dashboard")
                } else {
                    self.appCoordinator.goToPage("welcome")
                }
                self.isLoading = false // Finaliza o "loading"
            }
        }
    }
}
