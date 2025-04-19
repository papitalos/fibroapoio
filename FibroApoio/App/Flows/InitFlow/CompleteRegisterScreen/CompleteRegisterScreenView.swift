//
//  CompleteRegisterScreenView.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 09/04/2025.
//

import SwiftUI

struct CompleteRegisterScreenView: View {
    @EnvironmentObject var theme: Theme
    @StateObject var viewModel: CompleteRegisterScreenViewModel
    
    enum Field: Int, Hashable {
        case weight, height, birth_date, gender
    }
    @FocusState private var focusedField: Field?
    
    var body: some View {
        ZStack {
            Color.clear
                .contentShape(Rectangle())
                .onTapGesture {
                    focusedField = nil
                }
            VStack {
                Image("lootie-5")
                VStack {
                    Text("Vamos completar o seu perfil")
                        .heading(theme)
                        .fontWeight(.bold)
                    Text("Ajude-nos a saber um pouco mais sobre você")
                        .body(theme)
                }
                .padding(.top, theme.spacing.md)
                .padding(.horizontal, theme.spacing.xlg)
                Spacer()
                VStack(spacing: theme.spacing.md) {
                    // Gênero
                    VStack(alignment: .leading) {
                        AtomDropdownButton(
                            selectedOption: $viewModel.generoSelecionado,
                            options: [
                                (Genero.masculino, "Masculino", "person.fill"),
                                (Genero.feminino, "Feminino", "person.fill")
                            ],
                            placeholder: "Selecione seu gênero",
                            onSelect: { genero in
                                viewModel.genero = genero.rawValue
                            },
                            borderRadius: 16,
                            border: false,
                            mainIconName: "person.fill",
                            dropdownIcon: "chevron.down",
                            onSubmit: {focusedField = .birth_date }
                        )
                        .focused($focusedField, equals: .gender)
                        .frame(height: 55)
                    }
                    
                    // Data de Nascimento
                    VStack(alignment: .leading) {
                        AtomDateInput(
                            selectedDate: $viewModel.dataNascimento,
                            placeholder: "Data de nascimento",
                            onDateChange: { date in
                                viewModel.dataNascimento = date
                            },
                            borderRadius: 16,
                            border: false,
                            backgroundColor: Color.gray.opacity(0.1),
                            mainIconName: "calendar",
                            onSubmit: { focusedField = .weight }
                        )
                        .focused($focusedField, equals: .birth_date)
                        .frame(height: 55)
                    }
                    
                    // Peso
                    HStack{
                        AtomNumberInput(
                            placeholder: "Seu peso",
                            icon: "scalemass",
                            iconPosition: .leading,
                            maxLength: 3,
                            text: $viewModel.peso,
                            onSubmit: { focusedField = .height }
                        )
                        .focused($focusedField, equals: .weight)
                        .frame(height: 55)
                        
                        Text("KG")
                        .frame(width: 55, height: 55)
                        .foregroundColor(.white)
                        .background(Gradient(colors: [theme.colors.brandPrimary, theme.colors.brandTertiary]))
                        .cornerRadius(16)

                    }
                    
                    // Altura
                    HStack{
                        AtomNumberInput(
                            placeholder: "Sua altura",
                            icon: "ruler",
                            iconPosition: .leading,
                            maxLength: 3,
                            text: $viewModel.altura,
                            onSubmit: { viewModel.completeRegistration() }
                        )
                        .focused($focusedField, equals: .height)
                        .frame(height: 55)

                        Text("CM")
                        .frame(width: 55, height: 55)
                        .foregroundColor(.white)
                        .background(Gradient(colors: [theme.colors.brandPrimary, theme.colors.brandTertiary]))
                        .cornerRadius(16)
                        
                    }
                }
                .padding(theme.spacing.xlg)
                Spacer()
                VStack {
                    AtomButton(
                        action: {
                            viewModel.completeRegistration()
                        },
                        label: "Completar Perfil",
                        icon: "arrow.right",
                        iconPosition: .trailing,
                        borderRadius: 125,
                        border: true,
                        backgroundColor: .blue,
                        textColor: .white
                    )
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding(.top, theme.spacing.sm)
                    }
                }
                .padding(.horizontal, theme.spacing.xlg)
                Spacer()
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)

        
    }
    
    init() {
        _viewModel = StateObject(wrappedValue:
            DependencyContainer.shared.container.resolve(CompleteRegisterScreenViewModel.self)!)
    }
}

// MARK: - Preview

struct CompleteRegisterScreenView_Previews: PreviewProvider {
    static var previews: some View {
        CompleteRegisterScreenView()
            .environmentObject(Theme())
            .environmentObject(DependencyContainer.shared.container.resolve(AppCoordinatorService.self)!)
    }
}
