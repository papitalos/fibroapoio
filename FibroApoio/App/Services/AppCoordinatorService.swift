//
//  AppCoordinator.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import Combine
import SwiftUI

class AppCoordinatorService: ObservableObject {
    @Published var currentPage: Screen = .splash
    @Published var currentUser: Usuario?

    @ViewBuilder
    func getView(for screen: Screen) -> some View {
        switch screen {
        case .splash:
            SplashScreenView()
        case .welcome:
            WelcomeScreenView()
        case .register:
            RegisterScreenView()
        case .login:
            LoginScreenView()
        case .dashboard:
            DashboardScreenView()
        case .completeRegister:
            CompleteRegisterScreenView()
        }
        
    }

    func goToPage(_ screen: Screen) {
        currentPage = screen
        print("Indo para: \(currentPage)")

    }
}
