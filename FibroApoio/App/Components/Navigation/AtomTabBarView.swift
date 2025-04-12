//
//  CustomTabBarView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 08/04/2025.
//


import SwiftUI

struct CustomTabBarView: View {
    @Binding var selectedTab: Int

    let tabItems: [(icon: String, text: String)] = [
        (icon: "house", text: "Início"),
        (icon: "magnifyingglass", text: "Buscar"),
        (icon: "plus.app", text: "Adicionar"),
        (icon: "bell", text: "Notificações"),
        (icon: "person.crop.circle", text: "Perfil")
    ]

    var body: some View {
        HStack {
            ForEach(0..<tabItems.count, id: \.self) { index in
                Button(action: {
                    selectedTab = index
                }) {
                    VStack {
                        Image(systemName: tabItems[index].icon)
                            .font(.title3)
                        Text(tabItems[index].text)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                }
            }
        }
        .padding(.horizontal)
        .background(Color.white) // Definindo o background da TabBar
        .shadow(radius: 3) // Adicionando uma sombra para destacar
    }
}