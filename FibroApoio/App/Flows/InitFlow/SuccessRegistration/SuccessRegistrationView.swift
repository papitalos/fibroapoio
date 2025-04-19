import SwiftUI

struct SuccessRegistrationView: View {
    // MARK: - Environment Objects
    @EnvironmentObject var theme: Theme
    @Service var appCoordinator: AppCoordinatorService
    
    // MARK: - Properties
    var userName: String // Nome do usuário passado como parâmetro
    
    // MARK: - Body
    var body: some View {
        ZStack {
            // Fundo com cor clara
            theme.colors.background
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: theme.spacing.xlg) {
                // MARK: - Título no topo
                Text("Success Registration")
                    .font(.caption)
                    .foregroundColor(theme.colors.contentSecondary)
                    .padding(.top, theme.spacing.xlg)
                
                Spacer()
                
                // MARK: - Ilustração
                Image("success_registration") // Substitua por um asset correspondente
                    .resizable()
                    .scaledToFit()
                
                Spacer()
                
                // MARK: - Texto de boas-vindas
                VStack(spacing: theme.spacing.sm) {
                    Text("Bem vindo, $$userName)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(theme.colors.contentPrimary)
                    
                    Text("Vamos começar a cuidar de sua saúde!")
                        .font(.body)
                        .foregroundColor(theme.colors.contentSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, theme.spacing.lg)
                
                Spacer()
                
                // MARK: - Botão "Explorar"
                Button(action: {
                    appCoordinator.goToPage(.dashboard)
                }, label: {
                    Text("Explorar")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(theme.spacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.blue)
                                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 4)
                        )
                })
                .padding(.horizontal, theme.spacing.xlg)
                .padding(.bottom, theme.spacing.lg)
            }
        }
    }
}