//
//  MedicationEntryScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//

import SwiftUI

struct MedicationEntryScreenView: View {
    // MARK: - Environment & Services
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: MedicationEntryScreenViewModel
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
                ZStack {
                    Button(action: {
                        appCoordinator.goToPage(.dashboard)
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
                    .padding(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 320))
                    Text("Adicionar Medicamento")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity, alignment: .center)
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
                    
                    AtomTimeInput(
                        label: "Hora de Consumo",
                        title: "Selecionar Horário",
                        time: $viewModel.consumptionTime,
                        icon: "clock.fill",
                        border: false
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
                    if let error = viewModel.errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    
                    AtomButton(
                        action: { viewModel.openDialog()
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
        .overlay(
            Group {
                if viewModel.showPoints {
                    DialogPanel(
                        isPresented: $viewModel.showPoints,
                        windowName: "",
                        title: "+\(viewModel.selectedPoints) ⚡️",
                        description: "Registro de medicação concluido com sucesso!",
                        rightButton: (
                            label: "Continuar",
                            action: {
                                viewModel.saveMedicine()
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

    // MARK: - Init
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(MedicationEntryScreenViewModel.self)!
        )
    }
}

// MARK: - Preview
struct AddMedicineScreenView_Previews: PreviewProvider {
    static var previews: some View {
        MedicationEntryScreenView()
            .environmentObject(Theme())
            .environmentObject(
                DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!
            )
    }
}
