//
//  DependencyContainer.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import Swinject
import SwiftUI

class DependencyContainer {
    static let shared = DependencyContainer()
    let container = Container()

    private init() {
        registerServices()
        registerViewModels()
        registerPages()
    }

    private func registerServices() {
        container.register(FirebaseService.self) { _ in FirebaseService.shared }
        container.register(UserService.self) { resolver in
            UserService(firebaseService: resolver.resolve(FirebaseService.self)!)
        }
        container.register(AuthenticationService.self) { _ in AuthenticationService() }
        container.register(AppCoordinatorService.self) { _ in AppCoordinatorService() }
    }

    private func registerViewModels() {
        container.register(SplashScreenViewModel.self) { resolver in
            SplashScreenViewModel(
                appCoordinator: resolver.resolve(AppCoordinatorService.self)!,
                userService: resolver.resolve(UserService.self)!,
                authenticationService: resolver.resolve(AuthenticationService.self)!
            )
        }
    }

    private func registerPages() {
        container.register(SplashScreenView.self) { _ in SplashScreenView() }
        container.register(WelcomeScreenView.self) { _ in WelcomeScreenView() }
        container.register(RegisterScreenView.self) { _ in RegisterScreenView() }
        container.register(LoginScreenView.self) { _ in LoginScreenView() }
        container.register(DashboardScreenView.self) { _ in DashboardScreenView() }
    }

    func resolvePage(pageName: String) -> AnyView? {
        switch pageName {
        case "splash":
            return AnyView(container.resolve(SplashScreenView.self)!)
        case "welcome":
            return AnyView(container.resolve(WelcomeScreenView.self)!)
        case "register":
            return AnyView(container.resolve(RegisterScreenView.self)!)
        case "login":
            return AnyView(container.resolve(LoginScreenView.self)!)
        case "dashboard":
            return AnyView(container.resolve(DashboardScreenView.self)!)
        default:
            return nil
        }
    }
}
