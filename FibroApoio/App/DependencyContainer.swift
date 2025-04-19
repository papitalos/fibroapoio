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
        print("⚙️ APP STARTED")

        registerTheme()
        registerServices()
        registerViewModels()
        registerPages()
    }
    
    private func registerTheme() {
        print("registration of theme...")
        
        container.register(Theme.self) { _ in Theme() }.inObjectScope(.container)
    }

    private func registerServices() {
        print("registration of services...")

        container.register(FirebaseService.self) { _ in FirebaseService() }.inObjectScope(.container)
        container.register(AppCoordinatorService.self) { resolver in
            AppCoordinatorService(
                userService: resolver.resolve(UserService.self)!
            )
        }.inObjectScope(.container)
        container.register(LocalStorageService.self) { _ in LocalStorageService() }.inObjectScope(.container)
        
        container.register(UserService.self) { resolver in
            UserService(
                firebaseService: resolver.resolve(FirebaseService.self)!,
                localStorageService: resolver.resolve(LocalStorageService.self)!
            )
        }.inObjectScope(.container)
        
        container.register(AuthenticationService.self) { resolver in
            AuthenticationService(
                firebaseService: resolver.resolve(FirebaseService.self)!,
                userService: resolver.resolve(UserService.self)!,
                appCoordinatorService: resolver.resolve(AppCoordinatorService.self)!,
                localStorageService: resolver.resolve(LocalStorageService.self)!
            )
        }.inObjectScope(.container)
    }

    private func registerViewModels() {
        print("registration of view models...")

            container.register(SplashScreenViewModel.self) { _ in SplashScreenViewModel() }
            container.register(WelcomeScreenViewModel.self) { _ in WelcomeScreenViewModel() }
            container.register(RegisterScreenViewModel.self) { _ in RegisterScreenViewModel() }
            container.register(CompleteRegisterScreenViewModel.self) { _ in CompleteRegisterScreenViewModel() }
            container.register(LoginScreenViewModel.self) { _ in LoginScreenViewModel() }
            container.register(DashboardScreenViewModel.self) { _ in DashboardScreenViewModel() }
            container.register(HomeScreenViewModel.self) { _ in HomeScreenViewModel() }
            container.register(ProfileScreenViewModel.self) { _ in ProfileScreenViewModel() }
       }

       private func registerPages() {
           print("registration of pages...")

           container.register(SplashScreenView.self) { _ in SplashScreenView() }
           container.register(WelcomeScreenView.self) { _ in WelcomeScreenView() }
           container.register(RegisterScreenView.self) { _ in RegisterScreenView() }
           container.register(CompleteRegisterScreenView.self) { _ in CompleteRegisterScreenView() }
           container.register(SuccessRegistrationView.self) { _ in SuccessRegistrationView() }
           container.register(LoginScreenView.self) { _ in LoginScreenView() }
           container.register(DashboardScreenView.self) { _ in DashboardScreenView() }
           container.register(HomeScreenView.self) { _ in HomeScreenView() }
           container.register(ProfileScreenView.self) { _ in ProfileScreenView() }
       }

}
