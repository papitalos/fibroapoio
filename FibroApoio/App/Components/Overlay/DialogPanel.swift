//
//  DialogPanel.swift
//  FibroApoio
//
//  Created by ChatGPT on 30/04/2025.
//

import SwiftUI

/// Um painel de diálogo genérico, com:
/// 1. “X” de fechar no canto superior esquerdo (e tap fora fecha);
/// 2. Nome da janela opcional ao lado do “X”;
/// 3. Título principal;
/// 4. Descrição;
/// 5. Botão esquerdo (opcional);
/// 6. Botão direito (obrigatório).
struct DialogPanel: View {
    
    // MARK: - Bindings
    /// Controle de exibição do painel
    @Binding var isPresented: Bool
    
    // MARK: - Configurações de texto
    /// Nome da janela (opcional)
    let windowName: String?
    /// Título principal
    let title: String
    /// Descrição
    let description: String
    
    // MARK: - Ações dos botões
    /// Botão da esquerda (texto + ação). Opcional.
    let leftButton: (label: String, action: () -> Void)?
    /// Botão da direita (texto + ação). Obrigatório.
    let rightButton: (label: String, action: () -> Void)
    
    // MARK: - Estilo
    var panelBackground: Color = Color(.systemBackground)
    var titleFont: Font = .title2.bold()
    var descriptionFont: Font = .body
    var buttonFont: Font = .headline
    var leftButtonStyle: ButtonStyle = DefaultButtonStyle()
    var rightButtonStyle: ButtonStyle = DefaultButtonStyle()
    
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
                        }
                        .buttonStyle(leftButtonStyle)
                    }
                    
                    Button(action: {
                        rightButton.action()
                        withAnimation { isPresented = false }
                    }) {
                        Text(rightButton.label)
                            .font(buttonFont)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(rightButtonStyle)
                }
            }
            .padding(24)
            .background(panelBackground)
            .cornerRadius(16)
            .frame(maxWidth: 320)
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
                    leftButton: (
                        label: "Não sinto dor",
                        action: { print("Não sinto dor clicado") }
                    ),
                    rightButton: (
                        label: "Sim, sinto dores",
                        action: { print("Sim, sinto dores clicado") }
                    )
                )
            }
        }
    }
}
