//
//  AtomNumberInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI
import SwiftUI

struct AtomNumberInput: View {
    // MARK: - Properties

    // Configurações
    var placeholder: String
    var label: String?
    var icon: String?
    var iconPosition: Edge.Set = .leading
    var mask: String?
    var maxLength: Int?

    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false

    // Binding para o valor do texto
    @Binding var text: String

    @FocusState private var inFocus: Bool
    var onSubmit: (() -> Void)? = nil

    // MARK: - Init

    init(
        placeholder: String,
        label: String? = nil,
        icon: String? = nil,
        iconPosition: Edge.Set = .leading,
        mask: String? = nil,
        maxLength: Int? = nil,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        text: Binding<String>,
        onSubmit: (() -> Void)? = nil
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
        self.onSubmit = onSubmit
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading) {
            // Label se existir
            labelView()
            
            // Campo de entrada
            GeometryReader { geometry in
                ZStack {
                    // Campo numérico
                    inputFieldBackground(geometry: geometry)
                    
                    // Ícones
                    iconView(geometry: geometry)
                }
            }
            .frame(maxHeight: 55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Helper Methods
    
    // Método para o label
    private func labelView() -> some View {
        Group {
            if let label = label {
                Text(label)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            }
        }
    }
    
    // Método para o background do campo
    private func inputFieldBackground(geometry: GeometryProxy) -> some View {
        numberInputField()
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
    }
    
    // Método para o ícone
    private func iconView(geometry: GeometryProxy) -> some View {
        Group {
            if icon != nil && iconPosition == .leading {
                Image(systemName: icon!)
                    .foregroundColor(.gray)
                    .offset(x: -geometry.size.width * 0.42)
            } else if icon != nil && iconPosition == .trailing {
                Image(systemName: icon!)
                    .foregroundColor(.gray)
                    .offset(x: geometry.size.width * 0.42)
            }
        }
    }
    
    // Método para o campo de entrada numérico
    private func numberInputField() -> some View {
        TextField(placeholder, text: $text)
            .keyboardType(.numberPad)
            .focused($inFocus)
            .onChange(of: text) { handleTextChange() }
    }
    
    // Método para lidar com a mudança de texto
    private func handleTextChange() {
        var formattedText = format(text)
        print(formattedText.count)
        if let maxLength = maxLength, formattedText.count >= maxLength {
            let index = formattedText.index(formattedText.startIndex, offsetBy: maxLength)
            formattedText = String(formattedText[..<index])
            callOnSubmit()
        }
        text = formattedText
    }
    
    // Método para chamar onSubmit se existir
    private func callOnSubmit() {
        if let onSubmit = self.onSubmit {
            onSubmit()
        }
    }

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
