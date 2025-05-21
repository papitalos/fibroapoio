//
//  RankScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//

import SwiftUI

struct RankScreenView: View {
    @StateObject var viewModel: RankScreenViewModel
    @EnvironmentObject var theme: Theme
    @Service var userService: UserService

    var body: some View {
        VStack(spacing: 16) {
            if let myItem = viewModel.myItem {
                TopUserCard(item: myItem, userName: userService.currentUser?.nome?.firstName ?? "Usuário" )
                    .padding(.horizontal)
            }

            ScrollView {
                AtomList(items: viewModel.ranking.enumerated().map { index, item in
                    let isCurrentUser = item.id == viewModel.myItem?.id
                    
                    return AtomListItem(
                        title: isCurrentUser ? (viewModel.userService.currentUser?.nome ?? "Você") : item.nickname,
                        subtitle: nil,
                        image: Image(systemName: "person.crop.circle.fill"),
                        tag: "#\(index + 1)",
                        tagBackgroundColor: index == 0 ? Color.green.opacity(0.2) : (index == 1 ? Color.green.opacity(0.1) : nil),
                        tagTextColor: .black,
                        imageBackground: Color.green.opacity(0.2),
                        actions: []
                    )
                })
                .padding(.horizontal)
                .padding(.bottom, 16)
            }
        }
    }
    
    init(viewModel: RankScreenViewModel? = nil) {
        if let viewModel = viewModel {
            _viewModel = StateObject(wrappedValue: viewModel)
        } else {
            _viewModel = StateObject(
                wrappedValue:
                    DependencyContainer.shared.container.resolve(
                        RankScreenViewModel.self
                    )!
            )
        }
    }
}

// MARK: - Preview

class MockRankScreenViewModel: RankScreenViewModel {
    override init() {
        super.init()
        
        self.ranking = [
            RankingItem(id: "1", nickname: "João Pereira", pontuacao: 14000, rankName: "Diamante", position: 1),
            RankingItem(id: "2", nickname: "Maria Clara", pontuacao: 12000, rankName: "Ouro", position: 2),
            RankingItem(id: "3", nickname: "Italo Teofilo Filho", pontuacao: 10500, rankName: "Madeira", position: 3),
            RankingItem(id: "4", nickname: "Rafael Costa", pontuacao: 9000, rankName: "Bronze", position: 4),
            RankingItem(id: "5", nickname: "João Rodrigues", pontuacao: 8500, rankName: "Bronze", position: 5),
            RankingItem(id: "6", nickname: "Diana Rodrigues", pontuacao: 7500, rankName: "Madeira", position: 6),
            RankingItem(id: "7", nickname: "Santiago Santos", pontuacao: 5000, rankName: "Madeira", position: 7),
            RankingItem(id: "8", nickname: "Alfredo Martins", pontuacao: 2500, rankName: "Madeira", position: 8),
            RankingItem(id: "9", nickname: "Joana Farias", pontuacao: 900, rankName: "Madeira", position: 9)
        ]
        
        self.myItem = ranking.first(where: { $0.nickname == "Italo Teofilo Filho" })
    }
}

struct RankScreenView_Previews: PreviewProvider {
    static var previews: some View {
        RankScreenView(viewModel: MockRankScreenViewModel())
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
