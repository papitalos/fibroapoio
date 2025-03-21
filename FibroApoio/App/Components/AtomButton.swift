//
//  AtomButton.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

import SwiftUI

struct AtomButton: View {
    //MARK: - Properties

    // Configurações
    var label: String?
    var icon: String?
    var iconPosition: Edge.Set = .leading
    var action: () -> Void

    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var backgroundColor: Color = .gray
    var textColor: Color = .black

    //MARK: - Init

    init(
        action: @escaping () -> Void,
        label: String? = nil,
        icon: String? = nil,
        iconPosition: Edge.Set = .leading,
        password: Bool = false,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        backgroundColor: Color = .gray.opacity(0.5),
        textColor: Color = .black
    ) {
        self.action = action
        self.label = label
        self.icon = icon
        self.iconPosition = iconPosition
        self.borderRadius = borderRadius
        self.border = border
        self.backgroundColor = backgroundColor
        self.textColor = textColor
    }

    //MARK: - Body
    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                // Ícone à esquerda (se fornecido)
                if let icon = icon, iconPosition == .leading {
                    Image(systemName: icon)
                        .foregroundColor(textColor)
                }

                // Texto
                if let label = label {
                    Text(label)
                        .padding(.horizontal, 8)
                }

                // Ícone à direita (se fornecido)
                if let icon = icon, iconPosition == .trailing {
                    Image(systemName: icon)
                        .foregroundColor(textColor)
                }
            }.frame(maxWidth: .infinity, alignment: .center)
            .padding(16)
            .background(backgroundColor)
            .foregroundColor(textColor)
            .accentColor(.gray)
            .cornerRadius(borderRadius)
            .overlay {
                if border {
                    RoundedRectangle(cornerRadius: borderRadius)
                        .stroke(backgroundColor.opacity(0.5), lineWidth: 5)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

//MARK: - Preview

struct AtomButtont_Preview: PreviewProvider {
    static var previews: some View {
        VStack {
            AtomButton(
                action: { print("Botão pressionado!") },
                label: "Proximo",
                icon: "arrow.right",
                iconPosition: .trailing,
                borderRadius: 125,
                border: true,
                backgroundColor: .blue,
                textColor: .white
            )
        }
        .padding()
    }
}
