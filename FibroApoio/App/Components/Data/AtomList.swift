//
//  AtomListView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 19/04/2025.
//


import SwiftUI

struct AtomListView: View {
    let items: [AtomListItem] // Array de itens que será exibido
    
    var body: some View {
        VStack(spacing: 10) {
            ForEach(items) { item in
                AtomListRow(item: item)
            }
        }
        .padding() // Espaçamento geral da lista
    }
}