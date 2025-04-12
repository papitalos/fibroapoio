//
//  HomeScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 08/04/2025.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import Combine

class HomeScreenViewModel: ObservableObject {
    // MARK: - Enviroment Objects
    @Service var appCoordinator: AppCoordinatorService
    var cancellables = Set<AnyCancellable>()    
}
