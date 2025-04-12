// UserService.swift
import Combine
import FirebaseFirestore

class UserService {
    static let shared = UserService() // Singleton para acesso global

    private let firebaseService = FirebaseService.shared // Injeta o FirebaseService

    private init() {}

    /// Busca os dados do usuário do Firestore.
    func fetchUser(userId: String) -> AnyPublisher<Usuario?, Error> {
        return firebaseService.read(collection: "usuarios", documentId: userId)
    }

    /// Cria um novo usuário no Firestore.
    func createUser(user: Usuario) -> AnyPublisher<Void, Error> {
        return firebaseService.create(collection: "usuarios", documentId: user.id, data: user)
    }

    /// Atualiza os dados do usuário no Firestore.
    func updateUser(user: Usuario) -> AnyPublisher<Void, Error> {
        return firebaseService.update(collection: "usuarios", documentId: user.id, data: user)
    }

    /// Deleta um usuário do Firestore.
    func deleteUser(userId: String) -> AnyPublisher<Void, Error> {
        return firebaseService.delete(collection: "usuarios", documentId: userId)
    }

    /// Busca usuários por um campo específico (por exemplo, email).
    func findUsersByField(fieldName: String, fieldValue: Any) -> AnyPublisher<[Usuario], Error> {
        return firebaseService.findByField(collection: "usuarios", fieldName: fieldName, fieldValue: fieldValue)
    }

    /// Atualiza um campo específico do usuário no Firestore.
    func updateUserField(userId: String, fieldName: String, fieldValue: Any) -> AnyPublisher<Void, Error> {
        return firebaseService.updateField(collection: "usuarios", documentId: userId, fieldName: fieldName, fieldValue: fieldValue)
    }
}