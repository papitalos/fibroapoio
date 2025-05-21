import SwiftUI

struct StreakCalendar: View {
    // MARK: - Properties
    @State private var currentWeek: [String] = []
    @State private var currentMonth: String = ""
    @State private var streakData: [Int] = [0, 1, 2, 0, 1, 0, 2] // Dados de exemplo
    @State private var startDate: Date = Date()
    
    // MARK: - Init
    init() {
        // Configurar a semana inicial e o mês com base na data atual
        updateWeek(for: Date())
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 16) {
            // Título do mês
            HStack {
                Button(action: { moveToPreviousWeek() }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
                Text(currentMonth)
                    .font(.headline)
                    .foregroundColor(.gray)
                Button(action: { moveToNextWeek() }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            
            // Dias da semana com os indicadores
            HStack(spacing: 16) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        // Indicador (ícone circular)
                        Circle()
                            .fill(colorForStreakValue(streakData[index]))
                            .frame(width: 36, height: 36)
                            .overlay(
                                symbolForStreakValue(streakData[index])
                                    .foregroundColor(.white)
                                    .font(.headline)
                            )
                        
                        // Dia da semana e data
                        Text(currentWeek[index])
                            .font(.footnote)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
        .onAppear {
            fetchDataForCurrentWeek()
        }
    }
    
    // MARK: - Helper Methods
    
    func updateWeek(for date: Date) {
        // Atualiza o calendário com os dias da semana e mês correspondente
        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        
        currentMonth = formatter.string(from: date)
        
        let weekdaySymbols = calendar.shortWeekdaySymbols
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date))!
        
        currentWeek = (0..<7).map {
            let dayDate = calendar.date(byAdding: .day, value: $0, to: startOfWeek)!
            let dayNumber = calendar.component(.day, from: dayDate)
            let weekday = weekdaySymbols[calendar.component(.weekday, from: dayDate) - 1]
            return "$$weekday), $$dayNumber)"
        }
    }
    
    func fetchDataForCurrentWeek() {
        // Função mock: Aqui você faria a requisição ao Firebase
        print("Fetching data for week starting on $$startDate)")
    }
    
    func moveToNextWeek() {
        // Avança uma semana
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: startDate) {
            startDate = newDate
            updateWeek(for: startDate)
            fetchDataForCurrentWeek()
        }
    }
    
    func moveToPreviousWeek() {
        // Retorna uma semana
        if let newDate = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: startDate) {
            startDate = newDate
            updateWeek(for: startDate)
            fetchDataForCurrentWeek()
        }
    }
    
    func colorForStreakValue(_ value: Int) -> Color {
        // Define a cor para cada status
        switch value {
        case 0: return Color.gray // Login não realizado
        case 1: return Color.blue // Login realizado
        case 2: return Color.teal // Congelado
        default: return Color.clear
        }
    }
    
    func symbolForStreakValue(_ value: Int) -> Image {
        // Define o ícone para cada status
        switch value {
        case 0: return Image(systemName: "") // Nenhum ícone
        case 1: return Image(systemName: "checkmark") // Login realizado
        case 2: return Image(systemName: "snowflake") // Congelado
        default: return Image(systemName: "")
        }
    }
}

// MARK: - Preview
struct StreakCalendar_Previews: PreviewProvider {
    static var previews: some View {
        StreakCalendar()
            .padding()
    }
}