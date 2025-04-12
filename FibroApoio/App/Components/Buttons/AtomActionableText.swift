//
//  ActionableTextView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI

struct ActionableText: View {

    // MARK: - Properties

    let fullText: String
    let actions: [String: () -> Void]
    let textStyle: TextStyles

    private let fontSizes = FontSizes()
    private let fontFamilies = FontFamilies()
    private let textTypes: TextTypes

    // Estilos
    var textColor: Color = .primary
    var actionableTextColor: Color = .blue
    var underlined: Bool = true

    // MARK: - Initialization

    init(fullText: String, actions: [String: () -> Void], textStyle: TextStyles, textColor: Color = .primary, actionableTextColor: Color = .blue, underlined: Bool = true) {
        self.fullText = fullText
        self.actions = actions
        self.textStyle = textStyle
        self.textColor = textColor
        self.actionableTextColor = actionableTextColor
        self.underlined = underlined
        self.textTypes = TextTypes(fontSizes: fontSizes, fontFamilies: fontFamilies)
    }

    // MARK: - Computed Attributes

    private func getFont() -> Font {
        switch textStyle {
        case .title:
            return textTypes.title
        case .headingLG:
            return textTypes.headingLG
        case .heading:
            return textTypes.heading
        case .headingSM:
            return textTypes.headingSM
        case .subtitle:
            return textTypes.subtitle
        case .bodyLG:
            return textTypes.bodyLG
        case .body:
            return textTypes.body
        case .bodySM:
            return textTypes.bodySM
        case .caption:
            return textTypes.caption
        case .quote:
            return textTypes.quote
        case .mono:
            return textTypes.mono
        case .emphasis:
            return textTypes.emphasis
        }
    }

    // MARK: - Subviews

    var body: some View {
        createActionableText()
    }

    // MARK: - Methods

    
    private func createActionableText() -> some View {
        var currentText = fullText
        var view: AnyView = AnyView(Text(""))

        for (actionText, action) in actions {
            if let range = currentText.range(of: actionText, options: .caseInsensitive) {
                let prefix = String(currentText[..<range.lowerBound])
                let suffix = String(currentText[range.upperBound...])
                
                view = AnyView(
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(prefix)
                            .font(getFont())
                            .foregroundColor(textColor)
                        
                        Button(action: action) {
                            Text(actionText)
                                .font(getFont())
                                .foregroundColor(actionableTextColor)
                                .underline(underlined)
                        }
                        
                        Text(suffix)
                            .font(getFont())
                            .foregroundColor(textColor)
                    }
                )
                
                currentText = "" // texto já foi consumido
            }
        }

        // Se não houver actions, retorna o texto completo formatado
        if actions.isEmpty || !currentText.isEmpty {
            view = AnyView(
                Text(fullText)
                    .font(getFont())
                    .foregroundColor(textColor)
            )
        }

        return view
    }
}

// MARK: - Preview

struct ActionableTextView_Previews: PreviewProvider {
    static var previews: some View {
        let fullText = "Clique em Teste e Teste2 para executar ações."
        let actions: [String: () -> Void] = [
            "Teste": { print("Ação para Teste") },
            "Teste2": { print("Ação para Teste2") }
        ]

        return VStack {
            ActionableText(fullText: fullText, actions: actions, textStyle: .caption, textColor: .green, actionableTextColor: .red, underlined: false)
                .padding()
            ActionableText(fullText: fullText, actions: actions, textStyle: .body, textColor: .blue, actionableTextColor: .orange, underlined: true)
                .padding()
        }
    }
}
