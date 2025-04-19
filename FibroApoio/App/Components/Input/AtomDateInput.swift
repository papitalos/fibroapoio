//
//  AtomDateInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 14/04/2025.
//

import SwiftUI

struct AtomDateInput: View {
    // MARK: - Properties
    
    @Binding var selectedDate: Date?
    let placeholder: String
    let onDateChange: (Date) -> Void
    
    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var backgroundColor: Color = Color.gray.opacity(0.1)
    var mainIconName: String = "calendar"
    
    // Estado para exibir o modal
    @State private var isDatePickerPresented: Bool = false
    
    @FocusState private var inFocus: Bool
    var onSubmit: (() -> Void)? = nil
    
    // MARK: - Init
    init(
        selectedDate: Binding<Date?>,
        placeholder: String = "Escolha uma data",
        onDateChange: @escaping (Date) -> Void,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        backgroundColor: Color = Color.gray.opacity(0.1),
        mainIconName: String = "calendar",
        onSubmit: (() -> Void)? = nil
    ) {
        self._selectedDate = selectedDate
        self.placeholder = placeholder
        self.onDateChange = onDateChange
        self.borderRadius = borderRadius
        self.border = border
        self.backgroundColor = backgroundColor
        self.mainIconName = mainIconName
        self.onSubmit = onSubmit
    }
    
    // MARK: - Body
    var body: some View {
        dateInputContainer()
            .onTapGesture {
                showDatePicker()
            }
            .sheet(isPresented: $isDatePickerPresented) {
                createDatePickerView()
            }
    }
    
    // MARK: - Helper Methods
    
    // Método para criar o container do input
    private func dateInputContainer() -> some View {
        HStack {
            dateInputIcon()
            dateDisplayText()
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(dateInputBackground())
    }
    
    // Método para criar o ícone do campo
    private func dateInputIcon() -> some View {
        Image(systemName: mainIconName)
            .foregroundColor(.gray)
    }
    
    // Método para exibir o texto da data ou placeholder
    private func dateDisplayText() -> some View {
        Group {
            if let date = selectedDate {
                Text(formattedDate(date))
                    .foregroundColor(.blue)
            } else {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    // Método para criar o background do input
    private func dateInputBackground() -> some View {
        RoundedRectangle(cornerRadius: borderRadius)
            .fill(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
            )
    }
    
    // Método para criar a view do DatePicker
    private func createDatePickerView() -> some View {
        DatePickerView(
            selectedDate: $selectedDate,
            onDateChange: { date in
                onDateChange(date)
                isDatePickerPresented = false
                callOnSubmit()
            }
        )
    }
    
    // Método para formatar a data
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    // Método para exibir o DatePicker
    private func showDatePicker() {
        isDatePickerPresented = true
    }
    
    // Método para chamar onSubmit se existir
    private func callOnSubmit() {
        if let onSubmit = self.onSubmit {
            onSubmit()
        }
    }
}

// MARK: - DatePickerView
struct DatePickerView: View {
    @Binding var selectedDate: Date?
    let onDateChange: (Date) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 20) {
            datePickerHeader()
            datePickerWheel()
            confirmButton()
            cancelButton()
        }
        .padding()
    }
    
    // MARK: - Helper Methods
    
    private func datePickerHeader() -> some View {
        Text("Selecione a Data")
            .font(.headline)
            .padding(.top)
    }
    
    private func datePickerWheel() -> some View {
        DatePicker(
            "Selecione a Data",
            selection: Binding(
                get: { selectedDate ?? Date() },
                set: { date in
                    selectedDate = date
                }
            ),
            displayedComponents: .date
        )
        .datePickerStyle(WheelDatePickerStyle())
        .labelsHidden()
        .padding()
    }
    
    private func confirmButton() -> some View {
        Button("Confirmar") {
            if let date = selectedDate {
                onDateChange(date)
            }
        }
        .padding()
        .foregroundColor(.white)
        .background(Color.blue)
        .cornerRadius(10)
    }
    
    private func cancelButton() -> some View {
        Button("Cancelar") {
            dismiss()
        }
        .padding(.bottom)
        .foregroundColor(.red)
    }
}

// MARK: - Preview
struct AtomDateInput_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        @State private var selectedDate: Date? = nil
        
        var body: some View {
            VStack(spacing: 20) {
                AtomDateInput(
                    selectedDate: $selectedDate,
                    placeholder: "Data de nascimento",
                    onDateChange: { date in
                        print("Data selecionada: $$date)")
                    },
                    borderRadius: 16,
                    border: true
                )
                .frame(width: 300, height: 50)
                
                if selectedDate != nil {
                    Text("Data selecionada: \(dateFormatter.string(from: selectedDate!))")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
        }
        
        private var dateFormatter: DateFormatter {
            let formatter = DateFormatter()
            formatter.dateStyle = .long
            return formatter
        }
    }
}
