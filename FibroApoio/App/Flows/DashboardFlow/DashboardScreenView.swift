import SwiftUI

struct DashboardScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel : DashboardScreenViewModel
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService
    
    // MARK: - Properties
    @State var duration = 2.0
    @State var initSize = 1.1
    @State var angle = 0.00
    @State var opacity = 1.0

    @State private var selectedTab = 0

    var body: some View {
            VStack(spacing: 0) {
                // Conteúdo das telas
                switch selectedTab {
                case 0:
                    HomeScreenView()
                case 1:
                    HomeScreenView()
                case 2:
                    HomeScreenView()
                case 3:
                    HomeScreenView()
                case 4:
                    ProfileScreenView()
                default:
                    EmptyView()
                }

                // TabBar Customizada
                AtomTabBarView(selectedTab: $selectedTab)
            }
            .edgesIgnoringSafeArea(.bottom)
        }
    
    
    init() {
        _viewModel = StateObject(wrappedValue: DependencyContainer.shared.container.resolve(DashboardScreenViewModel.self)!)
    }
}

//MARK: - Preview
struct DashboardScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
