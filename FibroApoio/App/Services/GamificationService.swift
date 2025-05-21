//
//  GamificationService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 25/04/2025.
//

import Combine
import FirebaseFirestore

class GamificationService {
    let firebaseService: FirebaseService
    let userService: UserService
    let localStorageService: LocalStorageService
    var cancellables = Set<AnyCancellable>()

    /// Ordem hierárquica fixa de ranks
    private let hierarchy: [(id: String, nome: String)] = [
        (id: "qQerwqu5Pnj85oQIu2EU", nome: "madeira"),
        (id: "6DOqqJRcXFSO1BtqHDGm", nome: "pedra"),
        (id: "UhTdVpM5W9P97JIuxYEv", nome: "bronze"),
        (id: "pcWCzoujA5swD0on6O3O", nome: "prata"),
        (id: "G3CwTQ2rToh1fJ4XgBut", nome: "ouro"),
        (id: "9bMkmwHqHjL06WzFb24z", nome: "diamante"),
    ]

    init(
        firebaseService: FirebaseService,
        userService: UserService,
        localStorageService: LocalStorageService
    ) {
        self.firebaseService = firebaseService
        self.userService = userService
        self.localStorageService = localStorageService

    }

    //MARK: - Points
    func addPointsToCurrentUser(_ points: Int) -> AnyPublisher<Void, Error> {
        guard var user = userService.currentUser, user.id != nil else {
            return Fail(
                error: NSError(
                    domain: "GamificationService",
                    code: 0,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Usuário não encontrado"
                    ]
                )
            ).eraseToAnyPublisher()
        }

        let newScore = (user.pontuacao ?? 0) + points
        user.pontuacao = newScore

