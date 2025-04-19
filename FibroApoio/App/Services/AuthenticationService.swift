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
    private let localStorageService: LocalStorageService

    init(firebaseService: FirebaseService, userService: UserService, appCoordinatorService: AppCoordinatorService, localStorageService: LocalStorageService) {
        self.firebaseService = firebaseService
        self.appCoordinatorService = appCoordinatorService
        self.userService = userService
        self.localStorageService = localStorageService
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

                        let user: User = User(
                            id: userId,
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
    

    /// Completa o perfil do usuário atualizando seus dados.
    func completeRegister(altura_cm: Int, genero: String, data_nascimento: Date) -> AnyPublisher<Void, Error> {
        return userService.fetchUser()
            .flatMap { user -> AnyPublisher<Void, Error> in
                guard var user = user else {
                    return Fail(error: NSError(domain: "AuthenticationService", code: 0, userInfo: [NSLocalizedDescriptionKey: "‼️ ERROR: Usuário não encontrado no localStorage"])).eraseToAnyPublisher()
                }
                
                // Atualiza os dados do usuário com os novos valores
                user.altura_cm = altura_cm
                user.genero = genero
                user.data_nascimento = Timestamp(date: data_nascimento)
                
                // Atualiza o usuário no Firestore
                return self.userService.updateUser(user: user)
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
            self.resetAuthState()
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    print("Erro de autenticação: \(error.localizedDescription)")
                    promise(.failure(error))
                    return
                }
                
                guard let authResult = authResult else {
                    let error = NSError(domain: "AuthenticationService", code: 0, userInfo: [NSLocalizedDescriptionKey: "AuthResult is nil"])
                    promise(.failure(error))
                    return
                }
                
                let userId = authResult.user.uid
                print("\n- REALIZANDO LOGIN -\n RESULTADO: Bem Sucedido ✅\n ID: \(userId)")
                
                // Verificar se o usuário existe no Firestore
                self.firebaseService.read(collection: "usuarios", documentId: userId)
                    .sink(
                        receiveCompletion: { completion in
                            if case .failure(let error) = completion {
                                print("‼️ ERROR: Falha ao buscar usuário: \(error.localizedDescription)")
                                promise(.failure(error))
                            }
                        },
                        receiveValue: { (user: User?) in
                            if let user = user {
                                // Usuário existe no Firestore
                                print(" RESULTADO: Dados do usuário encontrados no Firestore ✅")
                                self.localStorageService.saveUser(user: user)
                                print("1 \(user)")
                                self.appCoordinatorService.loadUser(user: user)
                                // Verificar se o perfil está completo
                                if user.altura_cm != 0 && user.genero != nil && user.data_nascimento != nil {
                                    print("\n✅ Perfil completo")
                                    self.appCoordinatorService.goToPage(.dashboard)
                                } else {
                                    print("\n⚠️ Perfil incompleto")
                                    self.appCoordinatorService.goToPage(.completeRegister)
                                }
                                promise(.success(()))
                            }
                        }
                    )
                    .store(in: &self.cancellables)
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
                print("\n- ⬅ LOGOUT SUCCESSFUL! -")
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
    
    func resetAuthState() {
        do {
            try Auth.auth().signOut()
            self.userService.clearLocalStorage()
        } catch {
            print("‼️ ERROR: Problema ao resetar estado de autenticação:$$error)")
        }
    }
}
