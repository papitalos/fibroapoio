//
//  AtomNumberInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI

struct AtomNumberInput: View {
    // MARK: - Properties

    // Configurações
    var placeholder: String
    var label: String?
    var icon: String?
    var iconPosition: Edge.Set = .leading
    var mask: String?
    var maxLength: Int? // Novo parâmetro para limitar o tamanho

    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false

    // Binding para o valor do texto
    @Binding var text: String

    @FocusState private var inFocus: Bool

    // MARK: - Init

    init(
        placeholder: String,
        label: String? = nil,
        icon: String? = nil,
        iconPosition: Edge.Set = .leading,
        mask: String? = nil,
        maxLength: Int? = nil, // Inicializando maxLength
        borderRadius: CGFloat = 16,
        border: Bool = false,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.label = label
        self.icon = icon
        self.iconPosition = iconPosition
        self.mask = mask
        self.maxLength = maxLength
        self.borderRadius = borderRadius
        self.border = border
        self._text = text
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            if label != nil {
                Text(label ?? "")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            }

            GeometryReader { geometry in
                ZStack {
                    TextField(placeholder, text: $text)
                        .keyboardType(.numberPad)
                        .onChange(of: text) {
                            var formattedText = format(text)
                            if let maxLength = maxLength, formattedText.count > maxLength {
                                let index = formattedText.index(formattedText.startIndex, offsetBy: maxLength)
                                formattedText = String(formattedText[..<index])
                            }
                            text = formattedText
                        }
                        .padding(EdgeInsets(
                            top: 16,
                            leading: (icon != nil && iconPosition == .leading) ? 52 : 16,
                            bottom: 16,
                            trailing: (icon != nil && iconPosition == .trailing) ? 52 : 16
                        ))
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(borderRadius)
                        .overlay {
                            if border {
                                RoundedRectangle(cornerRadius: borderRadius)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            }
                        }
                        .foregroundColor(.blue)
                        .accentColor(.gray)
                        .cornerRadius(borderRadius)

                    // Ícone à esquerda (se fornecido)
                    if icon != nil && iconPosition == .leading {
                        Image(systemName: icon!)
                            .foregroundColor(.gray)
                            .offset(x: -geometry.size.width * 0.42)
                    }

                    // Ícone à direita (se fornecido)
                    if icon != nil && iconPosition == .trailing {
                        Image(systemName: icon!)
                            .foregroundColor(.gray)
                            .offset(x: geometry.size.width * 0.42)
                    }
                }
            }
            .frame(maxHeight: 55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Methods

    // Aplica a máscara ao número
    private func format(_ number: String) -> String {
        guard let mask = mask else {
            // Remove todos os caracteres não numéricos
            return number.filter { "0123456789".contains($0) }
        }

        var result = ""

        // Filtra apenas os dígitos do número inserido
        let digits = number.filter { "0123456789".contains($0) }
        var digitIndex = digits.startIndex

        for char in mask {
            if char == "X", digitIndex < digits.endIndex {
                result.append(digits[digitIndex])
                digitIndex = digits.index(after: digitIndex)
            } else {
                result.append(char)
            }
            if digitIndex >= digits.endIndex {
                break
            }
        }
        
        return result
    }
}

// MARK: - Preview

struct AtomNumberInputPreview: View {
    @State private var number: String = ""
    @State private var id: String = ""

    var body: some View {
        VStack {
            AtomNumberInput(
                placeholder: "Número de telemóvel",
                label: "Digite seu número",
                icon: "phone.fill",
                iconPosition: .leading,
                mask: "(XX) XXXX-XXXX",
                maxLength: 15,
                text: $number
            )
            
            AtomNumberInput(
                placeholder: "Identificação",
                label: "Digite sua ID",
                icon: "person.text.rectangle",
                iconPosition: .leading,
                mask: "XXX.XXX.XXX-XX",
                maxLength: 14,
                text: $id
            )
        }
        .padding()
    }
}

struct AtomNumberInput_Previews: PreviewProvider {
    static var previews: some View {
        AtomNumberInputPreview()
    }
}
