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

// Enum para o gênero
enum Genero: String, Hashable {
    case masculino = "Masculino"
    case feminino = "Feminino"
}

class CompleteRegisterScreenViewModel: ObservableObject {
    // MARK: - Enviroment Objects
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService
    
    // Propriedade para o AtomDropdownButton
    @Published var generoSelecionado: Genero?
    
    @Published var genero = ""
    @Published var dataNascimento: Date? = nil
    @Published var peso = ""
    @Published var altura = ""
    @Published var errorMessage: String?
    private var cancellables = Set<AnyCancellable>()


    func completeRegistration() {
        // Garantir que o gênero está atualizado com base na seleção
        if let generoSelecionado = generoSelecionado {
            genero = generoSelecionado.rawValue
        }
        
        // Garantir que a data de nascimento não está vazia
        if dataNascimento == nil {
            errorMessage = "Por favor, informe sua data de nascimento."
            return
        }
        
        guard validateFields() else { return }
        
        authenticationService.completeRegister(altura_cm: Int(altura)!, genero: genero, data_nascimento: dataNascimento!)
        .sink(
            receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.appCoordinator.goToPage(.successRegistration)
                    break
                case .failure(let error):
                    print("\n ‼️ ERROR: Falha ao completar registro: \(error.localizedDescription)")
                }
            },
            receiveValue: { _ in }
        )
        .store(in: &cancellables)
    }
    
    private func validateFields() -> Bool {
        guard !genero.isEmpty, !peso.isEmpty, !altura.isEmpty, dataNascimento != nil else {
            errorMessage = "Por favor, preencha todos os campos."
            return false
        }
        return true
    }
}
