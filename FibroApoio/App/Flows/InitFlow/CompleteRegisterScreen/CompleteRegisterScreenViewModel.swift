//
//  CompleteRegisterScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 09/04/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class CompleteRegisterScreenViewModel: ObservableObject {
    @Published var genero = ""
    @Published var dataNascimento = Date()
    @Published var peso = ""
    @Published var altura = ""
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()
    private var userService: UserService
    private var localStorageService: LocalStorageService

    init(
        userService: UserService = DependencyContainer.shared.container.resolve(UserService.self)!,
        localStorageService: LocalStorageService = DependencyContainer.shared.container.resolve(LocalStorageService.self)!
    ) {
        self.userService = userService
        self.localStorageService = localStorageService
    }

    func completeRegistration() {
        
    }
    
    private func validateFields() -> Bool {
        guard !genero.isEmpty, !peso.isEmpty, !altura.isEmpty else {
            errorMessage = "Por favor, preencha todos os campos."
            return false
        }
        return true
    }
}
