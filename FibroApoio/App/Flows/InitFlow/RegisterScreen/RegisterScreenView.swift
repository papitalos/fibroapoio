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
    @Service var localStorageService: LocalStorageService
    
    // MARK: - Properties
    
    let privacyPolicyURL = URL(string: "https://docs.google.com/document/d/1Tdk9gpcK8xgYfK6HYzMvVKMZmxqn4Vh6mTZgT99PfrY/edit?tab=t.cja9ocxhtozz")!
    let termsOfUseURL = URL(string: "https://docs.google.com/document/d/1Tdk9gpcK8xgYfK6HYzMvVKMZmxqn4Vh6mTZgT99PfrY/edit?tab=t.0")!
    
    enum Field: Int, Hashable {
        case name, identification, phone, email, password
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
                        text: $viewModel.name,
                        onSubmit: { focusedField = .identification }
                    )
                    .focused($focusedField, equals: .name)
                    
                    AtomNumberInput(
                        placeholder: "Identificação",
                        icon: "person.text.rectangle",
                        iconPosition: .leading,
                        maxLength: 9,
                        text: $viewModel.identification,
                        onSubmit: { focusedField = .phone }
                    )
                    .focused($focusedField, equals: .identification)

                    AtomNumberInput(
                        placeholder: "Número de telemóvel",
                        icon: "phone",
                        iconPosition: .leading,
                        mask: "XXX XXX XXX",
                        maxLength: 11,
                        text: $viewModel.number,
                        onSubmit: { focusedField = .email }
                    )
                    .focused($focusedField, equals: .phone)

                    AtomTextInput(
                        placeholder: "Email",
                        icon: "envelope",
                        iconPosition: .leading,
                        maxLength: 40,
                        text: $viewModel.email,
                        onSubmit: { focusedField = .password }
                    )
                    .focused($focusedField, equals: .email)

                    AtomTextInput(
                        placeholder: "Senha",
                        icon: "lock",
                        iconPosition: .leading,
                        password: true,
                        maxLength: 20,
                        text: $viewModel.senha,
                        onSubmit: { viewModel.registerUser() }
                    )
                    .focused($focusedField, equals: .password)

                    
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
            
            // MARK: - Botão de Voltar
            VStack {
                HStack {
                    Button(action: {
                        // Resetar o estado de visualização da tela de boas-vindas
                        localStorageService.resetWelcomeScreenState()
                        // Voltar para a tela de boas-vindas
                        appCoordinator.goToPage(.welcome)
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "arrow.left")
                                .foregroundColor(theme.colors.contentPrimary)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    .padding(.top, theme.spacing.md)
                    .padding(.leading, theme.spacing.md)
                    
                    Spacer()
                }
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
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
