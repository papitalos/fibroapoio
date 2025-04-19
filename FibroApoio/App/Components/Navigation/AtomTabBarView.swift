//
//  AtomTabBarView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 08/04/2025.
//
import SwiftUI

struct AtomTabBarView: View {
    @Binding var selectedTab: Int
    
    let tabItems: [(icon: String, text: String)] = [
        (icon: "house", text: "Início"),
        (icon: "trophy.fill", text: "Ranking"),
        (icon: "plus.circle.fill", text: "Adicionar"),
        (icon: "clipboard", text: "Atividade"),
        (icon: "person", text: "Perfil")
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
                            .frame(width: 32, height: 32, alignment: .center)
                        Text(tabItems[index].text)
                            .font(.caption)
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .foregroundColor(selectedTab == index ? .blue : .gray)
                }
            }
        }
        .padding(12)
        .padding(.bottom, 8)
        .background(Color.white)
        .shadow(color: .gray.opacity(0.05) ,radius: 3, x: 0, y: -8)
    }
}

struct AtomTabBar_Previews: PreviewProvider {
    static var previews: some View {
        TabBarPreviewWrapper()
    }
}

// View auxiliar para manter o estado
struct TabBarPreviewWrapper: View {
    @State var selectedTab: Int = 1

    var body: some View {
        AtomTabBarView(selectedTab: $selectedTab)
    }
}
