//
//  LoginScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 20/03/2025.
//

import SwiftUI

struct LoginScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: LoginScreenViewModel
    @Service var appCoordinator: AppCoordinatorService
    
    // MARK: - Properties
    @State var selection: AtomSelectButton.Selection = .left
    
    enum Field: Int, Hashable {
        case identification, email, password
    }
    @FocusState private var focusedField: Field?

    
    // MARK: - Body
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
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
                    ZStack{
                        if selection == .left {
                            AtomTextInput(
                                placeholder: "Email",
                                icon: "envelope",
                                iconPosition: .leading,
                                text: $viewModel.email,
                                onSubmit: { focusedField = .password }
                            )
                            .focused($focusedField, equals: .email)

                        } else {
                            AtomTextInput(
                                placeholder: "Identificação",
                                icon: "person.text.rectangle",
                                iconPosition: .leading,
                                text: $viewModel.id,
                                onSubmit: { focusedField = .password }
                            )
                            .focused($focusedField, equals: .identification)

                        }
                    }
                    
                    AtomTextInput(
                        placeholder: "Senha",
                        icon: "lock",
                        iconPosition: .leading,
                        password: true,
                        text: $viewModel.senha,
                        onSubmit: {  viewModel.loginUser(by: (selection == .left) ? "email" : "id") }
                    )
                    .focused($focusedField, equals: .password)

                    
                    let gmailLink = URL(string: "https://workspace.google.com/intl/pt-PT/gmail/")!
                    AtomLinkedText(
                        fullText: "Esqueceu sua senha? Clique aqui",
                        links: ["Clique aqui" : gmailLink],
                        textStyle: .caption
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
                        "Registrar": { appCoordinator.goToPage(.register) }
                    ]
                    
                    AtomActionableText(fullText: "Não possui uma conta? Registrar", actions: actions, textStyle: .body)
                        .foregroundColor(.blue)
                }
                .padding(.horizontal, theme.spacing.xlg)
                .padding(.bottom, theme.spacing.md)
                .frame(maxWidth: .infinity)
            }
            .ignoresSafeArea(.keyboard)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
      
    }
    
    //MARK: - Init
    init(){
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(LoginScreenViewModel.self)!)
    }
}

// MARK: - Preview

struct LoginScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return LoginScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }

}
