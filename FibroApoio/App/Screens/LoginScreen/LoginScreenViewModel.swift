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

class LoginScreenViewModel: ObservableObject {
    @ObservedObject var appCoordinator: AppCoordinator

    @Published var id = ""
    @Published var email = ""
    @Published var senha = ""
    @Published var errorMessage: String?
    
     init(appCoordinator: AppCoordinator) {
         self.appCoordinator = appCoordinator
     }
    
    func loginUser(by: String) {
        if by.contains("email") {
            guard !email.isEmpty && !senha.isEmpty else {
                self.errorMessage = "Por favor, preencha o email e a senha."
                return
            }
        } else if by.contains("id") {
            guard !id.isEmpty && !senha.isEmpty else {
                self.errorMessage = "Por favor, preencha o ID e a senha."
                return
            }
        } else {
            self.errorMessage = "Modo de login inválido."
            return
        }

        // Continuar com a verificação e o login
        checkIfUserExists(by: by) { [weak self] exists in
            guard let self = self else { return }
            if exists {
                self.loginFirebaseUser()
            } else {
                self.errorMessage = "Este usuário não está cadastrado."
            }
        }
    }
    
    private func checkIfUserExists(by: String, completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        var query: Query

        if by.contains("email") {
            query = db.collection("usuarios").whereField("email", isEqualTo: email.lowercased())
        } else {
            query = db.collection("usuarios").whereField("userID", isEqualTo: id)
        }

        query.getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }

            if error != nil {
                self.errorMessage = "Erro ao verificar usuário: \(String(describing: error))"
                completion(false)
                return
            }

            let userExists = !(querySnapshot?.documents.isEmpty ?? true)
            completion(userExists)
        }
    }

    private func loginFirebaseUser() {
        Auth.auth().signIn(withEmail: email, password: senha) { [weak self] authResult, error in
            guard let self = self else { return }

            if error != nil {
                self.errorMessage = "Erro ao fazer login: \(String(describing: error))"
                print("Erro ao fazer login: \(String(describing: error))")
                return
            }

            // Se o login for bem-sucedido, você pode realizar ações adicionais aqui,
            // como navegar para a tela principal do aplicativo ou salvar informações do usuário.
            print("Usuário logado com sucesso!")
            clearFields()
            appCoordinator.goToPage("dashboard")
        }
    }

    private func clearFields() {
        id = ""
        email = ""
        senha = ""
        errorMessage = nil
    }
}
