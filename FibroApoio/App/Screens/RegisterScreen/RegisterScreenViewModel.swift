//
//  RegisterScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/03/2025.
//

import SwiftUI
import Firebase
import FirebaseFirestore
import FirebaseAuth

class RegisterScreenViewModel: ObservableObject {
    @ObservedObject var appCoordinator: AppCoordinator
    
    @Published var name = ""
    @Published var id = ""
    @Published var number = ""
    @Published var email = ""
    @Published var senha = ""
    @Published var errorMessage: String?
    
    init(appCoordinator: AppCoordinator) {
        self.appCoordinator = appCoordinator
    }

    func registerUser() {
        // Verificar se os campos estão preenchidos
        guard !name.isEmpty, !id.isEmpty, !number.isEmpty, !email.isEmpty, !senha.isEmpty else {
            self.errorMessage = "Por favor, preencha todos os campos."
            return
        }

        // Verificar se o email já existe
        checkIfUserExists { [weak self] exists in
            guard let self = self else { return }
            if exists {
                self.errorMessage = "Este email já está cadastrado."
            } else {
                // Registrar o usuário no Firebase Authentication
                Auth.auth().createUser(withEmail: self.email, password: self.senha) { authResult, error in
                    if error != nil {
                        self.errorMessage = "Erro ao criar usuário: \(String(describing: error))"
                    } else {
                        // Salvar informações adicionais no Firestore
                        self.saveUserToFirestore(userId: authResult?.user.uid ?? "")
                    }
                }
            }
        }
    }

    private func checkIfUserExists(completion: @escaping (Bool) -> Void) {
        let db = Firestore.firestore()
        db.collection("usuarios")
            .whereField("email", isEqualTo: email)
            .getDocuments { (querySnapshot, error) in
                if error != nil {
                    print("Erro ao verificar email:\(String(describing: error))")
                    completion(false)
                } else {
                    completion((querySnapshot?.documents.count ?? 0) > 0)
                }
            }
    }

    private func saveUserToFirestore(userId: String) {
        let db = Firestore.firestore()
        let userData: [String: Any] = [
            "uid": userId,
            "nome": name,
            "id": id,
            "telemovel": number,
            "email": email
        ]

        db.collection("usuarios").document(userId).setData(userData) { error in
            if error != nil {
                self.errorMessage = "Erro ao salvar dados do usuário: \(String(describing: error))"
            } else {
                self.clearFields()
                self.appCoordinator.goToPage("dashboard")
            }
        }
    }

    private func clearFields() {
        name = ""
        id = ""
        number = ""
        email = ""
        senha = ""
        errorMessage = nil
    }
}
