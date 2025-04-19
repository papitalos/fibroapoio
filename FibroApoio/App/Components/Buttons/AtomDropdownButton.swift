import SwiftUI

struct AtomDropdownButton<T: Hashable>: View {
    //MARK: - Properties
    
    // State
    @Binding var selectedOption: T?
    let options: [(option: T, label: String, icon: String?)]
    let placeholder: String
    let onSelect: (T) -> Void
    
    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var mainIconName: String = "tag.circle"
    var dropdownIcon: String = "chevron.down"
    
    // Focus e Submit
    @FocusState private var inFocus: Bool
    var onSubmit: (() -> Void)? = nil
    
    //MARK: - Init
    init(
        selectedOption: Binding<T?>,
        options: [(option: T, label: String, icon: String?)],
        placeholder: String = "Escolha aqui",
        onSelect: @escaping (T) -> Void,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        mainIconName: String = "tag.circle",
        dropdownIcon: String = "chevron.down",
        onSubmit: (() -> Void)? = nil
    ) {
        self._selectedOption = selectedOption
        self.options = options
        self.placeholder = placeholder
        self.onSelect = onSelect
        self.borderRadius = borderRadius
        self.border = border
        self.mainIconName = mainIconName
        self.dropdownIcon = dropdownIcon
        self.onSubmit = onSubmit
    }
    
    //MARK: - Body
    var body: some View {
        Menu {
            optionsMenuContent()
        } label: {
            dropdownButton()
        }
        .buttonStyle(PlainButtonStyle())
        .focused($inFocus)
        .onChange(of: selectedOption) {
            callOnSubmit()
        }
    }
    
    //MARK: - Helper Methods
    
    // Método para criar o conteúdo do menu de opções
    private func optionsMenuContent() -> some View {
        ForEach(options.indices, id: \.self) { index in
            menuOption(at: index)
        }
    }
    
    // Método para criar cada opção do menu
    private func menuOption(at index: Int) -> some View {
        let option = options[index]
        return Button {
            selectOption(option.option)
        } label: {
            optionLabel(option)
        }
        .padding(8)
    }
    
    // Método para criar o label de cada opção
    private func optionLabel(_ option: (option: T, label: String, icon: String?)) -> some View {
        HStack {
            Text(option.label)
            if let iconName = option.icon {
                Image(systemName: iconName)
            }
        }
        .padding(8)
    }
    
    // Método para selecionar uma opção
    private func selectOption(_ option: T) {
        selectedOption = option
        onSelect(option)
        inFocus = false
    }
    
    // Método para criar o botão do dropdown
    private func dropdownButton() -> some View {
        HStack {
            mainIcon()
            selectionText()
            Spacer()
            chevronIcon()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(buttonBackground())
    }
    
    // Método para o ícone principal
    private func mainIcon() -> some View {
        Image(systemName: mainIconName)
            .foregroundColor(.gray)
    }
    
    // Método para o texto de seleção
    private func selectionText() -> some View {
        Group {
            if let selected = selectedOption,
               let selectedItem = options.first(where: { $0.option == selected }) {
                Text(selectedItem.label)
                    .foregroundColor(.blue)
            } else {
                Text(placeholder)
                    .foregroundColor(.gray.opacity(0.5))
            }
        }
    }
    
    // Método para o ícone de chevron
    private func chevronIcon() -> some View {
        Image(systemName: dropdownIcon)
            .foregroundColor(.gray)
            .font(.caption)
    }
    
    // Método para o background do botão
    private func buttonBackground() -> some View {
        RoundedRectangle(cornerRadius: borderRadius)
            .fill(Color.gray.opacity(0.1))
            .overlay(
                RoundedRectangle(cornerRadius: borderRadius)
                    .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
            )
    }
    
    // Método para chamar onSubmit
    private func callOnSubmit() {
        if let onSubmit = self.onSubmit {
            onSubmit()
        }
    }
}

//MARK: - Preview
struct AtomDropdownButton_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }
    
    struct PreviewWrapper: View {
        enum GradientStyle: String, Hashable {
            case linear = "Linear"
            case radial = "Radial"
            case angular = "Angular"
        }
        
        @State var selectedStyle: GradientStyle?
        @State var selectedColor: String?
        
        var body: some View {
            VStack(spacing: 20) {
                // Exemplo com borda e foco
                AtomDropdownButton(
                    selectedOption: $selectedStyle,
                    options: [
                        (GradientStyle.linear, "Linear", "arrow.down.right.circle"),
                        (GradientStyle.radial, "Radial", "arrow.up.and.down.circle"),
                        (GradientStyle.angular, "Angular", "arrow.clockwise.circle")
                    ],
                    placeholder: "Escolha um estilo",
                    onSelect: { style in
                        print("Selecionado: $$style.rawValue)")
                    },
                    borderRadius: 10,
                    border: true,
                    mainIconName: "paintbrush",
                    dropdownIcon: "chevron.down",
                    onSubmit: {
                        // Simular passagem para o próximo campo
                        print("Passando para o próximo campo")
                    }
                )
                .frame(width: 220, height: 40)
                
                Text("Estilo Selecionado: \(selectedStyle?.rawValue ?? "Nenhum")")
                    .padding()
                
                // Exemplo com onSubmit que atualiza outra propriedade
                AtomDropdownButton(
                    selectedOption: $selectedColor,
                    options: [
                        ("red", "Vermelho", "circle.fill"),
                        ("blue", "Azul", "circle.fill"),
                        ("green", "Verde", "circle.fill")
                    ],
                    placeholder: "Escolha uma cor",
                    onSelect: { color in
                        print("Cor selecionada: $$color)")
                    },
                    borderRadius: 16,
                    border: false,
                    mainIconName: "paintpalette",
                    onSubmit: {
                        // Após selecionar cor, abrir automaticamente o dropdown de estilo
                        selectedStyle = nil // Reset para demonstração
                    }
                )
                .frame(width: 220, height: 40)
            }
            .padding()
        }
    }
}
