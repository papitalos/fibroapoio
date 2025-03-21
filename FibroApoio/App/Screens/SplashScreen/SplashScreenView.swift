//
//  SplashScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

struct SplashScreenView: View {
    //MARK: - Properties
    @EnvironmentObject var theme: Theme
    @ObservedObject var viewModel: SplashScreenViewModel

    //Estado para animações
    @State var duration = 2.0
    @State var angle = 0.00
    @State var opacity = 1.0

    //MARK: - Body
    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .scaleEffect(1.2)
                    .rotationEffect(Angle(degrees: angle))
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: duration)) {
                            self.angle = 45.00
                            self.opacity = 0.0
                        }
                    }
            }
            VStack {
                Text("FibroApoio")
                    .title(theme)
                    .scaleEffect(1.2)
                    .opacity(opacity)
            }.onAppear {
                withAnimation(.easeIn(duration: duration)) {
                    self.opacity = 0.0
                }
            }
        }
        .onAppear {
        }
    }
    
    //MARK: - Inicializador
    init(viewModel: SplashScreenViewModel) {
        self.viewModel = viewModel
    }
}

//MARK: - Preview
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator()
        let viewModel = SplashScreenViewModel(appCoordinator: appCoordinator)
        SplashScreenView(viewModel: viewModel)
            .environmentObject(Theme())
    }
}
