//
//  ProfileView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//
import SwiftUI

struct ProfileScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: ProfileScreenViewModel
    @State var notificationsEnabled = true
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService

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
                        Text("Italo Teofilo Filho")
                            .font(.headline)
                        Text("desde 22 set, 2022")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
                VStack(alignment: .center) {
                    Text("Madeira")
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
                        Text("10.500")
                            .font(.headline)
                    }
                }
                .padding(.horizontal)
            }.padding(.horizontal)

            HStack(spacing: 10) {
                VStack {
                    Text("173cm").font(.headline)
                    Text("Altura").font(.subheadline)
                        .foregroundColor(.gray)

                }.padding(24).background(Color(.systemGray6)).cornerRadius(16)
                Spacer()
                VStack {
                    Text("173cm").font(.headline)
                    Text("Altura").font(.subheadline)
                        .foregroundColor(.gray)

                }.padding(24).background(Color(.systemGray6)).cornerRadius(16)
                Spacer()
                VStack {
                    Text("173cm").font(.headline)
                    Text("Altura").font(.subheadline)
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
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Methods
    func logout() {
        authenticationService.logout()
            .sink(
                receiveCompletion: { completion in
                    switch completion {
                    case .finished:
                        print("Logout realizado com sucesso.")
                        appCoordinator.goToPage(.welcome)
                    case .failure(let error):
                        print("Erro ao realizar logout: \(error)")
                    }
                },
                receiveValue: { _ in
                }
            )
            .store(in: &viewModel.cancellables)
    }
    // MARK: - Init
    init() {
        _viewModel = StateObject(
            wrappedValue:
                DependencyContainer.shared.container.resolve(
                    ProfileScreenViewModel.self
                )!
        )
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
