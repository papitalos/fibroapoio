//
//  LoginScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI

struct LoginScreenView: View {
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var appCoordinator: AppCoordinator
    
    // MARK: - ViewModel
    @ObservedObject var viewModel: LoginScreenViewModel
    
    // MARK: - Properties
    @State var selection: AtomSelectButton.Selection = .left
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            VStack {
                Text("Olá boa tarde,").body(theme)
                Text("Entre na sua conta").heading(theme).fontWeight(.bold)
            }
            .frame(maxWidth: .infinity)
            .padding(.top, theme.spacing.md)
            .padding(.horizontal, theme.spacing.xlg)
            AtomSelectButton(selection: $selection,
            buttons: [
                ("Email", {}),
                ("Id", {}),
            ],
             buttonBackgroundColor: theme.colors.brandPrimary,
             buttonTextColor: theme.colors.contentInversed)
            Spacer()
            VStack(spacing: theme.spacing.md) {
                if selection == .right {
                    Text("⚠️ Essa funcionalidade não foi implementada").foregroundColor(.red).body(theme)
                    Text("É necessario ter funcionalidades premium no Firebase!").foregroundColor(.red).caption(theme)
                }
                // MARK: - AtomInputs
                ZStack{
                    if selection == .left {
                        AtomTextInput(
                            placeholder: "Email",
                            icon: "envelope",
                            iconPosition: .leading,
                            text: $viewModel.email
                        )
                    } else {
                        AtomTextInput(
                            placeholder: "Identificação",
                            icon: "person.text.rectangle",
                            iconPosition: .leading,
                            text: $viewModel.id
                        )
                    }
                }
                
                AtomTextInput(
                    placeholder: "Senha",
                    icon: "lock",
                    iconPosition: .leading,
                    password: true,
                    text: $viewModel.senha
                )
            }
            .padding(theme.spacing.xlg)
            Spacer()
            VStack {
                AtomButton(
                    action: {
                        viewModel.loginUser(by: (selection == .left) ? "email" : "id")
                    },
                    label: "Entrar",
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
                let actions: [String: () -> Void] = [
                    "Registrar": { appCoordinator.goToPage("register") }
                ]
                
                ActionableTextView(fullText: "Não possui uma conta? Registrar", actions: actions, textStyle: .body)
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
    init(viewModel: LoginScreenViewModel) {
        self.viewModel = viewModel
    }
}

// MARK: - Preview

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let appCoordinator = AppCoordinator()
        let viewModel = LoginScreenViewModel(appCoordinator: appCoordinator)
        return LoginScreenView(viewModel: viewModel)
            .environmentObject(Theme())
            .environmentObject(appCoordinator)
    }

}
