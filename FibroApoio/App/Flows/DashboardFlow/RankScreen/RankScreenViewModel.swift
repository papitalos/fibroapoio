//
//  RankScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 08/04/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class RankScreenViewModel: ObservableObject {
    @Service var userService: UserService
    @Service var gamificationService: GamificationService
    private var cancellables = Set<AnyCancellable>()

    @Published var ranking: [RankingItem] = []
    @Published var myItem: RankingItem?

    init() {
        observeRankUsers()
    }

    private func observeRankUsers() {
        userService.$rankUsers
            .receive(on: DispatchQueue.main)
            .sink { [weak self] users in
                guard let self, let currentUserId = userService.currentUser?.id else { return }

                let ordered = users.sorted(by: { ($0.pontuacao ?? 0) > ($1.pontuacao ?? 0) })

                let items: [RankingItem] = ordered.enumerated().map { index, user in
                    let rankId = user.id_rank?.documentID ?? ""
                    let rankName = self.gamificationService.getRankNameById(rankId)

                    return RankingItem(
                        id: user.id ?? UUID().uuidString,
                        nickname: user.nickname ?? "Anônimo",
                        pontuacao: user.pontuacao ?? 0,
                        rankName: rankName,
                        position: index + 1
                    )
                }

                self.ranking = items
                self.myItem = items.first(where: { $0.id == currentUserId })
            }
            .store(in: &cancellables)
    }
}
