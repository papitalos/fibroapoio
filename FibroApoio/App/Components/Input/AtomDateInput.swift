//
//  AtomDateInput.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 12/04/2025.
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
    var placeholderColor: Color = .gray
    var selectedTextColor: Color = .blue
    var backgroundColor: Color = Color.gray.opacity(0.1)
    var mainIconName: String = "calendar"
    
    // MARK: - Init
    init(
        selectedDate: Binding<Date?>,
        placeholder: String = "Escolha uma data",
        onDateChange: @escaping (Date) -> Void,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        placeholderColor: Color = .gray,
        selectedTextColor: Color = .blue,
        backgroundColor: Color = Color.gray.opacity(0.1),
        mainIconName: String = "calendar"
    ) {
        self._selectedDate = selectedDate
        self.placeholder = placeholder
        self.onDateChange = onDateChange
        self.borderRadius = borderRadius
        self.border = border
        self.placeholderColor = placeholderColor
        self.selectedTextColor = selectedTextColor
        self.backgroundColor = backgroundColor
        self.mainIconName = mainIconName
    }
    
    // MARK: - Body
    var body: some View {
        HStack {
            Image(systemName: mainIconName)
                .foregroundColor(.gray)
            
            // Mostrar a data selecionada ou o placeholder
            if let date = selectedDate {
                Text(formattedDate(date))
                    .foregroundColor(selectedTextColor)
            } else {
                Text(placeholder)
                    .foregroundColor(placeholderColor)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: borderRadius)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: borderRadius)
                        .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
                )
        )
        .onTapGesture {
            showDatePicker()
        }
    }
    
    // MARK: - Auxiliar Functions
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func showDatePicker() {
        // Mostrar o DatePicker em "sheet" usando UIKit
        let alert = UIAlertController(style: .actionSheet, title: "Selecionar Data")
        let picker = UIDatePicker()

        picker.datePickerMode = .date
        picker.preferredDatePickerStyle =.inline **```