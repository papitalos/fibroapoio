//
//  AtomTimeInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import SwiftUI

struct AtomTimeInput: View {
    // MARK: - Bindings e propriedades configuráveis
    var label: String?
    var title: String
    @Binding var time: Date
    var icon: String = "clock"
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var foregroundColor: Color = .gray
    var backgroundColor: Color = Color.gray.opacity(0.1)

    // MARK: - Estado para o DatePicker modal
    @State private var showPicker = false
    @State private var tempTime = Date()

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let label = label {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.leading, 8)
            }

            Button(action: {
                tempTime = time // inicializa com o valor atual
                showPicker = true
            }) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(foregroundColor)
                    Text(title)
                        .foregroundColor(foregroundColor)
                    Spacer()
                    Text(time.formatted(date: .omitted, time: .shortened))
                        .foregroundColor(foregroundColor)
                    Image(systemName: "chevron.right")
                        .foregroundColor(foregroundColor)
                }
                .padding()
                .background(backgroundColor)
                .cornerRadius(borderRadius)
                .overlay {
                    if border {
                        RoundedRectangle(cornerRadius: borderRadius)
                            .stroke(foregroundColor.opacity(0.3), lineWidth: 1)
                    }
                }
            }
            .sheet(isPresented: $showPicker) {
                VStack(spacing: 20) {
                    DatePicker("Selecionar horário", selection: $tempTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()

                    Button("Confirmar") {
                        time = tempTime
                        showPicker = false
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
                .presentationDetents([.fraction(0.35)])
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct AtomTimeSelectorPreview: View {
    @State private var selectedTime: Date = Date()

    var body: some View {
        VStack(spacing: 20) {
            AtomTimeInput(
                label: "Hora da Consulta",
                title: "Selecionar Horário",
                time: $selectedTime,
                icon: "clock.fill",
                border: false
            )
        }
        .padding()
    }
}

struct AtomTimeSelector_Previews: PreviewProvider {
    static var previews: some View {
        AtomTimeSelectorPreview()
    }
}
