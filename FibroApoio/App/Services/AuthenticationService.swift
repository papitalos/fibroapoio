//
//  AuthenticationService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import FirebaseAuth
import FirebaseFirestore
import Combine

class AuthenticationService {
    private let firebaseService: FirebaseService
    private let userService: UserService
    private let appCoordinatorService: AppCoordinatorService

    init(firebaseService: FirebaseService, userService: UserService, appCoordinatorService: AppCoordinatorService) {
        self.firebaseService = firebaseService
        self.appCoordinatorService = appCoordinatorService
        self.userService = userService
    }

    // MARK: - Properties
    private var cancellables = Set<AnyCancellable>() // Importante: DEVE estar aqui

    /// Registra um novo usuário com email e senha.
    func register(email: String, password: String,
                  nome: String,
                  telemovel: String,
                  identification: String) -> AnyPublisher<AuthDataResult?, Error> {
        return Future<AuthDataResult?, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    print("Registro realizado com sucesso!")
                    promise(.success(authResult))
                    if let authResult = authResult {
                        let userId = authResult.user.uid
                        print("User ID: \(userId)")
                        let user = Usuario(
                            identification: identification,
                            id_rank: nil,
                            nome: nome,
                            nickname: "teste",
                            pontuacao: 0,
                            streak_atual: 0,
                            telemovel: telemovel,
                            email: email,
                            data_nascimento: nil,
                            altura_cm: 0,
                            genero: nil
                        )

                        // Cria o usuário no Firestore
                        self.userService.createUser(user: user, documentID: userId)
                            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
                            .store(in: &self.cancellables)
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    /// Verifica se o perfil do usuário está completo (altura, gênero, data de nascimento preenchidos).
    func verifyProfileCompletion(userId: String) -> AnyPublisher<Bool, Error> {
        print("Verificando se o perfil do usuário está completo...")
        return userService.fetchUser(userId: userId)
            .map { user in
                guard let user = user else { return false }
                return user.altura_cm != 0 && user.genero != nil && user.data_nascimento != nil
            }
            .eraseToAnyPublisher()
    }

    /// Completa o registro do usuário atualizando seus dados.
    func completeRegister(userId: String, altura_cm: Int, genero: String, data_nascimento: Date, documentID: String) -> AnyPublisher<Void, Error> {
        return userService.fetchUser(userId: userId)
            .flatMap { user -> AnyPublisher<Void, Error> in
                guard var user = user else {
                    return Fail(error: NSError(domain: "AuthenticationService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado"])).eraseToAnyPublisher()
                }
                
                // Atualiza os dados do usuário com os novos valores
                user.altura_cm = altura_cm
                user.genero = genero
                user.data_nascimento = Timestamp(date: data_nascimento)
                
                // Atualiza o usuário no Firestore
                return self.userService.updateUser(user: user, documentID: documentID)
            }
            .eraseToAnyPublisher()
    }

    /// Faz login com email e senha.
    func login(email: String, password: String) -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthenticationService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else if let authResult = authResult {
                    print("Login realizado com sucesso!")
                    self.verifyProfileCompletion(userId: authResult.user.uid)
                        .sink(receiveCompletion: { completion in
                            switch completion {
                            case .finished:
                                break
                            case .failure(let error):
                                print("Erro ao verificar o perfil: \(String(describing: error))")
                                promise(.failure(error))
                                return
                            }
                        }, receiveValue: { isComplete in
                            if isComplete {
                                print("Perfil completo")
                                self.appCoordinatorService.goToPage(.dashboard)
                            } else {
                                print("Perfil incompleto")
                                self.appCoordinatorService.goToPage(.completeRegister)
                            }
                            promise(.success(()))
                        })
                        .store(in: &self.cancellables)
                } else {
                    let error = NSError(domain: "AuthenticationService", code: 0, userInfo: [NSLocalizedDescriptionKey: "AuthResult is nil"])
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }


    /// Faz logout do usuário atual.
    func logout() -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
                // Limpa o LocalStorage ao fazer logout
                self.userService.clearLocalStorage()
                print("Logout realizado com sucesso!")
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
