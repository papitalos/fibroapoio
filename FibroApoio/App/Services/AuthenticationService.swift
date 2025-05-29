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
    private let gamificationService: GamificationService

    private var cancellables = Set<AnyCancellable>()

    init(firebaseService: FirebaseService, userService: UserService, appCoordinatorService: AppCoordinatorService, localStorageService: LocalStorageService, gamificationService: GamificationService) {
        self.firebaseService = firebaseService
        self.appCoordinatorService = appCoordinatorService
        self.userService = userService
        self.localStorageService = localStorageService
        self.gamificationService = gamificationService
    }
    
    //MARK: - Registro
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
                    print("\n- REALIZANDO REGISTRO -\n RESULTADO: Bem sucedido ✅\n")
                    promise(.success(authResult))
                    if let authResult = authResult {
                        let userId = authResult.user.uid
                        let randomNick = self.userService.generateRandomNickname()
                        let initialRankRef = self.firebaseService.reference(to: "rank/qQerwqu5Pnj85oQIu2EU")

                        let user: User = User(
                            id: userId,
                            identification: identification,
                            id_rank: initialRankRef,
                            nome: nome,
                            nickname: randomNick,
                            pontuacao: 5000,
                            streak_atual: 0,
                            telemovel: telemovel,
                            email: email,
                            data_nascimento: nil,
                            altura_cm: 0,
                            peso_kg: 0,
                            genero: nil
                        )

                        // Cria o usuário no Firestore
                        self.userService.createUser(user: user, documentID: userId)
                            .flatMap { self.userService.loadUser() }
                            .sink(receiveCompletion: { _ in }, receiveValue: {
                                self.appCoordinatorService.goToPage(.completeRegister)
                            })
                            .store(in: &self.cancellables)

                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    

    /// Completa o perfil do usuário atualizando seus dados.
    func completeRegister(altura_cm: Int, peso_kg: Int, genero: String, data_nascimento: Date) -> AnyPublisher<Void, Error> {
        guard var user = userService.currentUser else {
            return Fail(error: NSError(
                domain: "AuthenticationService",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "‼️ ERROR: Usuário não carregado em memória"]
            )).eraseToAnyPublisher()
        }

        // Atualiza os dados do usuário com os novos valores
        user.altura_cm = altura_cm
        user.peso_kg = peso_kg
        user.genero = genero
        user.data_nascimento = Timestamp(date: data_nascimento)

        guard let userId = user.id else {
            return Fail(error: NSError(
                domain: "AuthenticationService",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "‼️ ERROR: ID do usuário não encontrado"]
            )).eraseToAnyPublisher()
        }

        // Cria o histórico de peso
        let historico_peso = HistoricoPeso(
            id: UUID().uuidString,
            data_registro: Timestamp(date: Date()),
            id_usuario: userId,
            peso_kg: Double(peso_kg)
        )

        // Salva histórico de peso e atualiza o usuário
        let pesoPublisher = firebaseService
            .create(collection: "historico_pesos", data: historico_peso)
            .map { _ in () }
            .eraseToAnyPublisher()

        return userService.persistCurrentUser(user)
            .flatMap { pesoPublisher }
            .eraseToAnyPublisher()
    }


    //MARK: - Login
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

                                self.userService.loadUser()
                                    .flatMap { _ in
                                        self.gamificationService.ensureEmptyStreakForToday()
                                    }
                                    .flatMap { _ in
                                        self.gamificationService.evaluateRankIfFirstLoginOfWeek()
                                            .catch { error -> AnyPublisher<GamificationService.RankChangeResult?, Never> in
                                                print("❌ Erro ao avaliar rank semanal: \(error.localizedDescription)")
                                                return Just(nil).eraseToAnyPublisher()
                                            }
                                    }
                                    .receive(on: DispatchQueue.main)
                                    .sink(receiveCompletion: { completion in
                                        // Aqui trata erro de ensureEmptyStreakForToday ou loadUser
                                        if case let .failure(error) = completion {
                                            print("🟥 Erro ao carregar usuário ou garantir streak: \(error)")
                                        }
                                        // Continua mesmo com falhas
                                        if user.altura_cm != 0 && user.peso_kg != 0 && user.genero != nil && user.data_nascimento != nil {
                                            self.appCoordinatorService.goToPage(.dashboard)
                                        } else {
                                            self.appCoordinatorService.goToPage(.completeRegister)
                                        }
                                        promise(.success(()))
                                    }, receiveValue: { result in
                                        switch result {
                                        case .promote:
                                            print("🚀 Promoção de rank após login semanal!")
                                        case .demote:
                                            print("📉 Rebaixamento de rank após login semanal!")
                                        case .none?, nil:
                                            print("🔁 Nenhuma mudança de rank após login.")
                                        }
                                    })
                                    .store(in: &self.cancellables)


                            }
                        }
                    )
                    .store(in: &self.cancellables)
            }
        }.eraseToAnyPublisher()
    }

    //MARK: - Logout
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
    
    //MARK: - Helpers
    /// Verifica se existe um usuário logado via FirebaseAuth
    func isUserLoggedIn() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
