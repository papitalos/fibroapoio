//
//  UserService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import Combine
import FirebaseFirestore

class UserService {
    private let firebaseService: FirebaseService
    private let localStorageService: LocalStorageService

    private var cancellables = Set<AnyCancellable>()

    init(
        firebaseService: FirebaseService,
        localStorageService: LocalStorageService
    ) {
        self.firebaseService = firebaseService
        self.localStorageService = localStorageService
    }
    
    /// Busca os dados do usuário, primeiro no LocalStorage e depois no Firestore.
    func fetchUser(userId: String? = nil) -> AnyPublisher<User?, Error> {
        // Se o userId não for fornecido, tenta carregar o usuário do LocalStorage
        if userId == nil {
            if let localUser = localStorageService.loadUser() {
                print(" MÉTODO: sem id no parâmetro")

                return Just(localUser)
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            else {
                print(" MÉTODO: sem id no parâmetro")
                let error = NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "\n ‼️ ERROR: Usuário não encontrado no localStorage e nenhum ID fornecido"])
                return Fail(error: error)
                    .eraseToAnyPublisher()
                }
        }
        
        // Se um userId foi fornecido, ou vamos usá-lo para buscar
        let userIdToUse = userId ?? localStorageService.loadUser()?.id
        
        guard let userIdToUse = userIdToUse else {
            // Não temos ID nem no parâmetro nem no localStorage
            let error = NSError(domain: "UserService", code: 404, userInfo: [NSLocalizedDescriptionKey: "\n ‼️ ERROR: Não foi possível determinar o ID do usuário"])
            return Fail(error: error)
                .eraseToAnyPublisher()
        }
        
        
        // Tenta carregar o usuário do LocalStorage
        if let localUser = localStorageService.loadUser(), localUser.id == userIdToUse {
            print("\n MÉTODO: com id no parâmetro")
            return Just(localUser)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        } else {
            // Se não encontrar no LocalStorage, busca todos os dados no Firestore
            return firebaseService.read(
                collection: "usuarios", documentId: userIdToUse
            )
            .handleEvents(receiveOutput: { user in
                if let user = user {
                    self.localStorageService.saveUser(user: user)
                }
            })
            .eraseToAnyPublisher()
        }
    }
        
    /// Cria um novo usuário no Firestore (com todos os dados) no LocalStorage.
    func createUser(user: User, documentID: String? = nil) -> AnyPublisher<Void, Error> {
        return firebaseService.create(
            collection: "usuarios", documentId: documentID, data: user
        )
        .handleEvents(receiveCompletion: { completion in
            if case .finished = completion {
                self.localStorageService.saveUser(user: user)
            }
        })
        .eraseToAnyPublisher()
    }

    /// Atualiza os dados do usuário no Firestore (com todos os dados)  no LocalStorage.
    func updateUser(user: User) -> AnyPublisher<Void, Error> {
        guard let userId = user.id, !userId.isEmpty else {
                return Fail(error: NSError(domain: "UserService", code: 0, userInfo: [NSLocalizedDescriptionKey: "‼️ ERROR: Usuário não possui ID"])).eraseToAnyPublisher()
        }
        
        return firebaseService.update(
            collection: "usuarios", documentId: user.id!, data: user
        )
        .handleEvents(receiveCompletion: { completion in
            if case .finished = completion {
                self.localStorageService.saveUser(user: user)
            }
        })
        .eraseToAnyPublisher()
    }

    /// Deleta um usuário do Firestore e remove do LocalStorage.
    func deleteUser(userId: String) -> AnyPublisher<Void, Error> {
        return firebaseService.delete(
            collection: "usuarios", documentId: userId
        )
        .handleEvents(receiveCompletion: { completion in
            if case .finished = completion {
                self.localStorageService.deleteUser()
            }
        })
        .eraseToAnyPublisher()
    }

    /// Remove o usuário do LocalStorage.
    func clearLocalStorage() {
        localStorageService.deleteUser()
    }

    /// Busca usuários por um campo específico (por exemplo, email).
    func findUsersByField(fieldName: String, fieldValue: Any) -> AnyPublisher<
        [User], Error
    > {
        return firebaseService.findByField(
            collection: "usuarios", fieldName: fieldName, fieldValue: fieldValue
        )
    }

    /// Atualiza um campo específico do usuário no Firestore.
    func updateUserField(userId: String, fieldName: String, fieldValue: Any)
        -> AnyPublisher<Void, Error>
    {
        return firebaseService.updateField(
            collection: "usuarios", documentId: userId, fieldName: fieldName,
            fieldValue: fieldValue)
    }
}

// MARK: - Extensions
extension FirebaseService {
    func readUser(collection: String, documentId: String) -> AnyPublisher<User?, Error> {
        read(collection: collection, documentId: documentId)
    }
}

extension String {
    var firstName: String {
        components(separatedBy: " ").first ?? self
    }
}
