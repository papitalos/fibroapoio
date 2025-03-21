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
    @Published var isLoading: Bool = true // Indica se a verificação está em andamento

    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
        checkCurrentUser()
    }

    func checkCurrentUser() {
        Auth.auth().addStateDidChangeListener { [weak self] auth, user in
            guard let self = self else { return }
            
            // Simula um pequeno delay para exibir a SplashScreen por um tempo mínimo
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                if user != nil {
                    // Usuário está logado, navega para o dashboard
                    self.appCoordinator.goToPage("dashboard")
                } else {
                    // Usuário não está logado, navega para a tela de login
                    self.appCoordinator.goToPage("welcome")
                }
                self.isLoading = false // Finaliza o "loading"
            }
        }
    }
}