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
        VStack(spacing: theme.spacing.lg) {
            Spacer()

            Text("O que deseja registrar?")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.bottom, theme.spacing.md)

            VStack(spacing: theme.spacing.md) {
                AtomButton(
                    action: { appCoordinator.goToPage(.addMedication) },
                    label: "Medicação",
                    borderRadius: 16,
                    border: true,
                    backgroundColor: .purple,
                    textColor: .white
                )

                AtomButton(
                    action: { appCoordinator.goToPage(.addFood) },
                    label: "Alimentação",
                    borderRadius: 16,
                    border: true,
                    backgroundColor: .green,
                    textColor: .white
                )

                AtomButton(
                    action: { appCoordinator.goToPage(.addActivity) },
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
        .padding(.top, theme.spacing.xlg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white.ignoresSafeArea())
    }
}
