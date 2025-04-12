// FirebaseService.swift
import FirebaseFirestore
import FirebaseFirestoreSwift
import Combine

class FirebaseService {
    static let shared = FirebaseService() // Singleton para acesso global

    private let db = Firestore.firestore()

    private init() {}

    // MARK: - Funções de CRUD Básicas

    /// Cria um novo documento na coleção especificada.
    func create<T: Encodable>(collection: String, documentId: String? = nil, data: T) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                var ref: DocumentReference
                if let documentId = documentId {
                    ref = self.db.collection(collection).document(documentId)
                    try ref.setData(from: data)
                } else {
                    ref = self.db.collection(collection).document()
                    try ref.setData(from: data)
                }
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    /// Busca um documento específico na coleção.
    func read<T: Decodable>(collection: String, documentId: String) -> AnyPublisher<T?, Error> {
        return Future<T?, Error> { promise in
            self.db.collection(collection).document(documentId).getDocument { (document, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let document = document, document.exists else {
                    promise(.success(nil))
                    return
                }

                do {
                    let item = try document.data(as: T.self)
                    promise(.success(item))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Atualiza um documento existente na coleção.
    func update<T: Encodable>(collection: String, documentId: String, data: T) -> AnyPublisher<Void, Error> {
        return Future { promise in
            do {
                try self.db.collection(collection).document(documentId).setData(from: data, merge: true)
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    /// Deleta um documento da coleção.
    func delete(collection: String, documentId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.db.collection(collection).document(documentId).delete { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    // MARK: - Funções de CRUD Avançadas

    /// Busca todos os documentos de uma coleção.
    func getAll<T: Decodable>(collection: String) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            self.db.collection(collection).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                guard let querySnapshot = querySnapshot else {
                    promise(.success([]))
                    return
                }

                var items: [T] = []
                for document in querySnapshot.documents {
                    do {
                        let item = try document.data(as: T.self)
                        items.append(item)
                    } catch {
                        promise(.failure(error))
                        return
                    }
                }
                promise(.success(items))
            }
        }.eraseToAnyPublisher()
    }

    /// Busca documentos por um campo específico com um valor específico.
    func findByField<T: Decodable>(collection: String, fieldName: String, fieldValue: Any) -> AnyPublisher<[T], Error> {
        return Future<[T], Error> { promise in
            self.db.collection(collection)
                .whereField(fieldName, isEqualTo: fieldValue)
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    guard let querySnapshot = querySnapshot else {
                        promise(.success([]))
                        return
                    }

                    var items: [T] = []
                    for document in querySnapshot.documents {
                        do {
                            let item = try document.data(as: T.self)
                            items.append(item)
                        } catch {
                            promise(.failure(error))
                            return
                        }
                    }
                    promise(.success(items))
                }
        }.eraseToAnyPublisher()
    }

    /// Atualiza apenas um campo específico de um documento.
    func updateField(collection: String, documentId: String, fieldName: String, fieldValue: Any) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.db.collection(collection).document(documentId).updateData([
                fieldName: fieldValue
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }
}