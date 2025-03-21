//
//  FibroApoioApp.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

//Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct FibroApoioApp: App {
    //Firebase
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

    @StateObject var appCoordinator = AppCoordinator() // Instância do AppCoordinator
    @StateObject private var theme = Theme() // Instância do App Theme
    
    var body: some Scene {
        WindowGroup {  ContentView()
                .environmentObject(appCoordinator)
                .environmentObject(theme)
        }
    }
}
