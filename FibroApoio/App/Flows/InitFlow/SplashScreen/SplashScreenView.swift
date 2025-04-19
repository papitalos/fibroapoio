//
//  SplashScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//
// SplashScreenView.swift
import SwiftUI

struct SplashScreenView: View {
    //MARK: - Properties
    @Service var theme: Theme
    @StateObject var viewModel: SplashScreenViewModel
    @Service var appCoordinator: AppCoordinatorService

    //Estado para animações
    @State var duration = 2.0
    @State private var angle = 0.0
    @State private var opacity = 1.0

    //MARK: - Body
    var body: some View {
        VStack {
            Image("Logo")
                .scaleEffect(1.2)
                .rotationEffect(Angle(degrees: angle))
                .opacity(opacity)
                .onAppear {
                    startRotationAnimation()
                }
            Text("FibroApoio")
                .title(theme)
                .scaleEffect(1.2)
                .opacity(opacity)
        }
        .opacity(opacity)        
    }

    //MARK: - Methods
    func startRotationAnimation() {
        withAnimation(
            .easeIn(duration: 1.0)
                .repeatForever(autoreverses: false)
        ) {
            self.angle = 360.0
        }
    }
    
    init() {
        _viewModel = StateObject(wrappedValue: DependencyContainer.shared.container.resolve(SplashScreenViewModel.self)!)
    }
}

//MARK: - Preview
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
