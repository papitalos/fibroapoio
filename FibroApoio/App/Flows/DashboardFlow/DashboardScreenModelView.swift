//
//  DashboardScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class DashboardScreenViewModel: ObservableObject {
    // MARK: - Enviroment Objects
    @Service var appCoordinator: AppCoordinatorService
    var cancellables = Set<AnyCancellable>()
}
