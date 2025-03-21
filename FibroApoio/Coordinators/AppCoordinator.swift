//
//  AppCoordinator.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import Combine
// AppCoordinator.swift
import SwiftUI

class AppCoordinator: ObservableObject {
    @Published var currentPage: String = "splash"

    init() { /*TODO: Inicialização do estado aplicação*/  }

    func goToPage(_ pageName: String) {
        currentPage = pageName
    }
}
