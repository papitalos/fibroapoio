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

    init(
        firebaseService: FirebaseService,
        localStorageService: LocalStorageService
    ) {
        self.firebaseService = firebaseService
        self.localStorageService = localStorageService
    }

    /// Busca os dados do usuário, primeiro no LocalStorage e depois no Firestore.
    func fetchUser(userId: String) -> AnyPublisher<Usuario?, Error> {
        print("Buscando usuário \(userId)")
        // Tenta carregar o usuário do LocalStorage
        if let localUser = localStorageService.loadUser() {
            return Just(localUser)
                .setFailureType(to: Error.self) 
                .eraseToAnyPublisher()
        } else {
            // Se não encontrar no LocalStorage, busca todos os dados no Firestore
            return firebaseService.read(
                collection: "usuarios", documentId: userId
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
    func createUser(user: Usuario, documentID: String? = nil) -> AnyPublisher<Void, Error> {
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
    func updateUser(user: Usuario, documentID: String) -> AnyPublisher<Void, Error> {
        return firebaseService.update(
            collection: "usuarios", documentId: documentID, data: user
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
        [Usuario], Error
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

extension FirebaseService {
    func readUser(collection: String, documentId: String) -> AnyPublisher<Usuario?, Error> {
        read(collection: collection, documentId: documentId)
    }
}
