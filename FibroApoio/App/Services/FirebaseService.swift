//
//  FirebaseService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import FirebaseFirestore
import Combine

class FirebaseService {
    let db = Firestore.firestore()
    private let localStorageService: LocalStorageService

    init(localStorageService: LocalStorageService) {
        self.localStorageService = localStorageService
    }

    // MARK: - CRUD Basic

    func create<T: Encodable & AuditFields>(collection: String, documentId: String? = nil, data: T) -> AnyPublisher<Void, Error> {
        print("\n- CRIANDO DADOS NO FIRESTORE -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId ?? "Nenhum")")

        var mutableData = data
        if mutableData.createdAt == nil {
            mutableData.createdAt = Timestamp(date: Date())
        }
        if mutableData.updatedAt == nil {
            mutableData.updatedAt = Timestamp(date: Date())
        }
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

    // MARK: - CRUD Advanced

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

    // MARK: - Date Manipulation CRUD

    // FirebaseService.swift

    func findByDateAndField<T: Decodable>(
        collection: String,
        fieldName: String,
        from: Date,
        to: Date? = nil,
        filterField: String? = nil,
        filterValue: String? = nil
    ) -> AnyPublisher<[T], Error> {
        var query: Query = db.collection(collection)
            .whereField(fieldName, isGreaterThanOrEqualTo: Timestamp(date: from))

        if let to = to {
            query = query.whereField(fieldName, isLessThanOrEqualTo: Timestamp(date: to))
        }

        if let filterField = filterField, let filterValue = filterValue {
            query = query.whereField(filterField, isEqualTo: filterValue)
        }

        return Future<[T], Error> { promise in
            query.getDocuments { snapshot, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }

                let items: [T] = snapshot?.documents.compactMap {
                    try? $0.data(as: T.self) 
                } ?? []

                promise(.success(items))
            }
        }
        .eraseToAnyPublisher()
    }


    func createDocumentWithDate<T: Encodable & AuditFields>(
        collection: String,
        documentId: String? = nil,
        data: T,
        customDate: Date
    ) -> AnyPublisher<Void, Error> {
        print("\n- CRIANDO COM DATA CUSTOM -\n COLLECTION:\(collection)\n DOCUMENT ID: \(documentId ?? "Nenhum")")

        var mutableData = data
        mutableData.createdAt = Timestamp(date: customDate)
        mutableData.updatedAt = Timestamp(date: customDate)
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

    // MARK: - Util

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

    func reference(to path: String) -> DocumentReference {
        return Firestore.firestore().document(path)
    }
}
