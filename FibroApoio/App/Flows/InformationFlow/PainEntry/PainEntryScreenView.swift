//
//  PainEntryScreen.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 30/04/2025.
//


import SwiftUI

/// Tela de registro de dores com hotspots clicáveis e seleção de nível
struct PainEntryScreenView: View {
    // MARK: State
    @Service var appCoordinatorService: AppCoordinatorService
    @Service var userService: UserService
    @Service var theme: Theme
    @StateObject private var viewModel = PainEntryScreenViewModel()
    @State private var side: BodySide = .front
    @State private var selectedZone: BodyZone?

    var body: some View {
        VStack(spacing: 16) {
            // 1) Toggle de frente/trás
            Picker(selection: $side, label: Text("Lado")) {
                Text("Frente").tag(BodySide.front)
                Text("Trás").tag(BodySide.back)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding(.horizontal)
            
            // 2) Corpo com hotspots
            GeometryReader { geo in
                ZStack {
                    if(userService.currentUser?.genero == "Masculino"){
                        Image(side == .front ? "man_front" : "man_back")
                            .resizable()
                            .scaledToFit()
                    }else{
                        Image(side == .front ? "woman_front" : "woman_back")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    
                    ForEach(zones(for: side)) { zoneInfo in
                        hotspotView(for: zoneInfo, in: geo)
                    }

                }
            }
            Spacer()
            
            // 4) Botão de completar
            VStack{
                Text(viewModel.entries.count == 1 ?
                     "1 dor registrada" :
                     "\(viewModel.entries.count) dores registradas"
                )
                    .foregroundColor(.white)
                    .bodySM(theme)

                AtomButton(
                    action: { viewModel.openDialog() },
                    label: "Proximo",
                    icon: "arrow.right",
                    iconPosition: .trailing,
                    borderRadius: 125,
                    border: true,
                    backgroundColor: theme.colors.brandPrimary,
                    textColor: .white
                )
                .padding(.horizontal)
                .padding(.bottom)
            }
           
        }
        .padding(24)
        .background(Gradient(colors:[theme.colors.brandTertiary,.blue]))
        .sheet(item: $selectedZone) { zone in
            PainLevelPicker(zone: zone) { level in
                if level >= 0 {
                    viewModel.addEntry(PainEntry(zone: zone, level: level, side: side))
                }
                selectedZone = nil
            }
        }
        .overlay(
            Group {
                if viewModel.showPoints {
                    DialogPanel(
                        isPresented: $viewModel.showPoints,
                        windowName: "",
                        title: "+\(viewModel.selectedPoints) ⚡️",
                        description: "Registro de dores concluido com sucesso!",
                        rightButton: (
                            label: "Continuar",
                            action: {
                                viewModel.savePainEntries()
                            }
                        ),
                        leftButton: (
                            label: "Me enganei",
                            action: {}
                        )
                    )
                }
            }
        )

    }


    // MARK: - Helpers
   
    /// Define hotspots de acordo com o lado
    private func zones(for side: BodySide) -> [Zone] {
        // posições aproximadas (x, y) relativas
        let common: [Zone] = [
            Zone(zone: .head, x: 0.5, y: 0.13),
            Zone(zone: .rightShoulder, x: 0.33, y: 0.28),
            Zone(zone: .leftShoulder, x: 0.68, y: 0.28),
            Zone(zone: .rightElbow, x: 0.3, y: 0.40),
            Zone(zone: .leftElbow, x: 0.7, y: 0.40),
            Zone(zone: .rightHand, x: 0.23, y: 0.53),
            Zone(zone: .leftHand, x: 0.76, y: 0.53),
            Zone(zone: .chest, x: 0.5, y: 0.3),
            Zone(zone: .abdomen, x: 0.5, y: 0.42),
            Zone(zone: .rightHip, x: 0.4, y: 0.52),
            Zone(zone: .leftHip, x: 0.6, y: 0.52),
            Zone(zone: .rightThigh, x: 0.4, y: 0.63),
            Zone(zone: .leftThigh, x: 0.6, y: 0.63),
            Zone(zone: .rightKnee, x: 0.37, y: 0.73),
            Zone(zone: .leftKnee, x: 0.63, y: 0.73),
            Zone(zone: .rightShin, x: 0.37, y: 0.83),
            Zone(zone: .leftShin, x: 0.63, y: 0.83),
            Zone(zone: .rightFoot, x: 0.33, y: 0.93),
            Zone(zone: .leftFoot, x: 0.67, y: 0.93)
        ]
        return common
    }
    
    @ViewBuilder
    private func hotspotView(for zoneInfo: Zone, in geo: GeometryProxy) -> some View {
        let isSelected = viewModel.entries.contains {
            $0.zone == zoneInfo.zone && $0.side == side
        }

        let circleOpacity = isSelected ? 0.6 : 0.01

        Circle()
            .fill(Color.red)
            .opacity(circleOpacity)
            .frame(width: 66, height: 66)
            .position(
                x: geo.size.width * zoneInfo.x,
                y: geo.size.height * zoneInfo.y
            )
            .onTapGesture {
                if let index = viewModel.entries.firstIndex(where: {
                    $0.zone == zoneInfo.zone && $0.side == side
                }) {
                    viewModel.entries.remove(at: index)
                } else {
                    selectedZone = zoneInfo.zone
                }
            }
    }

    
    //MARK: - Init
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(PainEntryScreenViewModel.self)!)
        
        // Fundo das partes não-selecionadas
       UISegmentedControl.appearance().backgroundColor = .white
       // Cor do segmento selecionado
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(theme.colors.brandPrimary)
       // Texto normal (não-selecionado)
       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.gray], for: .normal)
       // Texto do segmento selecionado
       UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
    }
}

// MARK: - Picker de nível de dor
struct PainLevelPicker: View {
    let zone: BodyZone
    let onSelect: (Int) -> Void

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: { onSelect(-1) }) {
                    Image(systemName: "xmark")
                        .foregroundColor(.secondary)
                        .padding()
                }
                Text("Nível da dor")
                    .font(.headline)
                Spacer()
            }

            Text("Selecione o nível de dor de 1 (leve) até 10 (intensa) para \(String(describing: zone.displayName))")
                .font(.subheadline)
                .foregroundColor(.gray)

            // 1 a 10 com variação de cor
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 4) {
                    ForEach(1...10, id: \.self) { i in
                        let hue = 0.0 + (Double(i - 1) / 9.0) * 0.33 // de vermelho (0.0) a verde (0.33)
                        let color = Color(hue: hue, saturation: 0.9, brightness: 0.9)

                        Button(action: { onSelect(i) }) {
                            Text("\(i)")
                                .font(.body.weight(.bold))
                                .frame(width: 32, height: 32)
                                .background(color)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            Spacer()
        }
        .padding()
        .presentationDetents([.medium])
    }
}


// MARK: - Preview

struct PainRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        PainEntryScreenView()
            .previewLayout(.sizeThatFits)
    }
}
