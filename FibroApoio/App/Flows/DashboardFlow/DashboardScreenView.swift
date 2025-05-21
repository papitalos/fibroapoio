import SwiftUI

struct DashboardScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService

    // MARK: - Properties
    @State private var showCheckinDialog = false
    @State private var showPromoteDialog = false
    @State private var showDemoteDialog = false

    @State var duration = 2.0
    @State var initSize = 1.1
    @State var angle = 0.00
    @State var opacity = 1.0

    @State var selectedTab = 0

    var body: some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                switch selectedTab {
                case 0:
                    HomeScreenView(
                        selectedTab: $selectedTab,
                        showCheckinDialog: $showCheckinDialog,
                        showPromoteDialog: $showPromoteDialog,
                        showDemoteDialog: $showDemoteDialog
                    )
                case 1:
                    RankScreenView()
                case 2:
                    AddEntryScreenView()
                case 3:
                    ActivityScreenView()
                case 4:
                    ProfileScreenView()
                default:
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            AtomTabBarView(selectedTab: $selectedTab)
                .padding(.bottom, 8)
                .background(Color.white.shadow(radius: 5))
        }
        .frame(maxHeight: .infinity)
        .edgesIgnoringSafeArea(.bottom)
        .overlay(dialogs)
    }

    // MARK: - Dialogs ViewBuilder
    @ViewBuilder
    private var dialogs: some View {
        if showCheckinDialog {
            DialogPanel(
                isPresented: $showCheckinDialog,
                windowName: "Registro de dores",
                title: "Está sentindo alguma dor?",
                description: "Dores musculares, dores de cabeça, dor nos ossos, alguma coisa?",
                rightButton: (
                    label: "Sim, sinto dores",
                    action: { appCoordinator.goToPage(.painEntry) }
                ),
                leftButton: (
                    label: "Não sinto dor",
                    action: {
                        // TODO: - Salvar que não sente dor hoje
                    }
                )
            
            )
        }

        if showPromoteDialog {
            DialogPanel(
                isPresented: $showPromoteDialog,
                windowName: "Promoção de rank",
                title: "Parabéns!",
                description: "Você foi promovido para o próximo rank!", 
                rightButton: (
                    label: "Continuar",
                    action: {}
                )
            )
        }

        if showDemoteDialog {
            DialogPanel(
                isPresented: $showDemoteDialog,
                windowName: "Rebaixamento de rank",
                title: "Sinto muito!",
                description: "Você foi rebaixado para o rank abaixo!",
                rightButton: (
                    label: "Continuar",
                    action: {}
                )
            )
        }
    }
}

// MARK: - Preview
struct DashboardScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardScreenView()
            .environmentObject(Theme())
    }
}
