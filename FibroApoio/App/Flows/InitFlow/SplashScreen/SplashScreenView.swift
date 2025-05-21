//
//  SplashScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//
import SwiftUI

struct SplashScreenView: View {
    //MARK: - Theme & ViewModel
    @Service var theme: Theme
    @StateObject var viewModel: SplashScreenViewModel

    //MARK: - Animation
    @State private var angle: Double = 0

    //MARK: - Body
    var body: some View {
        VStack {
            Image("Logo")
                .resizable()
                .frame(width: 120, height: 120)
                .rotationEffect(.degrees(angle))
                .onAppear {
                    startInfiniteRotation()
                }

            Text("FibroApoio")
                .title(theme)
                .padding(.top, 12)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(theme.colors.surfaceGround)
    }

    //MARK: - Rotation
    func startInfiniteRotation() {
        withAnimation(Animation.linear(duration: 3).repeatForever(autoreverses: false)) {
            angle = 360
        }
    }

    //MARK: - Init
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
