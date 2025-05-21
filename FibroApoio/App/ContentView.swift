//
//  ContentView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

var isPreview: Bool {
    ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}

struct ContentView: View {
    @ObservedObject var appCoordinator: AppCoordinatorService
    @Service var theme: Theme
    let id = UUID()
    
    var body: some View {
        print("- 🔁 DESENHANDO -\n viewID:\(id)")
        return appCoordinator.getView(for: appCoordinator.currentPage)
    }
    
    init() {
        _appCoordinator = ObservedObject(wrappedValue: DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
