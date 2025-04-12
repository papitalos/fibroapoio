//
//  AtomLinkedTextView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI

struct AtomLinkedText: View {

    // MARK: - Properties

    let fullText: String
    let links: [String: URL]
    let textStyle: TextStyles

    private let fontSizes = FontSizes()
    private let fontFamilies = FontFamilies()
    private let textTypes: TextTypes

    // Estilos
    var textColor: Color = .primary
    var linkColor: Color = .blue
    var underlined: Bool = true

    // MARK: - Initialization

    init(fullText: String, links: [String: URL], textStyle: TextStyles, textColor: Color = .primary, linkColor: Color = .blue, underlined: Bool = true) {
        self.fullText = fullText
        self.links = links
        self.textStyle = textStyle
        self.textColor = textColor
        self.linkColor = linkColor
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
        let attributedString = createAttributedString()
        return Text(attributedString)
    }

    // MARK: - Methods

    private func createAttributedString() -> AttributedString {
        var attributedString = AttributedString(fullText)

        attributedString.font = getFont()
        attributedString.foregroundColor = textColor

        for (linkText, url) in links {
            if let range = attributedString.range(of: linkText, options: .caseInsensitive) {
                attributedString[range].link = url
                attributedString[range].foregroundColor = linkColor
                if underlined {
                    attributedString[range].underlineStyle = .single
                } else {
                    attributedString[range].underlineStyle = .none
                }
            }
        }

        return attributedString
    }
}

// MARK: - Preview

struct AtomLinkedTextView_Previews: PreviewProvider {
    static var previews: some View {
        let fullText = "Teste teste1 Teste2. Veja mais em Teste."
        let links: [String: URL] = [
            "Teste": URL(string: "https://www.google.com")!,
            "Teste2": URL(string: "https://www.example.com")!
        ]

        return VStack {
            AtomLinkedText(fullText: fullText, links: links, textStyle: .caption, textColor: .green, linkColor: .red, underlined: false)
                .padding()
            AtomLinkedText(fullText: fullText, links: links, textStyle: .body, textColor: .blue, linkColor: .orange, underlined: true)
                .padding()
        }
    }
}
