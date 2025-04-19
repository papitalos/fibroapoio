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
    @Published var user: User?

    private var cancellables = Set<AnyCancellable>()
    private let userService: UserService

    init(userService: UserService){
        self.userService = userService
        print("- 🚪 PAGINA INICIAL CARREGADA: \(currentPage) -")
        
    }

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
        case .successRegistration:
            SuccessRegistrationView()
        }
        
    }

    func goToPage(_ screen: Screen) {
        print("\n- 🚪 MUDANDO DE PAGINA -\n \(currentPage) -> \(screen)")
        currentPage = screen
    }
    
    func loadUser(user: User?) {
        print("\n- 😃 USUARIO CARREGADO ABAIXO: -")
        print(user!)
        self.user = user
        
    }
    
    
}
