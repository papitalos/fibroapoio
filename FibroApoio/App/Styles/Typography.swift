//
//  Typography.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

import SwiftUI

// Estrutura para os Tamanhos de Fonte
struct FontSizes {
    let title: CGFloat = 32
    let headingLG: CGFloat = 24
    let heading: CGFloat = 20
    let headingSM: CGFloat = 16
    let subtitle: CGFloat = 14
    let bodyLG: CGFloat = 18
    let body: CGFloat = 16
    let bodySM: CGFloat = 14
    let caption: CGFloat = 12
    let quote: CGFloat = 16
    let mono: CGFloat = 16
    let emphasis: CGFloat = 16
}

// Estrutura para as Famílias de Fonte
struct FontFamilies {
    let helvetica: String = "Helvetica Neue"
    let monospaced: String = "Menlo"
}

// Estrutura para os Tipos de Texto
struct TextTypes {
    let title: Font
    let headingLG: Font
    let heading: Font
    let headingSM: Font
    let subtitle: Font
    let bodyLG: Font
    let body: Font
    let bodySM: Font
    let caption: Font
    let quote: Font
    let mono: Font
    let emphasis: Font

    init(fontSizes: FontSizes, fontFamilies: FontFamilies) {
        title = Font.custom(fontFamilies.helvetica, size: fontSizes.title)
            .weight(.bold)
        headingLG = Font.custom(
            fontFamilies.helvetica, size: fontSizes.headingLG
        ).weight(.semibold)
        heading = Font.custom(fontFamilies.helvetica, size: fontSizes.heading)
            .weight(.semibold)
        headingSM = Font.custom(
            fontFamilies.helvetica, size: fontSizes.headingSM
        ).weight(.semibold)
        subtitle = Font.custom(fontFamilies.helvetica, size: fontSizes.subtitle)
            .weight(.medium)
        bodyLG = Font.custom(fontFamilies.helvetica, size: fontSizes.bodyLG)
            .weight(.regular)
        body = Font.custom(fontFamilies.helvetica, size: fontSizes.body).weight(
            .regular)
        bodySM = Font.custom(fontFamilies.helvetica, size: fontSizes.bodySM)
            .weight(.regular)
        caption = Font.custom(fontFamilies.helvetica, size: fontSizes.caption)
            .weight(.light)

        // Estilos Especiais
        quote = Font.custom(fontFamilies.helvetica, size: fontSizes.quote)
            .italic()
        mono = Font.system(size: fontSizes.mono, design: .monospaced)
        emphasis = Font.custom(fontFamilies.helvetica, size: fontSizes.emphasis)
            .weight(.bold).italic()
    }
}

enum TextStyles {
    case title
    case headingLG
    case heading
    case headingSM
    case subtitle
    case bodyLG
    case body
    case bodySM
    case caption
    case quote
    case mono
    case emphasis
}
