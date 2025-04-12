//
//  FibroApoioApp.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import FirebaseAuth
import FirebaseCore
import FirebaseFirestore
import SwiftUI
import Swinject

//Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication
            .LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        FirebaseApp.configure()

        return true
    }
}

@main
struct FibroApoioApp: App {
    //Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    public let dependencyContainer = DependencyContainer.shared
    
    var body: some Scene {
        let theme: Theme = DependencyContainer.shared.container.resolve(Theme.self)!
        
        return WindowGroup {
            ContentView()
                .injectServices(theme: theme)
        }
    }
}
