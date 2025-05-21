//
//  AtomList.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 19/04/2025.
//

import SwiftUI

struct AtomList: View {
    let items: [AtomListItem]

    var body: some View {
        VStack(spacing: 10) {
            ForEach(items) { item in
                AtomListRow(item: item)
            }
            
            if items.isEmpty {
                Text("Nenhum item encontrado.")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .padding(.vertical)
            }
        }
    }
}

struct AtomListRow: View {
    let item: AtomListItem
    @State private var isShowingActionSheet = false

    var body: some View {
        HStack {
            if let image = item.image {
                image
                    .frame(width: 40, height: 40)
                    .background(
                        Circle()
                            .fill(
                                item.imageBackground ?? Color.gray.opacity(0.3)
                            )
                    )
            } else {
                Circle()
                    .fill(item.imageBackground ?? Color.gray.opacity(0.3))
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                    if let tag = item.tag {
                        Text(tag)
                            .font(.caption)
                            .foregroundColor(item.tagTextColor ?? .black)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(
                                item.tagBackgroundColor != nil ?
                                    AnyView(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(item.tagBackgroundColor!)
                                    ) :
                                    AnyView(EmptyView())
                            )
                            .cornerRadius(8)
                    }

                }

                if let subtitle = item.subtitle {
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
            }
            .padding(.leading, 8)

            Spacer()

            if !item.actions.isEmpty {
                if item.actions.count == 1 {
                    Button(action: item.actions[0].action) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                    }
                } else {
                    Button(action: {
                        isShowingActionSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(.horizontal, 8)
                    }
                    .actionSheet(isPresented: $isShowingActionSheet) {
                        ActionSheet(
                            title: Text("Ações"),
                            buttons: item.actions.map { action in
                                .default(
                                    Text(action.name),
                                    action: action.action
                                )
                            } + [.cancel()]
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)

    }
}
struct AtomList_Previews: PreviewProvider {
    static var previews: some View {
        AtomList(items: [
            AtomListItem(
                title: "Musculação",
                subtitle: "2h atrás",
                image: Image(systemName: "flame.fill"),
                tag: "500 pontos",
                tagBackgroundColor: .orange.opacity(0.2),
                tagTextColor: .orange,
                imageBackground: .orange.opacity(0.3),
                actions: [
                    (name: "Editar", action: { print("Editar selecionado") }),
                    (name: "Apagar", action: { print("Apagar selecionado") })
                ]
            ),
            AtomListItem(
                title: "Registro de dor",
                subtitle: "3h atrás",
                image: Image(systemName: "heart.fill"),
                tag: nil,
                tagBackgroundColor: nil,
                tagTextColor: nil,
                imageBackground: .pink.opacity(0.3),
                actions: [
                    (name: "Ver detalhes", action: { print("Detalhes selecionado") })
                ]
            ),
            AtomListItem(
                title: "Registro de medicamento",
                subtitle: nil,
                image: Image(systemName: "pills.fill"),
                tag: "Tomado",
                tagBackgroundColor: nil,
                tagTextColor: nil,
                imageBackground: .blue.opacity(0.2),
                actions: []
            )
        ])
        .previewLayout(.sizeThatFits)
        .padding()
        .background(Color(UIColor.systemGroupedBackground))
    }
}
