//
//  CompleteRegisterScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 09/04/2025.
//


import SwiftUI

struct CompleteRegisterScreenView: View {
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: CompleteRegisterScreenViewModel
    
    var body: some View {
        VStack {
            VStack {
                Text("Vamos completar o seu perfil")
                    .heading(theme)
                    .fontWeight(.bold)
                Text("Ajude-nos a saber um pouco mais sobre você")
                    .body(theme)
            }
            .padding(.top, theme.spacing.md)
            .padding(.horizontal, theme.spacing.xlg)
            Spacer()
            VStack(spacing: theme.spacing.md) {
                // Gênero
                Picker("Escolha seu gênero", selection: $viewModel.genero) {
                    Text("Masculino").tag("Masculino")
                    Text("Feminino").tag("Feminino")
                    Text("Outro").tag("Outro")
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // Data de Nascimento
                DatePicker("Data de nascimento", selection: $viewModel.dataNascimento, displayedComponents: .date)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                // Peso
                AtomNumberInput(
                    placeholder: "Seu peso",
                    icon: "scalemass",
                    iconPosition: .leading,
                    maxLength: 3,
                    text: $viewModel.peso
                )
                
                // Altura
                AtomNumberInput(
                    placeholder: "Sua altura",
                    icon: "ruler",
                    iconPosition: .leading,
                    maxLength: 3,
                    text: $viewModel.altura
                )
            }
            .padding(theme.spacing.xlg)
            Spacer()
            VStack {
                AtomButton(
                    action: {
                        viewModel.completeRegistration()
                    },
                    label: "Completar Registro",
                    icon: "arrow.right",
                    iconPosition: .trailing,
                    borderRadius: 125,
                    border: true,
                    backgroundColor: .blue,
                    textColor: .white
                )
                if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top, theme.spacing.sm)
                }
            }
            .padding(.horizontal, theme.spacing.xlg)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(CompleteRegisterScreenViewModel.self)!)
    }
}

// MARK: - Preview

struct CompleteRegisterScreenView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteRegisterScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
