//
//  WelcomeScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

struct WelcomeScreenView: View {
    //MARK: - Properties
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: WelcomeScreenViewModel
    @Service var appCoordinator: AppCoordinatorService

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
    
    
    init() {
        _viewModel = StateObject(wrappedValue: DependencyContainer.shared.container.resolve(WelcomeScreenViewModel.self)!)
    }
}


//MARK: - Preview
struct WelcomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return WelcomeScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
