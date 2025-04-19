//
//  HomeView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/04/2025.
//

import SwiftUI

struct HomeScreenView: View {
    // MARK: - Enviroment Objects
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: HomeScreenViewModel
    @State var notificationsEnabled = true
    @Service var appCoordinator: AppCoordinatorService
    @Service var authenticationService: AuthenticationService
    
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
            // Saudação e Energia
            HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text(greeting)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                        Text(appCoordinator.user?.nome?.firstName ?? "Usuário")
                            .font(.title)
                            .fontWeight(.bold)
                    }
                Spacer()
                HStack {
                    VStack {
                        Text("Madeira")
                            .font(.caption)
                            .fontWeight(.medium)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 4)
                            .background(Color.brown.opacity(0.2))
                            .cornerRadius(8)
                        HStack {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(.yellow)
                                .font(.footnote)
                            Text("10.500")
                                .font(.headline)
                        }
                    }
                }
            }

            // Calendário
            VStack {
                HStack {
                    Image(systemName: "chevron.left")
                    Spacer()
                    Text("Maio 2025")
                        .font(.headline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .foregroundColor(.gray)

                HStack(spacing: 10) {
                    ForEach(["Seg, 10", "Ter, 11", "Qua, 12", "Qui, 13", "Sex, 14", "Sab, 15", "Dom, 16"], id: \.self) { day in
                        VStack {
                            Circle()
                                .frame(width: 8, height: 8)
                                .foregroundColor(day.hasSuffix("10") ? .blue : .clear)
                            Text(day)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .padding(.bottom)

            // Objetivo do dia e botão de check-in
            HStack {
                Text("Objetivo do dia ⚠️")
                    .font(.subheadline)
                    .foregroundColor(.black)
                Spacer()
                Button(action: {}) {
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

            // Atividade Física (Gráfico)
            VStack(alignment: .leading) {
                Text("Atividade Física")
                    .font(.headline)
                HStack(alignment: .bottom, spacing: 15) {
                    ForEach(0..<7) { index in
                        VStack {
                            Capsule()
                                .frame(width: 10, height: CGFloat(40 + index * 10))
                                .foregroundColor(index % 2 == 0 ? Color.purple : Color.blue)
                            Text(["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"][index])
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background(Color.gray.opacity(0.1))
            .cornerRadius(12)

            // Últimas Atividades
            VStack(alignment: .leading) {
                HStack {
                    Text("Últimas Atividades")
                        .font(.headline)
                    Spacer()
                    Button(action: {}) {
                        Text("Ver mais")
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }

                VStack(spacing: 10) {
                    ActivityRow(activityName: "Musculação", color: .blue, points: 500, timeAgo: "2h atrás")
                    ActivityRow(activityName: "Registro de dor", color: .pink, points: 200, timeAgo: "3h atrás")
                    ActivityRow(activityName: "Registro de medicamento", color: .purple, points: 100, timeAgo: "4h atrás")
                }
            }
        }
        .padding()
    }
    
    //MARK: - Init
    init(){
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(HomeScreenViewModel.self)!)
    }
}

// Componente de Atividade
struct ActivityRow: View {
    var activityName: String
    var color: Color
    var points: Int
    var timeAgo: String

    var body: some View {
        HStack {
            Circle()
                .fill(color.opacity(0.3))
                .frame(width: 40, height: 40)
            VStack(alignment: .leading) {
                Text(activityName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(timeAgo)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Spacer()
            HStack {
                Text("↑ $$points)")
                    .foregroundColor(.green)
                    .fontWeight(.bold)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(radius: 3)
    }
}

// MARK: - Preview
struct HomeScreenView_Previews: PreviewProvider {
    static var previews: some View {
        return HomeScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }

}
