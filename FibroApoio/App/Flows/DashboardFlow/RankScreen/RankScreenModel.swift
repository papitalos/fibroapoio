//
//  RankScreenModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/04/2025.
//

struct RankingItem: Identifiable {
    var id: String
    var nickname: String
    var pontuacao: Int
    var rankName: String
    var position: Int? = nil
}
