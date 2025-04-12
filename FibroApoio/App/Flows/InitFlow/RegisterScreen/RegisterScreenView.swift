//
//  RegisterScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/03/2025.
//

import SwiftUI

struct RegisterScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: RegisterScreenViewModel
    @Service var appCoordinator: AppCoordinatorService
    
    // MARK: - Properties
    
    let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1Tdk9gpcK8xgYfK6HYzMvVKMZmxqn4Vh6mTZgT99PfrY/edit?tab=t.cja9ocxhtozz")!
    let termsOfUseURL = URL(string: "https://docs.google.com/document/d/1Tdk9gpcK8xgYfK6HYzMvVKMZmxqn4Vh6mTZgT99PfrY/edit?tab=t.0")!
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack {
                Text("Olá boa tarde,").body(theme)
                Text("Crie sua conta").heading(theme).fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, theme.spacing.md)
            .padding(.horizontal, theme.spacing.xlg)
            Spacer()
            VStack(spacing: theme.spacing.md) {
                // MARK: - AtomInputs
                AtomTextInput(
                    placeholder: "Nome Completo",
                    icon: "person",
                    iconPosition: .leading,
                    maxLength: 70,
                    text: $viewModel.name
                )
                AtomNumberInput(
                    placeholder: "Identificação",
                    icon: "person.text.rectangle",
                    iconPosition: .leading,
                    maxLength: 9,
                    text: $viewModel.identification
                )
                AtomNumberInput(
                    placeholder: "Número de telemóvel",
                    icon: "phone",
                    iconPosition: .leading,
                    mask: "XXX XXX XXX",
                    maxLength: 11,
                    text: $viewModel.number
                )
                AtomTextInput(
                    placeholder: "Email",
                    icon: "envelope",
                    iconPosition: .leading,
                    maxLength: 40,
                    text: $viewModel.email
                )
                AtomTextInput(
                    placeholder: "Senha",
                    icon: "lock",
                    iconPosition: .leading,
                    password: true,
                    maxLength: 20,
                    text: $viewModel.senha
                )
                
                // MARK: - LinkedText
                
                let fullText = "Ao continuar você aceita nossa Política de Privacidade e Termos de uso"
                let links: [String: URL] = [
                    "Política de Privacidade": privacyPolicyURL,
                    "Termos de uso": termsOfUseURL
                ]
                
                AtomLinkedText(fullText: fullText, links: links, textStyle: .caption)
                    .foregroundColor(theme.colors.contentSecondary)
                    .multilineTextAlignment(.center)
                    .frame(width: 230)
            }
            .padding(theme.spacing.xlg)
            Spacer()
            VStack {
                AtomButton(
                    action: {
                        viewModel.registerUser()
                    },
                    label: "Próximo",
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
            
            // MARK: - ActionableText
            
            HStack {
                Text("Já possui uma conta?")
                
                let enterText = "Entrar"
                let actions: [String: () -> Void] = [
                    enterText: { appCoordinator.goToPage(.login) }
                ]
                
                AtomActionableText(fullText: enterText, actions: actions, textStyle: .body)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, theme.spacing.xlg)
            .padding(.bottom, theme.spacing.md)
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(RegisterScreenViewModel.self)!)
    }
}

// MARK: - Preview

struct RegisterScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return RegisterScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
