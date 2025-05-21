//
//  HomeView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//

import Combine
import SwiftUI

struct HomeScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: HomeScreenViewModel
    @State private var rankName = "—"
    @Binding var showCheckinDialog: Bool
    @Binding var showPromoteDialog: Bool
    @Binding var showDemoteDialog: Bool

    @State private var cancellables = Set<AnyCancellable>()
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService
    @Service var userService: UserService
    @Service var gamificationService: GamificationService
    private var _selectedTab: Binding<Int>?

    
    // MARK: - Computed Properties
    private var greeting: String {
       let hour = Calendar.current.component(.hour, from: Date())
       
       switch hour {
           case 5..<12:
               return "Bom dia,"
           case 12..<18:
               return "Boa tarde,"
           default:
               return "Boa noite,"
           }
        }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            ScrollView(.vertical, showsIndicators: false) {
                // Saudação e Energia
                HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text(greeting)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                            Text(userService.currentUser?.nome?.firstName ?? "Usuário")
                                .font(.title)
                                .fontWeight(.bold)
                        }
                    Spacer()
                    //TODO: - Display do rank e dos pontos corretamente
                    HStack {
                        VStack {
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
                    }
                }

                // Calendário
                StreakCalendar(
                    primaryColor: .brandPrimary,
                    secondaryColor: .brandSecondary,
                    streakData: viewModel.cachedStreakData)
                .padding(.bottom)

                // Objetivo do dia e botão de check-in
                if(!viewModel.checkedInToday){
                    HStack {
                        Text("Objetivo do dia ⚠️")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                        Button(action: { showCheckinDialog = true } ) {
                            Text("Check-in Diário")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 8)
                                .background(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                                .cornerRadius(15)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                }
               
                
                GraphView(
                    data: viewModel.cachedActivityLevels,
                    primaryColor: .purple,
                    secondaryColor: .blue,
                    backgroundColor: Color.gray.opacity(0.1)
                )


                VStack(alignment: .leading) {
                    HStack {
                        Text("Atividades da semana")
                            .font(.headline)
                        Spacer()
                        Button(action: {  _selectedTab?.wrappedValue = 3
                        }) {
                            Text("Ver mais")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }

                    AtomList(items: viewModel.recentActivityItems)
                }
            }.scrollDisabled(true)
        }
        .onAppear {
            viewModel.load()

            let rankId = userService.currentUser?.id_rank?.documentID ?? ""
            rankName = self.gamificationService.getRankNameById(rankId)
            
            if(viewModel.rankActivity == "promote"){
                self.showPromoteDialog = true
            }
            if (viewModel.rankActivity == "demote"){
                self.showDemoteDialog = true
            }
        }
        .padding(EdgeInsets(top: 32, leading: 16, bottom: 32, trailing: 16))
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    //MARK: - Init
    init(viewModel: HomeScreenViewModel? = nil, selectedTab: Binding<Int>? = nil, showCheckinDialog: Binding<Bool>? = nil, showPromoteDialog: Binding<Bool>? = nil, showDemoteDialog: Binding<Bool>? = nil){
        
        
        if (showCheckinDialog != nil && showPromoteDialog != nil && showDemoteDialog != nil){
            self._showCheckinDialog = showCheckinDialog!
            self._showDemoteDialog = showDemoteDialog!
            self._showPromoteDialog = showPromoteDialog!
        }else{
            self._showCheckinDialog = .constant(false)
            self._showDemoteDialog = .constant(false)
            self._showPromoteDialog = .constant(false)
        }
        
        
        if(selectedTab != nil){
            self._selectedTab = selectedTab
        }
        
        if(viewModel != nil) {
            _viewModel = StateObject(wrappedValue:viewModel!)
        }else{
            _viewModel = StateObject(wrappedValue:
                DependencyContainer.shared.container.resolve(HomeScreenViewModel.self)!)
        }
    }
}

// MARK: - Preview
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        let mockVM = HomeScreenViewModel()
        mockVM.cachedActivityLevels = [2, 4, 6, 8, 5, 7, 3]
        mockVM.cachedStreakData = [1, 2, 0, -1, -1 , -1 , -1]
        @State var selectedTab = 0
        @State var showCheckinDialog: Bool = false
        
        return HomeScreenView(viewModel: mockVM, selectedTab: $selectedTab, showCheckinDialog: $showCheckinDialog)
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
