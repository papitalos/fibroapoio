//
//  AtomTextInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

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
        type: UIKeyboardType = .default
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
    }

    //MARK: - Body
    var body: some View {
        VStack(alignment: .leading) {
            if label != nil {
                Text(label ?? "")
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 12)
            }

            GeometryReader { geometry in
                ZStack{
                    Group{
                        if password {
                            SecureField(placeholder, text: $text)
                                .keyboardType(type)
                                .onChange(of: text) {
                                    if let maxLength = maxLength, text.count > maxLength {
                                        let index = text.index(text.startIndex, offsetBy: maxLength)
                                        text = String(text[..<index])
                                    }
                                    
                                    if debug { print(text) }

                                }
                                .padding(EdgeInsets(
                                    top: 16,
                                    leading: (icon != nil && iconPosition == .leading) ? 52 :
                                        16,
                                    bottom: 16,
                                    trailing: (icon != nil && iconPosition == .trailing) ? 52 : 16))

                        } else {
                            TextField(placeholder, text: $text)
                                .keyboardType(type)
                                .onChange(of: text) {
                                    if let maxLength = maxLength, text.count > maxLength {
                                        let index = text.index(text.startIndex, offsetBy: maxLength)
                                        text = String(text[..<index])
                                    }
                                    
                                    if debug { print(text) }

                                }
                                .padding(EdgeInsets(
                                    top: 16,
                                    leading: (icon != nil && iconPosition == .leading) ? 52 :
                                        16,
                                    bottom: 16,
                                    trailing: (icon != nil && iconPosition == .trailing) ? 52 : 16))
                        }
                    }
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
            }.frame(maxHeight: 55)
          
        }
        .frame(maxWidth: .infinity, alignment: .leading)
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
