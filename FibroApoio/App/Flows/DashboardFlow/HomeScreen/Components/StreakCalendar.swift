//
//  StreakCalendar.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 21/04/2025.
//

import SwiftUI

struct StreakCalendar: View {
    // MARK: - Properties
    @State private var currentWeek: [String] = []
    @State private var currentWeekDays: [String] = []
    @State private var currentMonth: String = ""
    @State private var startDate: Date = Date()
    
    // MARK: - Configs
    let primaryColor: Color
    let secondaryColor: Color
    let streakData: [Int]

    // MARK: - Init
    init(
        primaryColor: Color,
        secondaryColor: Color,
        streakData: [Int]
    ) {
        let today = Date()
        _startDate = State(initialValue: today)
        _currentMonth = State(initialValue: Calendar.current.monthSymbols[Calendar.current.component(.month, from: today) - 1])
        _currentWeek = State(initialValue: [])
        _currentWeekDays = State(initialValue: [])
        
        self.primaryColor = primaryColor
        self.secondaryColor = secondaryColor
        self.streakData = streakData
    }


    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // Título do mês (sem botões)
            Text(currentMonth)
                .font(.headline)
                .foregroundColor(.gray)

            // Dias da semana com os indicadores
            HStack {
                ForEach(0..<min(currentWeek.count, streakData.count), id: \.self) { index in
                    VStack(spacing: 8) {
                        // Indicador (ícone circular)
                        ZStack {
                            Circle()
                                .fill(colorForStreakValue(streakData[index]))
                                .frame(width: 24, height: 24)

                            if let symbol = symbolForStreakValue(streakData[index]) {
                                symbol
                                    .foregroundColor(.white)
                                    .font(.system(size: 16))
                            }
                        }

                        // Dia da semana e data
                        (
                            Text(currentWeek[index] + ", ") +
                            Text(currentWeekDays[index]).bold()
                        )
                        .font(.system(size: 12))
                        .foregroundColor(.gray)
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                        .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            updateWeek(for: Date())
        }
    }

    // MARK: - Helper Methods

    func updateWeek(for date: Date) {
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        currentMonth = formatter.string(from: date).capitalized

        guard let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)) else {
            return
        }

        currentWeek = []
        currentWeekDays = []

        for i in 0..<7 {
            if let day = calendar.date(byAdding: .day, value: i, to: startOfWeek) {
                let dayNumber = calendar.component(.day, from: day)
                let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: day) - 1]

                currentWeek.append(weekdaySymbol.capitalized)
                currentWeekDays.append(String(dayNumber))
            }
        }
    }

    func colorForStreakValue(_ value: Int) -> Color {
        switch value {
        case -1: return Color.gray.opacity(0.2) // futuro
        case 0: return Color.red // ❌ Não veio
        case 1: return primaryColor // ✅
        case 2: return secondaryColor // ❄️
        default: return Color.clear
        }
    }

    func symbolForStreakValue(_ value: Int) -> Image? {
        switch value {
        case 0: return Image(systemName: "xmark")
        case 1: return Image(systemName: "checkmark")
        case 2: return Image(systemName: "snowflake")
        default: return nil // -1 ou outros
        }
    }
}

// MARK: - Preview
struct StreakCalendar_Previews: PreviewProvider {
    static var previews: some View {
        StreakCalendar(
            primaryColor: .green,
            secondaryColor: .blue,
            streakData: [1, 0, 2, -1, -1, -1, -1] 
        )
        .padding()
    }
}
