    //
    //  UserService.swift
    //  FibroApoio
    //
    //  Created by Italo Teofilo Filho on 26/03/2025.
    //

    import Combine
    import FirebaseAuth
    import FirebaseFirestore

    class UserService {
        @Published private(set) var currentUser: User?
        @Published private(set) var weeklyData: UserWeeklyData = .init()
        @Published private(set) var rankUsers: [User] = []

        private let firebaseService: FirebaseService
        private let localStorageService: LocalStorageService
        private let utilService: UtilService

        var cancellables = Set<AnyCancellable>()

        init(
            firebaseService: FirebaseService,
            localStorageService: LocalStorageService,
            utilService: UtilService,
        ) {
            self.firebaseService = firebaseService
            self.localStorageService = localStorageService
            self.utilService = utilService
        }
        // MARK: - Rank List
        func loadUsersWithSameRank() -> AnyPublisher<Void, Error> {
            return fetchUsersWithSameRank()
                    .handleEvents(receiveOutput: { users in
                        self.rankUsers = users
                        print("✅ Usuários com mesmo rank carregados: \(users.count)")
                    })
                    .map { _ in () }
                    .eraseToAnyPublisher()
        }
        
        func fetchUsersWithSameRank() -> AnyPublisher<[User], Error> {
            guard let rankRef = currentUser?.id_rank else {
                return Fail(error: NSError(domain: "UserService", code: -11, userInfo: [NSLocalizedDescriptionKey: "Rank do usuário não encontrado"]))
                    .eraseToAnyPublisher()
            }

            return Future<[User], Error> { promise in
                self.firebaseService.db.collection("usuarios")
                    .whereField("id_rank", isEqualTo: rankRef)
                    .order(by: "pontuacao", descending: true)
                    .limit(to: 50)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            promise(.failure(error))
                            return
                        }

                        let users: [User] = snapshot?.documents.compactMap { try? $0.data(as: User.self) } ?? []
                        promise(.success(users))
                    }
            }
            .eraseToAnyPublisher()
        }

        //MARK: - User Load/Fetch
        func loadUser() -> AnyPublisher<Void, Error> {
            guard let userId = Auth.auth().currentUser?.uid else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: 401,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Usuário não autenticado"
                        ]
                    )
                ).eraseToAnyPublisher()
            }

            return fetchFirebaseUser(userId: userId)
                .flatMap { user -> AnyPublisher<Void, Error> in
                    guard let user = user else {
                        return Fail(
                            error: NSError(
                                domain: "UserService",
                                code: 404,
                                userInfo: [
                                    NSLocalizedDescriptionKey:
                                        "Usuário não encontrado no Firebase"
                                ]
                            )
                        ).eraseToAnyPublisher()
                    }
                    
                    // Limpa cache antigo para evitar dados inconsistentes
                    self.localStorageService.deleteUser()
                    self.localStorageService.deleteWeeklyData()
                    print("🧹 LocalStorage do usuário limpado.")

                    self.saveUserToMemoryAndCache(user)
                    return self.loadWeeklyData()
                        .flatMap { _ in self.loadUsersWithSameRank() }
                        .eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }

        func fetchFirebaseUser(userId: String) -> AnyPublisher<User?, Error> {
            return firebaseService.read(
                collection: "usuarios",
                documentId: userId
            ).eraseToAnyPublisher()
        }

        private func saveUserToMemoryAndCache(_ user: User) {
            self.localStorageService.saveUser(user: user)
            self.currentUser = user
        }

        //MARK: - User Data Load
        func loadWeeklyData() -> AnyPublisher<Void, Error> {
            guard let userId = currentUser?.id else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: -1,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Usuário não carregado"
                        ]
                    )
                ).eraseToAnyPublisher()
            }

            if let cachedData = localStorageService.loadWeeklyData(),
               let cachedDate = localStorageService.loadWeeklyDataDate(),
               Calendar.current.isDate(cachedDate, equalTo: Date(), toGranularity: .weekOfYear) {

                self.weeklyData = cachedData
                print("📦 Dados semanais carregados do LocalStorage")
                return Just(())
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }


            guard let (startOfWeek, endOfWeek) = UtilService.currentWeekInterval else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: -2,
                        userInfo: [
                            NSLocalizedDescriptionKey: "Erro ao calcular semana"
                        ]
                    )
                ).eraseToAnyPublisher()
            }


            let exerciciosPub =
                firebaseService.findByDateAndField(
                    collection: "exercicios",
                    fieldName: "createdAt",
                    from: startOfWeek,
                    to: endOfWeek,
                    filterField: "id_usuario",
                    filterValue: userId
                ) as AnyPublisher<[Exercicio], Error>
            
            let doresPub =
                firebaseService.findByDateAndField(
                    collection: "dores",
                    fieldName: "createdAt",
                    from: startOfWeek,
                    to: endOfWeek,
                    filterField: "id_usuario",
                    filterValue: userId
                ) as AnyPublisher<[Dor], Error>

            let checkinsPub =
                firebaseService.findByDateAndField(
                    collection: "checkin",
                    fieldName: "createdAt",
                    from: startOfWeek,
                    to: endOfWeek,
                    filterField: "id_usuario",
                    filterValue: userId
                ) as AnyPublisher<[Checkin], Error>

            let medicacoesPub =
                firebaseService.findByDateAndField(
                    collection: "medicacoes",
                    fieldName: "createdAt",
                    from: startOfWeek,
                    to: endOfWeek,
                    filterField: "id_usuario",
                    filterValue: userId
                ) as AnyPublisher<[Medicacao], Error>

            return Publishers.Zip4(
                exerciciosPub,
                doresPub,
                checkinsPub,
                medicacoesPub
            )
            .map { exercicios, dores, checkins, medicacoes in
                
                let exercicioPorDia = Self.aggregateMinutesByDay(
                    exercicios: exercicios
                )
                let streakPorDia = Self.aggregateStreakByDay(checkins: checkins)
                let data = UserWeeklyData(
                    exercicios: exercicios,
                    dores: dores,
                    checkins: checkins,
                    medicacoes: medicacoes,
                    exercicioPorDia: exercicioPorDia,
                    streakPorDia: streakPorDia
                )
                self.weeklyData = data
                self.localStorageService.saveWeeklyData(data)
                self.localStorageService.saveWeeklyDataDate(Date())
            }
            .map { _ in () }
            .eraseToAnyPublisher()
        }

        private static func aggregateMinutesByDay(exercicios: [Exercicio]) -> [Int] {
            var result = Array(repeating: 0, count: 7)

            for ex in exercicios {
                if let date = ex.duracao_inicio?.dateValue(),
                   let minutos = ex.duracao_minutos {
                    let weekday = Calendar.current.component(.weekday, from: date) - 1
                    guard (0..<7).contains(weekday) else { continue }

                    result[weekday] += minutos
                }
            }

            let normalized = result.map { minutos -> Int in
                let minThreshold = 10.0  // mínimo aceitável = 1 ponto
                let ideal = 40.0         // ideal = 7 pontos
                let max = 90.0           // máximo = 10 pontos

                let m = Double(minutos)

                if m < minThreshold {
                    return 0
                } else if m >= max {
                    return 10
                } else if m <= ideal {
                    // de 10 a 40 minutos → de 1 a 7 pontos
                    let percent = (m - minThreshold) / (ideal - minThreshold)
                    return Int(round(1 + percent * (7 - 1)))
                } else {
                    // de 40 a 90 minutos → de 7 a 10 pontos
                    let percent = (m - ideal) / (max - ideal)
                    return Int(round(7 + percent * (10 - 7)))
                }
            }

            return normalized
        }



        private static func aggregateStreakByDay(checkins: [Checkin]) -> [Int] {
            var result = Array(repeating: -1, count: 7)
            for ch in checkins {
                if let date = ch.createdAt?.dateValue(),
                    let status = ch.status_streak
                {
                    let weekday =
                        Calendar.current.component(.weekday, from: date) - 1
                    result[weekday] = status
                }
            }
            return result
        }

        //MARK: - User CRUD BASIC
        func createUser(user: User, documentID: String? = nil) -> AnyPublisher<Void, Error> {
            return firebaseService.create(
                collection: "usuarios",
                documentId: documentID,
                data: user
            )
            .handleEvents(receiveCompletion: { completion in
                if case .finished = completion {
                    self.localStorageService.saveUser(user: user)
                }
            })
            .eraseToAnyPublisher()
        }

        func persistCurrentUser(_ update: User) -> AnyPublisher<Void, Error> {
            guard let userId = currentUser?.id, userId == update.id else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário atual inválido"]
                    )
                ).eraseToAnyPublisher()
            }

            return firebaseService.update(
                collection: "usuarios",
                documentId: userId,
                data: update
            )
            .handleEvents(receiveCompletion: { completion in
                if case .finished = completion {
                    self.localStorageService.saveUser(user: update)
                    self.currentUser = update
                }
            })
            .eraseToAnyPublisher()
        }

        func deleteCurrentUser() -> AnyPublisher<Void, Error> {
            guard let userId = currentUser?.id else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: -4,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário atual não encontrado"]
                    )
                ).eraseToAnyPublisher()
            }

            return firebaseService.delete(
                collection: "usuarios",
                documentId: userId
            )
            .handleEvents(receiveCompletion: { completion in
                if case .finished = completion {
                    self.localStorageService.deleteUser()
                    self.currentUser = nil
                }
            })
            .eraseToAnyPublisher()
        }
        
        func persistWeeklyData(_ update: (inout UserWeeklyData) -> Void) -> AnyPublisher<Void, Error> {
            guard currentUser?.id != nil else {
                return Fail(
                    error: NSError(
                        domain: "UserService",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário não carregado"]
                    )
                ).eraseToAnyPublisher()
            }

            var updatedData = weeklyData
            update(&updatedData)
            
            updatedData.exercicioPorDia = Self.aggregateMinutesByDay(exercicios: updatedData.exercicios)
            updatedData.streakPorDia = Self.aggregateStreakByDay(checkins: updatedData.checkins)
            
            let batch = Firestore.firestore().batch()
            let date = Date()
            
            // Atualiza todos os createdAt que foram gerados agora, na cópia original em memória
            for i in updatedData.medicacoes.indices {
                if updatedData.medicacoes[i].createdAt == nil {
                    updatedData.medicacoes[i].createdAt = Timestamp(date: date)
                }
            }
            for i in updatedData.exercicios.indices {
                if updatedData.exercicios[i].createdAt == nil {
                    updatedData.exercicios[i].createdAt = Timestamp(date: date)
                }
            }
            for i in updatedData.dores.indices {
                if updatedData.dores[i].createdAt == nil {
                    updatedData.dores[i].createdAt = Timestamp(date: date)
                }
            }
            for i in updatedData.checkins.indices {
                if updatedData.checkins[i].createdAt == nil {
                    updatedData.checkins[i].createdAt = Timestamp(date: date)
                }
            }
            
            weeklyData = updatedData.copy()
            
            localStorageService.saveWeeklyData(updatedData)
            localStorageService.saveWeeklyDataDate(Date())

            func upsert<T: AuditFields & Encodable>(_ item: T, collection: String) {
                let ref = item.id != nil
                    ? firebaseService.db.collection(collection).document(item.id!)
                    : firebaseService.db.collection(collection).document()

                var copy = item
                if copy.id == nil { copy.id = ref.documentID }
                if copy.createdAt == nil {
                    copy.createdAt = Timestamp(date: date)
                    print("🆕 Criando createdAt para item novo: \(copy)")
                }

                copy.updatedAt = Timestamp(date: date)

                batch.setData(copy.toFirestore(), forDocument: ref, merge: true)
            }

            updatedData.dores.forEach { upsert($0, collection: "dores") }
            updatedData.exercicios.forEach { upsert($0, collection: "exercicios") }
            updatedData.medicacoes.forEach { upsert($0, collection: "medicacoes") }
            updatedData.checkins.forEach { upsert($0, collection: "checkin") }

            return Future<Void, Error> { promise in
                batch.commit { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(()))
                    }
                }
            }.eraseToAnyPublisher()
        }


        //MARK: - User CRUD ADVANCED
        func findDocumentsByDate<T: Decodable & AuditFields>(collection: String, from startDate: Date, to endDate: Date? = nil) -> AnyPublisher<[T], Error> {
                return firebaseService.findByDateAndField(
                    collection: collection,
                    fieldName: "createdAt",
                    from: startDate,
                    to: endDate,
                    filterField: "id_usuario",
                    filterValue: currentUser?.id ?? ""
                )
            }

        func findLastDocument<T: Decodable & AuditFields>(collection: String, fieldName: String = "createdAt") -> AnyPublisher<T?, Error> {
            guard let userId = currentUser?.id else {
                return Fail(error: NSError(domain: "UserService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado"])).eraseToAnyPublisher()
            }

            return Future<T?, Error> { promise in
                self.firebaseService.db.collection(collection)
                    .whereField("id_usuario", isEqualTo: userId)
                    .order(by: fieldName, descending: true)
                    .limit(to: 1)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            return promise(.failure(error))
                        }
                        guard let doc = snapshot?.documents.first else {
                            return promise(.success(nil))
                        }
                        do {
                            let item = try doc.data(as: T.self)
                            if item.isSoftDeleted {
                                return promise(.success(nil))
                            }
                            promise(.success(item))
                        } catch {
                            promise(.failure(error))
                        }
                    }
            }.eraseToAnyPublisher()
        }
        

        //MARK: - Helpers
        /// Gera um nickname aleatorio para o usuario
        func generateRandomNickname() -> String {
            let adjectives = [
                "Rápido", "Bravo", "Feroz", "Gentil", "Sábio", "Valente", "Ágil",
            ]
            let animals = [
                "Leão", "Tigre", "Águia", "Lobo", "Falcão", "Pantera", "Grifo",
            ]
            let adjective = adjectives.randomElement()!
            let animal = animals.randomElement()!
            let number = Int.random(in: 100...999)
            return "\(adjective)\(animal)\(number)"
        }

        func calculateCurrentUserAge(completion: @escaping (Int?) -> Void) {
            guard let birthTimestamp = currentUser?.data_nascimento else {
                print("‼️ data_nascimento não encontrada.")
                completion(nil)
                return
            }

            let birthDate = birthTimestamp.dateValue()
            let now = Date()
            let calendar = Calendar.current

            let ageComponents = calendar.dateComponents(
                [.year],
                from: birthDate,
                to: now
            )
            completion(ageComponents.year)
        }

        //MARK: - User Unload/Delete
        /// Remove o usuário do LocalStorage.
        func clearLocalStorage() {
            localStorageService.deleteUser()
        }

    }

    // MARK: - Extensions
    extension FirebaseService {
        func readUser(collection: String, documentId: String) -> AnyPublisher<
            User?, Error
        > {
            read(collection: collection, documentId: documentId)
        }
    }

    extension UserWeeklyData {
        func copy() -> UserWeeklyData {
            return UserWeeklyData(
                exercicios: self.exercicios,
                dores: self.dores,
                checkins: self.checkins,
                medicacoes: self.medicacoes,
                exercicioPorDia: self.exercicioPorDia,
                streakPorDia: self.streakPorDia
            )
        }
    }


    extension String {
        var firstName: String {
            components(separatedBy: " ").first ?? self
        }
    }
