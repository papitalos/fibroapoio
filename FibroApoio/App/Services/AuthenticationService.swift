// AuthenticationService.swift
import FirebaseAuth
import Combine

class AuthenticationService {
    private let firebaseService = FirebaseService.shared // Injeta o FirebaseService

    /// Registra um novo usuário com email e senha.
    func register(email: String, password: String) -> AnyPublisher<AuthDataResult?, Error> {
        return Future<AuthDataResult?, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(authResult))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Faz login com email e senha.
    func login(email: String, password: String) -> AnyPublisher<AuthDataResult?, Error> {
        return Future<AuthDataResult?, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { (authResult, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(authResult))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Faz logout do usuário atual.
    func logout() -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    /// Envia email de redefinição de senha.
    func resetPassword(email: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            Auth.auth().sendPasswordReset(withEmail: email) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}