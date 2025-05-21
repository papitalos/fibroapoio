//
//  ExerciseEntryScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 05/05/2025.
//


import SwiftUI

struct ExerciseEntryScreenView: View {
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: ExerciseEntryScreenViewModel
    @Service var appCoordinator: AppCoordinatorService

    enum Field: Hashable {
        case notes
    }
    @FocusState private var focusedField: Field?

    var body: some View {
        VStack(spacing: theme.spacing.md) {
            // Header
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
                .padding(.trailing, 320)

                Text("Adicionar Exercício")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .center)
            .padding(.horizontal)

            Spacer()

            // Formulário
            VStack(spacing: theme.spacing.md) {
                AtomTextInput(
                    placeholder: "Nome do exercício",
                    icon: "dumbbell.fill",
                    iconPosition: .leading,
                    maxLength: 50,
                    text: $viewModel.exerciseName
                )

                AtomTimeInput(
                    label: "Início",
                    title: "Hora de Início",
                    time: $viewModel.startTime,
                    icon: "clock",
                    border: false
                )

                AtomTimeInput(
                    label: "Fim",
                    title: "Hora de Fim",
                    time: $viewModel.endTime,
                    icon: "clock",
                    border: false
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

            // Botão
            VStack {
                if let error = viewModel.errorMessage {
                    Text(error)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                AtomButton(
                    action: {
                        viewModel.openDialog()
                    },
                    label: "Registrar Exercício",
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
        .ignoresSafeArea(.keyboard)
        .overlay(
            Group {
                if viewModel.showPoints {
                    DialogPanel(
                        isPresented: $viewModel.showPoints,
                        windowName: "",
                        title: "+\(viewModel.selectedPoints) ⚡️",
                        description: "Exercício registrado com sucesso!",
                        rightButton: (
                            label: "Continuar",
                            action: {
                                viewModel.saveExercise()
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

    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(ExerciseEntryScreenViewModel.self)!
        )
    }
}

struct ExerciseEntryScreenView_Previews: PreviewProvider {
    static var previews: some View {
        ExerciseEntryScreenView()
            .environmentObject(Theme())
            .environmentObject(
                DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!
            )
    }
}
