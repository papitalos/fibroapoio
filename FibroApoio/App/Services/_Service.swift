//
//  ServiceWrapper.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import Swinject
import SwiftUI

@propertyWrapper
struct Service<T> {
    let wrappedValue: T

    init() {
        self.wrappedValue = DependencyContainer.shared.container.resolve(T.self)!
    }
}

struct ServiceInjector: ViewModifier {
    let theme: Theme

    func body(content: Content) -> some View {
        content
            .environmentObject(theme)
    }

    init(theme: Theme) {
        self.theme = theme
    }
}

extension View {
    func injectServices(theme: Theme) -> some View {
        modifier(ServiceInjector(theme: theme))
    }
}
