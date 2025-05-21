//
//  SuccessRegistrationView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/04/2025.
//

import SwiftUI

struct SuccessRegistrationView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var theme: Theme
    @Service var appCoordinator: AppCoordinatorService
    @Service var userService: UserService
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: theme.spacing.xlg) {
                Image("lootie-6")
                Spacer()
                VStack(spacing: theme.spacing.sm) {
                    Text("Bem vindo,\(userService.currentUser?.nome?.firstName ?? "usuário")")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.contentPrimary)
                    
                    Text("Vamos começar a cuidar de sua saúde!")
                        .font(.body)
                        .foregroundColor(theme.colors.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, theme.spacing.xlg)
                
                Spacer()
            
                // MARK: - Botão "Explorar"
                AtomButton(
                    action: {
                        self.appCoordinator.goToPage(.dashboard)
                    },
                    label: "Explorar",
                    icon: "arrow.right",
                    iconPosition: .trailing,
                    borderRadius: 125,
                    border: true,
                    backgroundColor: .blue,
                    textColor: .white
                ).padding(.horizontal, theme.spacing.xlg)

            }
        }
    }
    
}

// MARK: - Preview
struct SuccessRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        // Crie uma instância do DependencyContainer para o preview
        let container = DependencyContainer.shared.container
        
        // Retorne a view com as dependências configuradas
        return SuccessRegistrationView()
            .environmentObject(Theme())
            .environmentObject(container.resolve(AppCoordinatorService.self)!)
    }
}
