//
//  AddEntryScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import SwiftUI

struct AddEntryScreenView: View {
    // MARK: - Environment & Services
    @EnvironmentObject var theme: Theme
    @Service var appCoordinator: AppCoordinatorService

    var body: some View {
        ZStack {
            Color.white
                .ignoresSafeArea()

            VStack {
                // MARK: - Header
                Text("O que deseja registrar?").heading(theme)
                .fontWeight(.bold)
                .padding(.top, theme.spacing.xlg)
                .padding(.horizontal, theme.spacing.xlg)
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer()

                // MARK: - Options
                VStack(spacing: theme.spacing.md) {
                    AtomButton(
                        action: { appCoordinator.goToPage(.medicationEntry) },
                        label: "Medicação",
                        borderRadius: 16,
                        border: true,
                        backgroundColor: theme.colors.brandSecondary,
                        textColor: .white
                    )
                    AtomButton(
                        action: { appCoordinator.goToPage(.painEntry) },
                        label: "Dores",
                        borderRadius: 16,
                        border: true,
                        backgroundColor: .green,
                        textColor: .white
                    )
                    AtomButton(
                        action: { appCoordinator.goToPage(.exerciseEntry) },
                        label: "Atividade Física",
                        borderRadius: 16,
                        border: true,
                        backgroundColor: .blue,
                        textColor: .white
                    )
                }
                .padding(.horizontal, theme.spacing.xlg)

                Spacer()
            }
        }
    }
}

struct AddEntryScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AddEntryScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
