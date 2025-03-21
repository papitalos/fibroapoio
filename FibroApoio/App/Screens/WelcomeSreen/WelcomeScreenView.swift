//
//  WelcomeScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

struct WelcomeScreenView: View {
    //MARK: - Properties
    @ObservedObject var viewModel: WelcomeScreenViewModel

    @EnvironmentObject var theme: Theme
    @EnvironmentObject var appCoordinator: AppCoordinator

    //MARK: - Body
    var body: some View {
        VStack {
            Image(viewModel.image)
                .resizable()
                .scaledToFit()
                .ignoresSafeArea()
            VStack {
                Text(viewModel.title)
                    .headingLG(theme)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, theme.spacing.sm)
                Text(viewModel.description)
                    .subtitle(theme)
                    .frame(maxWidth: .infinity, alignment: .leading)

            }.padding(
                EdgeInsets(
                    top: theme.spacing.md, leading: theme.spacing.xlg,
                    bottom: theme.spacing.md, trailing: theme.spacing.xlg))
            VStack {
                Button(action: viewModel.next) {
                    Image(systemName: "arrow.right")
                        .foregroundColor(theme.colors.contentPrimary)
                        .font(.title)
                        .padding()
                }
                .background(Circle().fill(theme.colors.brandSecondary))
                .frame(width: 100, height: 100, alignment: .trailing)
            }
            .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            .padding(.trailing, theme.spacing.xlg)
        }.frame(
            maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)

    }

    //MARK: - Inicializador
    init(viewModel: WelcomeScreenViewModel) {
        self.viewModel = viewModel
    }
}


//MARK: - Preview
struct WelcomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator()
        let viewModel = WelcomeScreenViewModel(appCoordinator: appCoordinator)
        return WelcomeScreenView(viewModel: viewModel)
            .environmentObject(Theme())
            .environmentObject(appCoordinator)
    }
}
