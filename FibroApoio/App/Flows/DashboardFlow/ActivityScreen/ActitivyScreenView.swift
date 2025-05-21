//
//  ActivityView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//
import SwiftUI

struct ActivityScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: ActivityScreenViewModel
    @Service var appCoordinator: AppCoordinatorService

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.md) {
            Text("Atividades da semana")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(theme.colors.contentPrimary)

            ScrollView(.vertical, showsIndicators: false) {
                AtomList(items: viewModel.activityItems)
            }
        }
        .onAppear() {
            viewModel.load()
        }
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    // MARK: - Init
    init(viewModel: ActivityScreenViewModel? = nil){
        if(viewModel != nil) {
            _viewModel = StateObject(wrappedValue:viewModel!)
        }else{
            _viewModel = StateObject(wrappedValue:
                DependencyContainer.shared.container.resolve(ActivityScreenViewModel.self)!)
        }
    }
}

// MARK: - Preview
struct ActivityScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let mockViewModel = ActivityScreenViewModel()
        mockViewModel.activityItems = [
            AtomListItem(
                title: "Musculação",
                subtitle: "2h atrás",
                image: Image(systemName: "flame.fill"),
                tag: "500 pontos",
                tagBackgroundColor: .orange.opacity(0.2),
                tagTextColor: .orange,
                imageBackground: .orange.opacity(0.3),
                actions: [
                    (name: "Editar", action: { print("Editar selecionado") }),
                    (name: "Apagar", action: { print("Apagar selecionado") })
                ]
            ),
            AtomListItem(
                title: "Registro de dor",
                subtitle: "3h atrás",
                image: Image(systemName: "heart.fill"),
                tag: nil,
                tagBackgroundColor: nil,
                tagTextColor: nil,
                imageBackground: .pink.opacity(0.3),
                actions: [
                    (name: "Ver detalhes", action: { print("Detalhes selecionado") })
                ]
            ),
            AtomListItem(
                title: "Registro de medicamento",
                subtitle: "4h atrás",
                image: Image(systemName: "pills.fill"),
                tag: "Tomado",
                tagBackgroundColor: nil,
                tagTextColor: nil,
                imageBackground: .blue.opacity(0.2),
                actions: []
            )
        ]

        return ActivityScreenView(viewModel: mockViewModel)
            .environmentObject(Theme())
            .environmentObject(
                DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!
            )
    }
}
