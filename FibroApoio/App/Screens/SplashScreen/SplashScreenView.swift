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
    @EnvironmentObject var appCoordinator: AppCoordinator

    //Estado para animações
    @State var duration = 2.0
    @State var initSize = 1.1
    @State var angle = 0.00
    @State var opacity = 1.0

    //MARK: - Body
    var body: some View {
        VStack {
            VStack {
                Image("Logo")
                    .scaleEffect(initSize)
                    .rotationEffect(Angle(degrees: angle))
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: duration)) {
                            self.initSize = 1.7
                            self.angle = 45.00
                            self.opacity = 0.0
                        }
                    }
            }
            VStack {
                Text("FibroApoio")
                    .title(theme)
                    .scaleEffect(initSize)
                    .opacity(opacity)
            }.onAppear {
                withAnimation(.easeIn(duration: duration)) {
                    self.initSize = theme.fontSizes.title
                    self.opacity = 0.0
                }
            }
        }
        .onAppear {
            // Navega para a WelcomeScreen na aplicação normal
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                appCoordinator.goToPage("welcome")  // Navega para a WelcomeScreen
            }
        }
    }
}
//MARK: - Preview
struct SplashScreenView_Previews: PreviewProvider {
    static var previews: some View {
        SplashScreenView()
            .environmentObject(Theme())
            .environmentObject(AppCoordinator())
    }
}
