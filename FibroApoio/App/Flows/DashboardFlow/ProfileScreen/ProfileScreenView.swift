//
//  ProfileView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//
import Combine
import SwiftUI

struct ProfileScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @Service var appCoordinator: AppCoordinatorService
    @Service var userService: UserService
    @Service var localStorageService: LocalStorageService
    @Service var authenticationService: AuthenticationService
    @Service var gamificationService: GamificationService
    
    @State private var cancellables = Set<AnyCancellable>()
    
    @State private var rankName = "—"
    @State private var ageNumber = "0"

    var body: some View {
        VStack(spacing: 20) {
            Text("Perfil")
                .font(.title)
                .bold()

            HStack {
                // Avatar e informações
                HStack(spacing: 15) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 60, height: 60)
                        .padding(16)
                        .background(
                            Circle().fill(Color(.systemGroupedBackground))
                        )

                    VStack(alignment: .leading, spacing: 5) {
                        Text(userService.currentUser?.nome?.firstName ?? "Usuário")
                            .font(.headline)
                        if let createdAt = userService.currentUser?.createdAt {
                            let formattedDate = createdAt.toFormattedDateString()
                            Text(formattedDate)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    Text(rankName.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.brown.opacity(0.2))
                        .foregroundColor(.brown)
                        .cornerRadius(8)
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundColor(.yellow)
                            .font(.footnote)
                        Text(String(userService.currentUser?.pontuacao ?? 0))
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
            }.padding(.horizontal)

            HStack(spacing: 4) {
                let altura = userService.currentUser?.altura_cm ?? 0
                let peso = userService.currentUser?.peso_kg ?? 0
                
                VStack {
                    Text("\(altura) cm").subtitle(self.theme).bold()
                        .foregroundColor(theme.colors.brandPrimary)
                    Text("Altura").font(.subheadline)
                        .foregroundColor(.gray)

                }.padding(24).background(Color(.systemGray6)).cornerRadius(16)
                Spacer()
                VStack {
                    Text("\(peso) kg").subtitle(self.theme).bold()
                        .foregroundColor(theme.colors.brandPrimary)
                    Text("Peso").font(.subheadline)
                        .foregroundColor(.gray)

                }.padding(24).background(Color(.systemGray6)).cornerRadius(16)
                Spacer()
                VStack {
                    Text(ageNumber).subtitle(self.theme).bold() .foregroundColor(theme.colors.brandPrimary)
                    Text("Idade").font(.subheadline)
                        .foregroundColor(.gray)

                }.padding(24).background(Color(.systemGray6)).cornerRadius(16)

            }.padding(.horizontal)
            Spacer()
            AtomActionableText(
                fullText: "Sair do App",
                actions: [
                    "Sair do app":
                        { self.logout() }
                ],
                textStyle: .bodySM,
                actionableTextColor: .contentSecondary,
                underlined: false
            ).padding(16).frame(maxWidth: .infinity, alignment: .trailing)
        }
        .onAppear {
            gamificationService.fetchCurrentRank { rank in
                rankName = rank?.getName() ?? "Nenhum"
            }
            
            userService.calculateCurrentUserAge { age in
                ageNumber = String(age!)
            }

        }
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Methods
    func logout() {
        authenticationService.logout()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        if self.localStorageService.hasSeenWelcomeScreen() {
                            self.appCoordinator.goToPage(.login)
                        } else {
                            self.appCoordinator.goToPage(.welcome)
                        }
                    case .failure(let error):
                        print("‼️ ERROR: Problema ao realizar logout \(error)")
                    }
                },
                receiveValue: { _ in }
            )
            .store(in: &cancellables)
    }

}

// MARK: - Preview

struct ProfileScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return ProfileScreenView()
            .environmentObject(Theme())
            .environmentObject(
                DependencyContainer.shared.container.resolve(
                    AppCoordinatorService.self
                )!
            )
    }
}
