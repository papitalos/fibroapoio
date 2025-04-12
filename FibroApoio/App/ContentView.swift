//
//  ContentView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var appCoordinator: AppCoordinatorService
    @Service var theme: Theme
    let id = UUID()
    
    var body: some View {
        print("ContentView \(id) está sendo redesenhada.\nTela atual: \(appCoordinator.currentPage) \nCoordinator: \(ObjectIdentifier(appCoordinator))")
        return appCoordinator.getView(for: appCoordinator.currentPage)
    }
    
    init() {
        _appCoordinator = ObservedObject(wrappedValue: DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
