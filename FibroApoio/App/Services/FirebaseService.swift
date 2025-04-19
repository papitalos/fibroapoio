//
//  FirebaseService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import FirebaseFirestore
import Combine

class FirebaseService {
    private let db = Firestore.firestore()

    init() {}

    // MARK: - Base CRUD

    /// Cria um novo documento na coleção especificada.
    func create<T: Encodable & AuditFields>(collection: String, documentId: String? = nil, data: T) -> AnyPublisher<Void, Error> {
        print("\n- CRIANDO DADOS NO FIRESTORE -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId ?? "Nenhum")")

        var mutableData = data
           mutableData.createdAt = Timestamp(date: Date())
           mutableData.updatedAt = Timestamp(date: Date())
           mutableData.deletedAt = nil
        
        return Future { promise in
                do {
                    let ref = documentId != nil
                        ? self.db.collection(collection).document(documentId!)
                        : self.db.collection(collection).document()
                    
                    try ref.setData(from: mutableData)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()
    }

    /// Busca um documento específico na coleção.
    func read<T: Decodable & AuditFields>(collection: String, documentId: String) -> AnyPublisher<T?, Error> {
        print("\n- BUSCANDO DADOS NO FIRESTORE -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId)")

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
                    
                    if item.isSoftDeleted {
                        promise(.success(nil))
                        return
                    }
                    
                    promise(.success(item))
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }



    /// Atualiza um documento existente na coleção.
    func update<T: Encodable & AuditFields>(collection: String, documentId: String, data: T) -> AnyPublisher<Void, Error> {
        print("\n- MODIFICANDO DADOS NO FIRESTORE -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId)")
        
        var mutableData = data
        mutableData.updatedAt = Timestamp(date: Date())
        
        return Future { promise in
                do {
                    try self.db.collection(collection).document(documentId).setData(from: mutableData, merge: true)
                    promise(.success(()))
                } catch {
                    promise(.failure(error))
                }
            }.eraseToAnyPublisher()
    }
    
    /// Deleta um documento por auditField
    func softDelete(collection: String, documentId: String) -> AnyPublisher<Void, Error> {
        return Future { promise in
            self.db.collection(collection).document(documentId).updateData([
                "deletedAt": Timestamp(date: Date())
            ]) { error in
                if let error = error {
                    promise(.failure(error))
                } else {
                    promise(.success(()))
                }
            }
        }.eraseToAnyPublisher()
    }

    /// Deleta um documento da coleção.
    func delete(collection: String, documentId: String) -> AnyPublisher<Void, Error> {
        print("\n- DELETANDO DADOS NO FIRESTORE -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId)")

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

    // MARK: - Advanced CRUD

    /// Busca todos os documentos de uma coleção.
    func getAll<T: Decodable>(collection: String) -> AnyPublisher<[T], Error> {
        return Future { promise in
            self.db.collection(collection)
                .whereField("deletedAt", isEqualTo: NSNull())
                .getDocuments { (querySnapshot, error) in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }

                    let docs = querySnapshot?.documents.compactMap { try? $0.data(as: T.self) } ?? []
                    promise(.success(docs))
                }
        }.eraseToAnyPublisher()
    }

    /// Busca documentos por um campo específico com um valor específico, ignorando soft deletes.
    func findByField<T: Decodable & AuditFields>(collection: String, fieldName: String, fieldValue: Any) -> AnyPublisher<[T], Error> {
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
                            
                            // Ignora documentos soft-deletados
                            if item.isSoftDeleted {
                                continue
                            }

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
    
    /// Verifica o documento no firebase
    func checkDocument(collection: String, documentId: String) {
        self.db.collection(collection).document(documentId).getDocument { (document, error) in
            if let error = error {
                print("Erro ao verificar documento: \(error.localizedDescription)")
                return
            }
            
            if let document = document, document.exists {
                print("Documento existe!")
                print("Dados: \(document.data() ?? [:])")
            } else {
                print("Documento não existe!")
            }
        }
    }
}
