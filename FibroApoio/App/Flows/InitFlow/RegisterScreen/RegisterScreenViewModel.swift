//
//  RegisterScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/03/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class RegisterScreenViewModel: ObservableObject {
    // MARK: - Enviroment Objects
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService

    // MARK: - Properties
    @Published var name = ""
    @Published var identification = ""
    @Published var number = ""
    @Published var email = ""
    @Published var senha = ""
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // MARK: - Methods
    func registerUser() {
        guard validateFields() else { return }

        authenticationService.register(
            email: email,
            password: senha,
            nome: name,
            telemovel: number,
            identification: identification
        ).sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    print("Registro concluído com sucesso")
                    self.clearFields()
                    self.appCoordinator.goToPage(.completeRegister)
                case .failure(_):
                    self.errorMessage =
                        "Erro ao registrar"
                    print("Erro ao registrar: \(String(describing: completion))")
                }
            },
            receiveValue: { authResult in
                print("Auth Result: \(String(describing: authResult))")
                // Aqui você pode tratar o resultado da autenticação, se necessário.
            }
        )
        .store(in: &cancellables)
    }

    private func validateFields() -> Bool {
        guard !name.isEmpty, !identification.isEmpty, !number.isEmpty, !email.isEmpty,
            !senha.isEmpty
        else {
            errorMessage = "Por favor, preencha todos os campos."
            return false
        }
        return true
    }

    private func clearFields() {
        name = ""
        identification = ""
        number = ""
        email = ""
        senha = ""
        errorMessage = nil
    }
}
