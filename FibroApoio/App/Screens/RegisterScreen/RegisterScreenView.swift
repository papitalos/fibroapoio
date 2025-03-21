//
//  RegisterScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/03/2025.
//

import SwiftUI

struct RegisterScreenView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    // MARK: - ViewModel
    @ObservedObject var viewModel: RegisterScreenViewModel

    // MARK: - Properties
    
    let privacyPolicyURL = URL(string: "https://www.example.com/privacy")!
    let termsOfUseURL = URL(string: "https://www.example.com/terms")!
    
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
                    text: $viewModel.name
                )
                AtomTextInput(
                    placeholder: "Identificação",
                    icon: "person.text.rectangle",
                    iconPosition: .leading,
                    text: $viewModel.id
                )
                AtomTextInput(
                    placeholder: "Número de telemóvel",
                    icon: "phone",
                    iconPosition: .leading,
                    text: $viewModel.number
                )
                AtomTextInput(
                    placeholder: "Email",
                    icon: "envelope",
                    iconPosition: .leading,
                    text: $viewModel.email
                )
                AtomTextInput(
                    placeholder: "Senha",
                    icon: "lock",
                    iconPosition: .leading,
                    password: true,
                    text: $viewModel.senha
                )
                
                // MARK: - LinkedText
                
                let fullText = "Ao continuar você aceita nossa Política de Privacidade e Termos de uso"
                let links: [String: URL] = [
                    "Política de Privacidade": privacyPolicyURL,
                    "Termos de uso": termsOfUseURL
                ]
                
                LinkedTextView(fullText: fullText, links: links, textStyle: .caption)
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
                    enterText: { appCoordinator.goToPage("login") }
                ]
                
                ActionableTextView(fullText: enterText, actions: actions, textStyle: .body)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal, theme.spacing.xlg)
            .padding(.bottom, theme.spacing.md)
            .frame(maxWidth: .infinity)
        }
        .ignoresSafeArea(.keyboard)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    //MARK: - Inicializador
    init(viewModel: RegisterScreenViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Preview

struct RegisterScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator()
        let viewModel = RegisterScreenViewModel(appCoordinator: appCoordinator)
        return RegisterScreenView(viewModel: viewModel)
            .environmentObject(Theme())
            .environmentObject(appCoordinator)
    }
}
