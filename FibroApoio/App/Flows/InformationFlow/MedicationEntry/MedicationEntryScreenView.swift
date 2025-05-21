//
//  MedicationEntry.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import SwiftUI

struct MedicationEntryScreen: View {
    // MARK: - Environment & Services
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: AddMedicineScreenViewModel
    @Service var appCoordinator: AppCoordinatorService
    
    // MARK: - Focus State
    enum Field: Hashable {
        case notes
    }
    @FocusState private var focusedField: Field?

    // MARK: - Body
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            
            VStack(spacing: theme.spacing.md) {
                // MARK: - Header
                HStack {
                    Button(action: {
                        appCoordinator.pop()
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 44, height: 44)
                            
                            Image(systemName: "arrow.left")
                                .foregroundColor(theme.colors.contentPrimary)
                                .font(.system(size: 18, weight: .semibold))
                        }
                    }
                    Spacer()
                    Text("Adicionar Medicamento")
                        .font(.headline)
                        .fontWeight(.semibold)
                    Spacer().frame(width: 44)
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Formulário
                VStack(spacing: theme.spacing.md) {
                    AtomTextInput(
                        placeholder: "Nome da medicação",
                        icon: "pills",
                        iconPosition: .leading,
                        maxLength: 50,
                        text: $viewModel.medicineName
                    )
                    
                    AtomTimeSelector(
                        title: "Hora de consumo",
                        time: viewModel.consumptionTime,
                        onTap: { viewModel.showTimePicker = true }
                    )
                    
                    AtomTextInput(
                        placeholder: "Tomar novamente? Ex: 8h em 8h",
                        icon: "arrow.triangle.2.circlepath",
                        iconPosition: .leading,
                        maxLength: 20,
                        text: $viewModel.repeatInterval
                    )
                    
                    VStack(alignment: .leading, spacing: theme.spacing.sm) {
                        Text("Ocorreu algo que quer deixar anotado?")
                            .font(.headline)
                        TextEditor(text: $viewModel.notes)
                            .focused($focusedField, equals: .notes)
                            .frame(height: 150)
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
                
                Spacer()
                
                // MARK: - Botão de Ação
                VStack {
                    AtomButton(
                        action: {
                            viewModel.saveMedicine()
                        },
                        label: "Registrar medicação",
                        borderRadius: 125,
                        border: true,
                        backgroundColor: .purple,
                        textColor: .white
                    )
                }
                .padding(.horizontal)
                .padding(.bottom, theme.spacing.lg)
            }
            .padding(.top, theme.spacing.lg)
        }
        .ignoresSafeArea(.keyboard)
        .sheet(isPresented: $viewModel.showTimePicker) {
            DatePicker(
                "Selecionar hora",
                selection: $viewModel.consumptionTime,
                displayedComponents: .hourAndMinute
            )
            .datePickerStyle(.wheel)
            .labelsHidden()
            .presentationDetents([.fraction(0.3)])
        }
    }

    // MARK: - Init
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(AddMedicineScreenViewModel.self)!
        )
    }
}

// MARK: - Preview
struct AddMedicineScreenView_Previews: PreviewProvider {
    static var previews: some View {
        AddMedicineScreenView()
            .environmentObject(Theme())
            .environmentObject(
                DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!
            )
    }
}