        return self.userService.persistCurrentUser(user)
    }

    func removePointsFromCurrentUser(_ points: Int) -> AnyPublisher<Void, Error>
    {
        return addPointsToCurrentUser(-points)
    }

    //MARK: - Rank Fetch
    func fetchRankByName(_ rankName: String) -> AnyPublisher<Rank?, Error> {
        return Future { promise in
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
        }.eraseToAnyPublisher()
    }

    func fetchRankById(_ id: String) -> AnyPublisher<Rank?, Error> {
        return firebaseService.read(collection: "rank", documentId: id)
    }

    func fetchCurrentRank(completion: @escaping (Rank?) -> Void) {
        guard let user = userService.currentUser, let ref = user.id_rank else {
            completion(nil)
            return
        }

        let parts = ref.path.split(separator: "/")
        guard parts.count == 2 else {
            completion(nil)
            return
        }

        firebaseService.read(
            collection: String(parts[0]),
            documentId: String(parts[1])
        )
        .sink(receiveCompletion: { _ in }, receiveValue: { completion($0) })
        .store(in: &cancellables)
    }

    func fetchNextRankById(_ currentRankId: String) -> AnyPublisher<
        Rank?, Error
    > {
        guard let idx = hierarchy.firstIndex(where: { $0.id == currentRankId }),
            idx < hierarchy.count - 1
        else {
            return Just(nil).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return fetchRankById(hierarchy[idx + 1].id)
    }

    func fetchPreviousRankById(_ currentRankId: String) -> AnyPublisher<
        Rank?, Error
    > {
        guard let idx = hierarchy.firstIndex(where: { $0.id == currentRankId }),
            idx > 0
        else {
            return Just(nil).setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return fetchRankById(hierarchy[idx - 1].id)
    }

    //MARK: - Rank Handle
    func evaluateUserRankForCurrentUser() -> AnyPublisher<RankChangeResult, Error> {
          guard var user = userService.currentUser, let rankRef = user.id_rank else {
              return Fail(error: NSError(
                  domain: "GamificationService",
                  code: 0,
                  userInfo: [NSLocalizedDescriptionKey: "Usuário ou referência de rank não encontrados"]
              )).eraseToAnyPublisher()
          }

          let currentRankId = rankRef.path.split(separator: "/").last.map(String.init) ?? ""

          return fetchRankById(currentRankId)
              .flatMap { currentRank -> AnyPublisher<RankChangeResult, Error> in
                  guard let currentRank = currentRank,
                        let minScore = currentRank.pontuacao_min,
                        let userScore = user.pontuacao else {
                      return Fail(error: NSError(
                          domain: "GamificationService",
                          code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Dados do usuário ou rank inválidos"]
                      )).eraseToAnyPublisher()
                  }

                  if userScore >= minScore {
                      return self.fetchNextRankById(currentRankId)
                          .flatMap { nextRank -> AnyPublisher<RankChangeResult, Error> in
                              guard let next = nextRank else {
                                  return Just(.none).setFailureType(to: Error.self).eraseToAnyPublisher()
                              }
                              let nextId = next.id ?? next.nome!
                              user.id_rank = self.firebaseService.reference(to: "rank/\(nextId)")
                              user.pontuacao = 200
                              return self.userService.persistCurrentUser(user)
                                  .map { .promote }
                                  .eraseToAnyPublisher()
                          }
                          .eraseToAnyPublisher()
                  } else {
                      return self.fetchPreviousRankById(currentRankId)
                          .flatMap { prevRank -> AnyPublisher<RankChangeResult, Error> in
                              guard let prev = prevRank else {
                                  return Just(.none).setFailureType(to: Error.self).eraseToAnyPublisher()
                              }
                              let prevId = prev.id ?? prev.nome!
                              user.id_rank = self.firebaseService.reference(to: "rank/\(prevId)")
                              user.pontuacao = 200
                              return self.userService.persistCurrentUser(user)
                                  .map { .demote }
                                  .eraseToAnyPublisher()
                          }
                          .eraseToAnyPublisher()
                  }
              }
              .eraseToAnyPublisher()
      }
    
    //MARK: - Streak
    func addStreak(status: Int) -> AnyPublisher<Void, Error> {
        guard let user = userService.currentUser, let userId = user.id else {
            return Fail(
                error: NSError(
                    domain: "GamificationService",
                    code: 100 + status,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Usuário não encontrado para registrar streak status \(status)"
                    ]
                )
            ).eraseToAnyPublisher()
        }

        let checkin = Checkin(id_usuario: userId, status_streak: status)
        return self.firebaseService.create(collection: "checkin", data: checkin)
    }

    func addEmptyStreak() -> AnyPublisher<Void, Error> {
        return addStreak(status: -1)
    }

    func addStreakFreeze() -> AnyPublisher<Void, Error> {
        return addStreak(status: 2)
    }

    /// Marca o streak de hoje como concluído (status_streak = 1)
    func addStreakCompletion() -> AnyPublisher<Checkin, Error> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(byAdding: .second, value: 86399, to: startOfToday)!

        return userService.findDocumentsByDate(
            collection: "checkin",
            from: startOfToday,
            to: endOfToday
        )
        .tryMap { (checkins: [Checkin]) -> Checkin in
            guard var todayCheckin = checkins.first(where: { $0.status_streak == -1 }) else {
                throw NSError(
                    domain: "Checkin",
                    code: -2,
                    userInfo: [NSLocalizedDescriptionKey: "Nenhum checkin com status -1 encontrado para hoje"]
                )
            }

            todayCheckin.status_streak = 1
            return todayCheckin
        }
        .flatMap { updatedCheckin in
            guard let id = updatedCheckin.id else {
                return Fail<Checkin, Error>(
                    error: NSError(
                        domain: "Checkin",
                        code: -1,
                        userInfo: [NSLocalizedDescriptionKey: "Checkin sem ID"]
                    )
                ).eraseToAnyPublisher()
            }

            return self.firebaseService
                .update(collection: "checkin", documentId: id, data: updatedCheckin)
                .map { updatedCheckin } // Passa o checkin adiante
                .eraseToAnyPublisher()
        }
        .handleEvents(receiveOutput: { updatedCheckin in
            self.userService.persistWeeklyData { weekly in
                if let index = weekly.checkins.firstIndex(where: { $0.id == updatedCheckin.id }) {
                    weekly.checkins[index] = updatedCheckin
                } else {
                    weekly.checkins.append(updatedCheckin)
                }
            }
            .sink(receiveCompletion: { _ in }, receiveValue: { _ in })
            .store(in: &self.userService.cancellables)
        })
        .eraseToAnyPublisher()
    }


    func incrementStreakAtualForCurrentUser() -> AnyPublisher<Void, Error> {
        guard var user = userService.currentUser else {
            return Fail(
                error: NSError(
                    domain: "GamificationService",
                    code: 999,
                    userInfo: [NSLocalizedDescriptionKey: "Usuário não encontrado para incrementar streak"]
                )
            ).eraseToAnyPublisher()
        }

        let currentStreak = user.streak_atual ?? 0
        user.streak_atual = currentStreak + 1

        return userService.persistCurrentUser(user)
    }


    /// Garante um streak vazio se o usuario entrar no app
    func ensureEmptyStreakForToday() -> AnyPublisher<Void, Error> {
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: Date())
        let endOfToday = calendar.date(
            byAdding: .second,
            value: 86399,
            to: startOfToday
        )!

        return userService.findDocumentsByDate(
            collection: "checkin",
            from: startOfToday,
            to: endOfToday
        )
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            if checkins.isEmpty {
                return self.addEmptyStreak()
            } else {
                print(
                    "🟢 Já existe checkin hoje. Nenhum novo documento será criado."
                )
                return Just(()).setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
        }
        .eraseToAnyPublisher()
    }

    /// Verifica se o usuário fez check-in ontem. Caso não tenha feito, registra streak quebrado (85%) ou congelado (15%).
    func checkYesterdayStreak() -> AnyPublisher<Void, Error> {
        let calendar = Calendar.current
        guard
            let startOfYesterday = calendar.date(
                byAdding: .day,
                value: -1,
                to: calendar.startOfDay(for: Date())
            ),
            let endOfYesterday = calendar.date(
                byAdding: .second,
                value: 86399,
                to: startOfYesterday
            )
        else {
            return Fail(
                error: NSError(
                    domain: "DateError",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Erro ao calcular data de ontem"
                    ]
                )
            )
            .eraseToAnyPublisher()
        }

        return userService.findDocumentsByDate(
            collection: "checkin",
            from: startOfYesterday,
            to: endOfYesterday
        )
        .handleEvents(receiveOutput: { (checkins: [Checkin]) in
            print(
                "\n- 🔁 VERIFICANDO SE O USUÁRIO FEZ CHECK-IN ONTEM -\n QUANTIDADE: \(checkins.count) 📊"
            )
        })
        .flatMap { (checkins: [Checkin]) -> AnyPublisher<Void, Error> in
            if let yesterdayCheckin = checkins.first(where: {
                $0.status_streak == -1
            }), let docId = yesterdayCheckin.id {
                let chance = Int.random(in: 1...100)
                let newStatus = chance <= 15 ? 2 : 0
                var updatedCheckin = yesterdayCheckin
                updatedCheckin.status_streak = newStatus
                return self.firebaseService.update(
                    collection: "checkin",
                    documentId: docId,
                    data: updatedCheckin
                )
            }

            if checkins.isEmpty {
                return self.userService.findLastDocument(collection: "checkin")
                    .flatMap {
                        (lastCheckin: Checkin?) -> AnyPublisher<Void, Error> in
                        guard var last = lastCheckin else {
                            return Just(()).setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        }

                        guard let docId = last.id else {
                            return Just(()).setFailureType(to: Error.self)
                                .eraseToAnyPublisher()
                        }

                        if last.status_streak == 1 || last.status_streak == 2,
                            let lastDate = last.createdAt?.dateValue()
                        {
                            let nextDay = calendar.date(
                                byAdding: .day,
                                value: 1,
                                to: lastDate
                            )!
                            let newCheckin = Checkin(
                                id_usuario: last.id_usuario,
                                status_streak: 0
                            )
                            return self.firebaseService.createDocumentWithDate(
                                collection: "checkin",
                                data: newCheckin,
                                customDate: nextDay
                            )
                        } else if last.status_streak == -1 {
                            last.status_streak = 0
                            return self.firebaseService.update(
                                collection: "checkin",
                                documentId: docId,
                                data: last
                            )
                        }

                        return Just(()).setFailureType(to: Error.self)
                            .eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }

            print(" RESULTADO: Tem documento de Checkin ✅\n")
            return Just(()).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
        .eraseToAnyPublisher()
    }
    
    //MARK: - Helpers
    func getRankNameById(_ id: String) -> String {
        return hierarchy.first(where: { $0.id == id })?.nome ?? "Rank desconhecido"
    }

    enum RankChangeResult {
         case promote, demote, none
    }
    
    struct UserScoreUpdate: Encodable, AuditFields {
        var id: String?
        
        var pontuacao: Int
        var updatedAt: Timestamp?
        var createdAt: Timestamp? = nil
        var deletedAt: Timestamp? = nil
    }
}
