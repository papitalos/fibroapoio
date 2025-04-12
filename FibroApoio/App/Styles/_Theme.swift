//
//  _Theme.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 16/03/2025.
//

import SwiftUI

// Theme Observable
class Theme: ObservableObject {
    @Published var colors = Colors()
    @Published var fontSizes = FontSizes()
    @Published var fontFamilies = FontFamilies()
    @Published var spacing = Spacing()

    lazy var textTypes: TextTypes = {
        TextTypes(fontSizes: self.fontSizes, fontFamilies: self.fontFamilies)
    }()

}

// Extensions
extension Text {
    func title(_ theme: Theme) -> some View {
        self.font(theme.textTypes.title)
            .foregroundColor(theme.colors.contentPrimary)
    }

    func headingLG(_ theme: Theme) -> some View {
        self.font(theme.textTypes.headingLG)
            .foregroundColor(theme.colors.contentPrimary)
    }

    func heading(_ theme: Theme) -> some View {
        self.font(theme.textTypes.heading)
            .foregroundColor(theme.colors.contentPrimary)
    }

    func headingSM(_ theme: Theme) -> some View {
        self.font(theme.textTypes.headingSM)
            .foregroundColor(theme.colors.contentPrimary)
    }

    func subtitle(_ theme: Theme) -> some View {
        self.font(theme.textTypes.subtitle)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func bodyLG(_ theme: Theme) -> some View {
        self.font(theme.textTypes.bodyLG)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func body(_ theme: Theme) -> some View {
        self.font(theme.textTypes.body)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func bodySM(_ theme: Theme) -> some View {
        self.font(theme.textTypes.bodySM)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func caption(_ theme: Theme) -> some View {
        self.font(theme.textTypes.caption)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func quote(_ theme: Theme) -> some View {
        self.font(theme.textTypes.quote)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func mono(_ theme: Theme) -> some View {
        self.font(theme.textTypes.mono)
            .foregroundColor(theme.colors.contentSecondary)
    }

    func emphasis(_ theme: Theme) -> some View {
        self.font(theme.textTypes.emphasis)
            .foregroundColor(theme.colors.contentSecondary)
    }
}
