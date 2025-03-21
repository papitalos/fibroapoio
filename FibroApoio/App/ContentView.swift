//
//  ContentView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

// ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appCoordinator: AppCoordinator

    var body: some View {
        Group {
            switch appCoordinator.currentPage {
            case "splash":
                SplashScreenView()
            case "welcome":
                WelcomeScreenView(viewModel: WelcomeScreenViewModel(appCoordinator: appCoordinator))
            case "register":
                RegisterScreenView(viewModel: RegisterScreenViewModel(appCoordinator: appCoordinator))
            case "login":
                LoginScreenView(viewModel: LoginScreenViewModel(appCoordinator: appCoordinator))
            case "dashboard":
                DashboardScreenView()
            default:
                Text("Pagina não encontrada")
            }
        }
        .environmentObject(appCoordinator)
    }
}
