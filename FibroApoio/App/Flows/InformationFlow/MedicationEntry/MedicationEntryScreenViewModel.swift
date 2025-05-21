//
//  MedicationEntryScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import Foundation
import SwiftUI
import Combine

final class MedicationEntryScreenViewModel: ObservableObject {
    // MARK: - Input Fields
    @Published var medicineName: String = ""
    @Published var consumptionTime: Date = Date()
    @Published var repeatInterval: String = ""
    @Published var notes: String = ""
    
    // MARK: - UI Control
    @Published var showTimePicker: Bool = false
    
    // MARK: - Services
    @Service var appCoordinator: AppCoordinatorService
    @Service var medicineService: MedicineService // supondo que você tenha um serviço para salvar medicamentos

    // MARK: - Public Methods
    func saveMedicine() {
        // Validação simples
        guard !medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // TODO: Adicionar tratamento de erro com feedback ao usuário (ex: Snackbar, Toast etc.)
            return
        }

        let entry = MedicineEntry(
            name: medicineName,
            time: consumptionTime,
            repeatInterval: repeatInterval,
            notes: notes
        )
        
        medicineService.save(entry: entry) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.appCoordinator.pop()
                } else {
                    // TODO: Tratar falha ao salvar (ex: mostrar mensagem de erro)
                }
            }
        }
    }
}
