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
    private var cancellables = Set<AnyCancellable>()

    init(){
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
        case .painEntry:
            PainEntryScreenView()
        case .medicationEntry:
            MedicationEntryScreenView()
        case .addEntry:
            AddEntryScreenView()
        case .exerciseEntry:
            ExerciseEntryScreenView()
        }

    }

    func goToPage(_ screen: Screen) {
        print("\n- 🚪 MUDANDO DE PAGINA -\n \(currentPage) -> \(screen)")
        currentPage = screen
    }
    
}
