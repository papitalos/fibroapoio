//
//  DialogPanel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 30/04/2025.
//

import SwiftUI

struct DialogPanel: View {
    // MARK: - Bindings
    @Binding var isPresented: Bool
    
    // MARK: - Configurações de texto
    let windowName: String?
    let title: String
    let description: String
    
    // MARK: - Ações dos botões
    let rightButton: (label: String, action: () -> Void)
    let leftButton: (label: String, action: () -> Void)?
    
    // MARK: - Estilo
    var panelBackground: Color = Color(.systemBackground)
    var titleFont: Font = .title2.bold()
    var descriptionFont: Font = .body
    var buttonFont: Font = .subheadline.bold()
    var leftButtonColor: Color = .gray.opacity(0.1)
    var rightButtonColor: Color = .accentColor
    
    init(
        isPresented: Binding<Bool>,
        windowName: String? = nil,
        title: String,
        description: String,
        rightButton: (label: String, action: () -> Void),
        leftButton: (label: String, action: () -> Void)? = nil,
        panelBackground: Color = Color(.systemBackground),
        titleFont: Font = .title2.bold(),
        descriptionFont: Font = .body,
        buttonFont: Font = .subheadline.bold(),
        leftButtonColor: Color = .gray.opacity(0.1),
        rightButtonColor: Color = .accentColor
    ) {
        self._isPresented = isPresented
        self.windowName = windowName
        self.title = title
        self.description = description
        self.rightButton = rightButton
        self.leftButton = leftButton
        self.panelBackground = panelBackground
        self.titleFont = titleFont
        self.descriptionFont = descriptionFont
        self.buttonFont = buttonFont
        self.leftButtonColor = leftButtonColor
        self.rightButtonColor = rightButtonColor
    }

    
    var body: some View {
        ZStack {
            // Background semi-transparente
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    withAnimation { isPresented = false }
                }
            
            // Painel de diálogo
            VStack(spacing: 16) {
                
                // Header: X + windowName
                HStack {
                    Button(action: {
                        withAnimation { isPresented = false }
                    }) {
                        Image(systemName: "xmark")
                            .foregroundColor(.secondary)
                            .padding(8)
                    }
                    
                    if let name = windowName {
                        Text(name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                }
                
                // Title
                Text(title)
                    .font(titleFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                // Description
                Text(description)
                    .font(descriptionFont)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.secondary)
                
                // Buttons
                HStack(spacing: 12) {
                    if let left = leftButton {
                        Button(action: {
                            left.action()
                            withAnimation { isPresented = false }
                        }) {
                            Text(left.label)
                                .font(buttonFont)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(.black)
                        }
                        .padding(16)
                        .background(leftButtonColor)
                        .cornerRadius(16)
                    }
                    
                    Button(action: {
                        rightButton.action()
                        withAnimation { isPresented = false }
                    }) {
                        Text(rightButton.label)
                            .font(buttonFont)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(.white)
                    }
                    .padding(16)
                    .background(rightButtonColor)
                    .cornerRadius(16)
                }
            }
            .padding(16)
            .background(panelBackground)
            .cornerRadius(16)
            .frame(maxWidth: 360)
            .shadow(radius: 20)
        }
        .animation(.easeInOut, value: isPresented)
    }
}

// MARK: - Preview

struct DialogPanel_Previews: PreviewProvider {
    @State static var showPanel = true
    
    static var previews: some View {
        ZStack {
            Color(.systemGray6).ignoresSafeArea()
            
            if showPanel {
                DialogPanel(
                    isPresented: $showPanel,
                    windowName: "Registro de Dores",
                    title: "Está sentindo alguma dor?",
                    description: "Dores musculares, dores de cabeça, dor nos ossos, alguma coisa?",
                    rightButton: (
                        label: "Sim, sinto dores",
                        action: { print("Sim, sinto dores clicado") }
                    ),
                    leftButton: (
                        label: "Não sinto dor",
                        action: { print("Não sinto dor clicado") }
                    )
                )
            }
        }
    }
}
