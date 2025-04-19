//
//  AtomTextInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

import SwiftUI
import SwiftUI

struct AtomTextInput: View {
    //MARK: - Properties

    // Configurações
    var placeholder: String
    var label: String?
    var password: Bool = false
    var maxLength: Int?
    var debug: Bool = false
    var type: UIKeyboardType = .default

    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var icon: String?
    var iconPosition: Edge.Set = .leading
    
    // Binding para o valor do texto
    @Binding var text: String

    @FocusState private var inFocus: Bool
    var onSubmit: (() -> Void)? = nil

    //MARK: - Init
    init(
        placeholder: String,
        label: String? = nil,
        icon: String? = nil,
        iconPosition: Edge.Set = .leading,
        password: Bool = false,
        maxLength: Int? = nil,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        text: Binding<String>,
        debug: Bool = false,
        type: UIKeyboardType = .default,
        onSubmit: (() -> Void)? = nil
    ) {
        self.placeholder = placeholder
        self.label = label
        self.icon = icon
        self.iconPosition = iconPosition
        self.password = password
        self.maxLength = maxLength
        self.borderRadius = borderRadius
        self.border = border
        self._text = text
        self.debug = debug
        self.type = type
        self.onSubmit = onSubmit
    }

    //MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            // Título do campo se existir
            labelView()
            
            // Campo de entrada
            GeometryReader { geometry in
                ZStack {
                    // Campo de texto (senha ou normal)
                    inputFieldBackground(geometry: geometry)
                    
                    // Ícones
                    iconView(geometry: geometry)
                }
            }
            .frame(maxHeight: 55)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    //MARK: - Helper Methods
    
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
        Group {
            if password {
                secureInputField()
            } else {
                regularInputField()
            }
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
    
    // Método para o campo de entrada regular
    private func regularInputField() -> some View {
        TextField(placeholder, text: $text)
            .keyboardType(type)
            .focused($inFocus)
            .submitLabel(.next)
            .onSubmit {
                if let onSubmit = self.onSubmit {
                    onSubmit()
                }
            }
            .onChange(of: text) { handleTextChange() }
    }
    
    // Método para o campo de entrada seguro (senha)
    private func secureInputField() -> some View {
        SecureField(placeholder, text: $text)
            .keyboardType(type)
            .focused($inFocus)
            .submitLabel(.next)
            .onSubmit {
                if let onSubmit = self.onSubmit {
                    onSubmit()
                }
            }
            .onChange(of: text) { handleTextChange() }
    }
    
    // Método para lidar com a mudança de texto
    private func handleTextChange() {
        if let maxLength = maxLength, text.count > maxLength {
            let index = text.index(text.startIndex, offsetBy: maxLength)
            text = String(text[..<index])
            callOnSubmit()
        }
        
        if debug { print(text) }
    }
    
    // Método para chamar onSubmit se existir
    private func callOnSubmit() {
        if let onSubmit = self.onSubmit {
            onSubmit()
        }
    }
}

//MARK: - Preview
struct AtomTextInputPreview: View {
    @State private var email: String = ""
    @State private var senha: String = ""

    var body: some View {
        VStack {
            AtomTextInput(
                placeholder: "Email",
                label: "Digite seu email",
                icon: "envelope.fill",
                iconPosition: .leading,
                maxLength: 30,
                text: $email,
                debug: true,
                type: .emailAddress
            )
            
            AtomTextInput(
                placeholder: "Senha",
                label: "Digite sua senha",
                icon: "lock",
                iconPosition: .trailing,
                password: true,
                maxLength: 15,
                text: $senha,
                debug: true,
                type: .default
            )
        }
        .padding()
    }
}

struct AtomTextInput_Previews: PreviewProvider {
    static var previews: some View {
        AtomTextInputPreview()
    }
}
