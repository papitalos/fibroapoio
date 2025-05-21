//
//  RankService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 25/04/2025.
//

import FirebaseFirestore
import Combine

class RankService {
    let firebaseService: FirebaseService
    let userService: UserService
    let localStorageService: LocalStorageService
    private var cancellables = Set<AnyCancellable>()

    /// Ordem hierárquica fixa de ranks
    private let hierarchy: [(id: String, nome: String)] = [
        (id: "qQerwqu5Pnj85oQIu2EU", nome: "madeira"),
        (id: "6DOqqJRcXFSO1BtqHDGm", nome: "pedra"),
        (id: "UhTdVpM5W9P97JIuxYEv", nome: "bronze"),
        (id: "pcWCzoujA5swD0on6O3O", nome: "prata"),
        (id: "G3CwTQ2rToh1fJ4XgBut", nome: "ouro"),
        (id: "9bMkmwHqHjL06WzFb24z", nome: "diamante")
    ]

    init(firebaseService: FirebaseService, userService: UserService, localStorageService: LocalStorageService) {
        self.firebaseService = firebaseService
        self.userService = userService
        self.localStorageService = localStorageService
        
    }

    //MARK: - Points
    /// Adiciona pontos ao usuário atual (Firestore e LocalStorage)
    func addPointsToCurrentUser(_ points: Int) -> AnyPublisher<Void, Error> {
        return userService.fetchUser()
            .flatMap { user -> AnyPublisher<Void, Error> in
                guard var user = user, let userId = user.id else {
                    return Fail(error: NSError(
                        domain: "RankService",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado"]
                    )).eraseToAnyPublisher()
                }

                let newScore = (user.pontuacao ?? 0) + points
                user.pontuacao = newScore

                let updateData = UserScoreUpdate(pontuacao: newScore)
                return self.firebaseService.update(
                    collection: "usuarios", documentId: userId, data: updateData
                )
                .handleEvents(receiveCompletion: { completion in
                    if case .finished = completion {
                        self.userService.clearLocalStorage()
                        self.localStorageService.saveUser(user: user)
                    }
                })
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    /// Remove pontos do usuário atual (Firestore e LocalStorage)
    func removePointsFromCurrentUser(_ points: Int) -> AnyPublisher<Void, Error> {
        return addPointsToCurrentUser(-points)
    }
    
    //MARK: - Rank Fetch
    /// Busca um Rank pelo nome (campo “nome” no documento).
    func fetchRankByName(_ rankName: String) -> AnyPublisher<Rank?, Error> {
        return Future<Rank?, Error> { promise in
            self.firebaseService.db
                .collection("rank")
                .whereField("nome", isEqualTo: rankName)
                .limit(to: 1)
                .getDocuments { snapshot, error in
                    if let error = error {
                        return promise(.failure(error))
                    }
                    guard let doc = snapshot?.documents.first else {
                        return promise(.success(nil))
                    }
                    do {
                        let rank = try doc.data(as: Rank.self)
                        promise(.success(rank))
                    } catch {
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }

    func fetchNextRankById(_ currentRankId: String) -> AnyPublisher<Rank?, Error> {
        guard let idx = hierarchy.firstIndex(where: { $0.id == currentRankId }),
              idx < hierarchy.count - 1 else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let nextId = hierarchy[idx + 1].id
        return fetchRankById(nextId)
    }

    func fetchPreviousRankById(_ currentRankId: String) -> AnyPublisher<Rank?, Error> {
        guard let idx = hierarchy.firstIndex(where: { $0.id == currentRankId }),
              idx > 0 else {
            return Just(nil).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        let prevId = hierarchy[idx - 1].id
        return fetchRankById(prevId)
    }

    
    /// Busca o Rank atual do usuário (decodificando o `DocumentReference` salvo em `user.id_rank`).
     func fetchCurrentRank(completion: @escaping (Rank?) -> Void) {
         userService.fetchUser()
         .flatMap { user -> AnyPublisher<Rank?, Error> in
           guard let u = user, let ref = u.id_rank else {
             return Just(nil)
               .setFailureType(to: Error.self)
               .eraseToAnyPublisher()
           }
           let parts = ref.path.split(separator: "/")
           guard parts.count == 2 else {
             return Just(nil)
               .setFailureType(to: Error.self)
               .eraseToAnyPublisher()
           }
           return self.firebaseService.read(
             collection: String(parts[0]),
             documentId: String(parts[1])
           )
         }
         .sink(
           receiveCompletion: { _ in },
           receiveValue: { rank in
             if let rank = rank {
                 print("\n- FETCHING RANK -\n RESULTADO: Rank Encontrado ✅\n Nome: \(rank.getName())")
             } else {
                 print("\n- FETCHING RANK -\n RESULTADO: Rank Não Encontrado ‼️")
             }
             completion(rank)
           }
         )
         .store(in: &cancellables)
     }
    
    func fetchRankById(_ id: String) -> AnyPublisher<Rank?, Error> {
        return firebaseService.read(collection: "rank", documentId: id)
    }


    //MARK: - Rank Handle
    func evaluateUserRankForCurrentUser() -> AnyPublisher<Void, Error> {
        return userService.fetchUser()
            .flatMap { user -> AnyPublisher<Void, Error> in
                guard var user = user, let rankRef = user.id_rank else {
                    print("\n ‼️ERROR: Usuário ou referência de rank não encontrados.")
                    return Fail(error: NSError(
                        domain: "UserService",
                        code: 0,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário ou rank atual não encontrado"]
                    )).eraseToAnyPublisher()
                }

                let currentRankId = rankRef.path.split(separator: "/").last.map(String.init) ?? ""
                return self.fetchRankById(currentRankId)
                    .flatMap { currentRank -> AnyPublisher<Void, Error> in
                        guard let currentRank = currentRank,
                              let minScore = currentRank.pontuacao_min,
                              let userScore = user.pontuacao else {
                            print("\n ‼️ERROR: Dados do usuário ou rank inválidos.")
                            return Fail(error: NSError(
                                domain: "UserService",
                                code: 1,
                                userInfo: [NSLocalizedDescriptionKey: "Dados do usuário ou rank inválidos"]
                            )).eraseToAnyPublisher()
                        }

                        print("\n -ℹ️ RANK -\n ATUAL: \(currentRank.nome ?? "Desconhecido")\n Pontuação do usuário: \(userScore)\n Mínimo exigido para subir: \(minScore)")

                        if userScore >= minScore {
                            return self.fetchNextRankById(currentRankId)
                                .flatMap { nextRank -> AnyPublisher<Void, Error> in
                                    guard let next = nextRank else {
                                        print(" RESULTADO: Usuário já está no rank mais alto. 🟰\n")
                                        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                                    }

                                    let nextId = next.id ?? next.nome!
                                    user.id_rank = self.firebaseService.reference(to: "rank/\(nextId)")
                                    print(" RESULTADO: Usuário promovido para: \(next.nome ?? "Desconhecido") ✅\n")
                                    return self.userService.updateUser(user: user)
                                        .handleEvents(receiveCompletion: { completion in
                                            if case .finished = completion {
                                                self.userService.clearLocalStorage()
                                                self.localStorageService.saveUser(user: user)
                                            }
                                        })
                                        .eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        } else {
                            return self.fetchPreviousRankById(currentRankId)
                                .flatMap { prevRank -> AnyPublisher<Void, Error> in
                                    guard let prev = prevRank else {
                                        print(" RESULTADO: Usuário já está no menor rank. Não pode ser rebaixado. 🟰\n")
                                        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                                    }

                                    let prevId = prev.id ?? prev.nome!
                                    user.id_rank = self.firebaseService.reference(to: "rank/\(prevId)")
                                    print(" RESULTADO: Usuário rebaixado para: \(prev.nome ?? "Desconhecido")⬇️\n")
                                    return self.userService.updateUser(user: user)
                                        .handleEvents(receiveCompletion: { completion in
                                            if case .finished = completion {
                                                self.userService.clearLocalStorage()
                                                self.localStorageService.saveUser(user: user)
                                            }
                                        })
                                        .eraseToAnyPublisher()
                                }
                                .eraseToAnyPublisher()
                        }
                    }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

     
    //MARK: - Streak
    /// Função privada para registrar qualquer status de streak
    private func addStreak(status: Int) -> AnyPublisher<Void, Error> {
        return userService.fetchUser()
            .flatMap { user -> AnyPublisher<Void, Error> in
                guard let user = user, let userId = user.id else {
                    return Fail(error: NSError(
                        domain: "RankService",
                        code: 100 + status,
                        userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado para registrar streak status \(status)"]
                    )).eraseToAnyPublisher()
                }

                let checkin = Checkin(id_usuario: userId, status_streak: status)
                return self.firebaseService.create(collection: "checkin", data: checkin)
            }
            .eraseToAnyPublisher()
    }

    /// Congela o streak do usuário (status_streak = 1)
    func addEmptyStreak() -> AnyPublisher<Void, Error> {
        return addStreak(status: -1)
    }
    
    /// Marca o streak de hoje como concluído (status_streak = 1)
    func addStreakCompletion() -> AnyPublisher<Void, Error> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .second, value: 86399, to: startOfToday)!

        return firebaseService.findMyDocumentsByDate(
            collection: "checkin",
            fieldName: "createdAt",
            from: startOfToday,
            to: endOfToday
        )
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            guard var todayCheckin = checkins.first(where: { $0.status_streak == -1 }),
                  let docId = todayCheckin.id else {
                print("⚠️ Nenhum checkin com status -1 encontrado para hoje.")
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }

            todayCheckin.status_streak = 1
            return self.firebaseService.update(collection: "checkin", documentId: docId, data: todayCheckin)
        }
        .eraseToAnyPublisher()
    }

    
    /// Congela o streak do usuário (status_streak = 2)
    func addStreakFreeze() -> AnyPublisher<Void, Error> {
        return addStreak(status: 2)
    }

    /// Marca o streak como quebrado (status_streak = 0)
    func addStreakBreaking() -> AnyPublisher<Void, Error> {
        return addStreak(status: 0)
    }
    
    /// Garante um streak vazio se o usuario entrar no app
    func ensureEmptyStreakForToday() -> AnyPublisher<Void, Error> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .second, value: 86399, to: startOfToday)!

        return firebaseService.findMyDocumentsByDate(
            collection: "checkin",
            fieldName: "createdAt",
            from: startOfToday,
            to: endOfToday
        )
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            if checkins.isEmpty {
                return self.addEmptyStreak()
            } else {
                print("🟢 Já existe checkin hoje. Nenhum novo documento será criado.")
                return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    /// Verifica se o usuário fez check-in ontem. Caso não tenha feito, registra streak quebrado (85%) ou congelado (15%).
    func checkYesterdayStreak() -> AnyPublisher<Void, Error> {
        let calendar = Calendar.current
        guard let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: calendar.startOfDay(for: Date())),
              let endOfYesterday = calendar.date(byAdding: .second, value: 86399, to: startOfYesterday) else {
            return Fail(error: NSError(domain: "DateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Erro ao calcular data de ontem"]))
                .eraseToAnyPublisher()
        }
        
        return firebaseService.findMyDocumentsByDate(
            collection: "checkin",
            fieldName: "createdAt",
            from: startOfYesterday,
            to: endOfYesterday
        )
        .handleEvents(receiveOutput: { (checkins: [Checkin]) in
            print("\n- 🔁 VERIFICANDO SE O USUÁRIO FEZ CHECK-IN ONTEM -\n QUANTIDADE: \(checkins.count) 📊")
        }, receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("‼️ Erro ao buscar checkins de ontem: \(error)")
            default:
                break
            }
        })
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            if let yesterdayCheckin = checkins.first(where: { $0.status_streak == -1 }), let docId = yesterdayCheckin.id {
                let chance = Int.random(in: 1...100)
                let newStatus = chance <= 15 ? 2 : 0
                var updatedCheckin = yesterdayCheckin
                updatedCheckin.status_streak = newStatus
                return self.firebaseService.update(collection: "checkin", documentId: docId, data: updatedCheckin)
            }

            if checkins.isEmpty {
                return self.firebaseService.findLastMyDocument(collection: "checkin")
                    .flatMap { (lastCheckin: Checkin?) -> AnyPublisher<Void, Error> in
                        guard var last = lastCheckin else {
                            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }

                        guard let docId = last.id else {
                            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                        }

                        if last.status_streak == 1 || last.status_streak == 2, let lastDate = last.createdAt?.dateValue() {
                            let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: lastDate)!
                            let newCheckin = Checkin(id_usuario: last.id_usuario, status_streak: 0)
                            return self.firebaseService.createDocumentWithDate(
                                collection: "checkin",
                                data: newCheckin,
                                customDate: nextDay
                            )
                        } else if last.status_streak == -1 {
                            last.status_streak = 0
                            return self.firebaseService.update(collection: "checkin", documentId: docId, data: last)
                        }

                        return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }

            print(" RESULTADO: Tem documento de Checkin ✅\n")
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }

        .eraseToAnyPublisher()

    }

    
    struct UserScoreUpdate: Encodable, AuditFields {
        var pontuacao: Int
        var updatedAt: Timestamp?
        var createdAt: Timestamp? = nil
        var deletedAt: Timestamp? = nil
    }
}
