//
//  DashboardScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 15/03/2025.
//

import SwiftUI

struct DashboardScreenView: View {
    //MARK: - Properties
    @EnvironmentObject var theme: Theme
    @EnvironmentObject var appCoordinator: AppCoordinator

    //Estado para animações
    @State var duration = 2.0
    @State var initSize = 1.1
    @State var angle = 0.00
    @State var opacity = 1.0

    //MARK: - Body
    var body: some View {
        VStack {
            Text("FibroApoio Dashboard")
                .title(theme)
                .scaleEffect(initSize)
                .opacity(opacity)
        }
    }
}
//MARK: - Preview
struct DashboardScreenView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardScreenView()
            .environmentObject(Theme())
            .environmentObject(AppCoordinator())
    }
}
