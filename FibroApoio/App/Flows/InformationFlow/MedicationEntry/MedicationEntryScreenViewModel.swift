//
//  MedicationEntryScreenViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

class MedicationEntryScreenViewModel: ObservableObject {
    // MARK: - Inputs
    @Published var medicineName: String = ""
    @Published var consumptionTime: Date = Date()
    @Published var repeatInterval: String = ""
    @Published var notes: String = ""
    @Published var errorMessage: String? = nil

    // MARK: - UI Control
    @Published var showTimePicker: Bool = false
    let points = [200,300,400]
    @Published var selectedPoints: Int = 0
    @Published var showPoints: Bool = false
    
    // MARK: - Services
    @Service var appCoordinator: AppCoordinatorService
    @Service var userService: UserService

    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Public Methods
    func openDialog() {
        guard !medicineName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
               errorMessage = "Por favor, preencha o nome da medicação."
               return
           }

           guard !repeatInterval.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
               errorMessage = "Informe se haverá repetição (ex: 8h em 8h)."
               return
           }
        
        self.errorMessage = nil
        self.selectedPoints = self.points.randomElement()!
        self.showPoints = true
    }
    
    func saveMedicine() {
        guard let userId = userService.currentUser?.id else {
            print("‼️ Usuário não encontrado")
            return
        }

        let repeatHours = Int(repeatInterval.filter("0123456789".contains))

        let medicacao = Medicacao(
            id: nil,
            data_consumo: Timestamp(date: consumptionTime),
            id_usuario: userId,
            nome: medicineName.trimmingCharacters(in: .whitespacesAndNewlines),
            observacoes: notes,
            periodo: repeatHours,
            createdAt: nil,
            updatedAt: nil,
            deletedAt: nil
        )

        userService.persistWeeklyData { weekly in
            weekly.medicacoes.append(medicacao)
        }
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completion in
            switch completion {
            case .failure(let error):
                print("❌ Erro ao salvar medicação: \(error.localizedDescription)")
            case .finished:
                print("✅ Medicação salva com sucesso.")
                self.appCoordinator.goToPage(.dashboard)
            }
        }, receiveValue: { _ in })
        .store(in: &cancellables)
    }

}
