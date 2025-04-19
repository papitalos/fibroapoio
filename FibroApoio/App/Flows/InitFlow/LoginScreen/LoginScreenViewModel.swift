//
//  LoginScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class LoginScreenViewModel: ObservableObject {
    // MARK: - Enviroment Objects
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService

    // MARK: - Properties
    @Published var id = ""
    @Published var email = ""
    @Published var senha = ""
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Methods
    func loginUser(by loginMethod: String) {
        if loginMethod.contains("email") {
            guard !email.isEmpty && !senha.isEmpty else {
                self.errorMessage = "Por favor, preencha o email e a senha."
                return
            }

            authenticationService.login(email: email, password: senha)
                .sink(receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        self.clearFields()
                    case .failure(_):
                        self.errorMessage = "Erro ao fazer login"
                        print("\n‼️ ERROR: \(String(describing: completion))")
                    }
                }, receiveValue: { _ in })
                .store(in: &cancellables)
        } else {
            self.errorMessage = "Modo de login inválido."
        }
    }

    private func clearFields() {
        id = ""
        email = ""
        senha = ""
        errorMessage = nil
    }
}
