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
    @Service var appcCoordinatorService: AppCoordinatorService
    @Service var theme: Theme
    @StateObject private var viewModel = PainEntryScreenViewModel()
    @State private var side: BodySide = .front
    @State private var entries: [PainEntry] = []
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
                    if(appcCoordinatorService.user?.genero == "Masculino"){
                        Image(side == .front ? "man_front" : "man_back")
                            .resizable()
                            .scaledToFit()
                    }else{
                        Image(side == .front ? "woman_front" : "woman_back")
                            .resizable()
                            .scaledToFit()
                    }
                    
                    ForEach(zones(for: side)) { zoneInfo in
                        Circle()
                            .fill(Color.red.opacity(opacity(for: zoneInfo.zone)))
                            .frame(width: 66, height: 66)
                            .position(x: geo.size.width * zoneInfo.x,
                                      y: geo.size.height * zoneInfo.y)
                            .onTapGesture {
                                if let existingIndex = entries.firstIndex(where: { $0.zone == zoneInfo.zone && $0.side == side }) {
                                    entries.remove(at: existingIndex)
                                } else {
                                    selectedZone = zoneInfo.zone
                                }
                            }
                    }
                }
            }
            Spacer()
            
            // 4) Botão de completar
            VStack{
                Text( entries.count == 1 ?
                      "\(entries.count) dor registrada" :
                        "\(entries.count) dores registradas"
                )
                    .foregroundColor(.white)
                    .bodySM(theme)

                AtomButton(
                    action: { viewModel.savePainEntries() },
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

    }

    // MARK: - Helpers

    /// Define hotspots de acordo com o lado
    private func zones(for side: BodySide) -> [Zone] {
        // posições aproximadas (x, y) relativas
        let common: [Zone] = [
            Zone(zone: .head, x: 0.5, y: 0.13),
            Zone(zone: .leftShoulder, x: 0.33, y: 0.28),
            Zone(zone: .rightShoulder, x: 0.68, y: 0.28),
            Zone(zone: .leftElbow, x: 0.3, y: 0.40),
            Zone(zone: .rightElbow, x: 0.7, y: 0.40),
            Zone(zone: .leftHand, x: 0.23, y: 0.53),
            Zone(zone: .rightHand, x: 0.76, y: 0.53),
            Zone(zone: .chest, x: 0.5, y: 0.3),
            Zone(zone: .abdomen, x: 0.5, y: 0.42),
            Zone(zone: .leftHip, x: 0.4, y: 0.52),
            Zone(zone: .rightHip, x: 0.6, y: 0.52),
            Zone(zone: .leftThigh, x: 0.4, y: 0.63),
            Zone(zone: .rightThigh, x: 0.6, y: 0.63),
            Zone(zone: .leftKnee, x: 0.37, y: 0.73),
            Zone(zone: .rightKnee, x: 0.63, y: 0.73),
            Zone(zone: .leftShin, x: 0.37, y: 0.83),
            Zone(zone: .rightShin, x: 0.63, y: 0.83),
            Zone(zone: .leftFoot, x: 0.33, y: 0.93),
            Zone(zone: .rightFoot, x: 0.67, y: 0.93)
        ]
        return common
    }

    /// Opacidade do hotspot: mais forte se já registrado
    private func opacity(for zone: BodyZone) -> Double {
        if entries.contains(where: { $0.zone == zone && $0.side == side }) {
            return 0.6
        } else {
            return 0.01
        }
    }

    /// Exemplo de ação de salvar (a implementar)
    private func saveEntries() {
        // TODO: disparar chamada ao ViewModel / Service para persistir
        print("Entradas salvas: \(entries)")
    }
    
    init() {
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

            Text("Selecione o nível de dor em 0 a 10 para \(zone.displayName)")
                .font(.subheadline)
                .foregroundColor(.gray)

            // 0 a 10
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(0..<11) { i in
                        Button(action: { onSelect(i) }) {
                            Text("\(i)")
                                .font(.body.weight(.bold))
                                .frame(width: 36, height: 36)
                                .background(.gray)
                                .clipShape(Circle())
                                .foregroundColor(.white)
                        }
                    }
                }
                .padding(.horizontal)
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
