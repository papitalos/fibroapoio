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
    var backgroundColor: Color = .gray.opacity(0.2)
    var textColor: Color = .black
    var placeholderColor: Color = .gray
    var mainIconName: String = "tag.circle"
    var dropdownIcon: String = "chevron.down"
    
    //MARK: - Init
    init(
        selectedOption: Binding<T?>,
        options: [(option: T, label: String, icon: String?)],
        placeholder: String = "Escolha aqui",
        onSelect: @escaping (T) -> Void,
        borderRadius: CGFloat = 16,
        border: Bool = false,
        backgroundColor: Color = .gray.opacity(0.2),
        textColor: Color = .black,
        placeholderColor: Color = .gray,
        mainIconName: String = "tag.circle",
        dropdownIcon: String = "chevron.down"
    ) {
        self._selectedOption = selectedOption
        self.options = options
        self.placeholder = placeholder
        self.onSelect = onSelect
        self.borderRadius = borderRadius
        self.border = border
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.placeholderColor = placeholderColor
        self.mainIconName = mainIconName
        self.dropdownIcon = dropdownIcon
    }
    
    //MARK: - Body
    var body: some View {
        Menu {
            ForEach(options.indices, id: \.self) { index in
                let option = options[index]
                Button {
                    selectedOption = option.option
                    onSelect(option.option)
                } label: {
                    HStack {
                        Text(option.label)
                        if let iconName = option.icon {
                            Image(systemName: iconName)
                        }
                    }
                }
            }
        } label: {
            HStack {
                // Mostrar o label da opção selecionada ou o placeholder
                if let selected = selectedOption,
                   let selectedItem = options.first(where: { $0.option == selected }) {
                    Text(selectedItem.label)
                        .foregroundColor(textColor)
                } else {
                    Text(placeholder)
                        .foregroundColor(placeholderColor)
                }
                
                Spacer()
                
                Image(systemName: mainIconName)
                    .foregroundColor(textColor)
                Image(systemName: dropdownIcon)
                    .foregroundColor(textColor)
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(backgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
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
        
        var body: some View {
            VStack(spacing: 20) {
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
                    backgroundColor: .blue.opacity(0.1),
                    textColor: .blue,
                    placeholderColor: .gray,
                    mainIconName: "paintbrush",
                    dropdownIcon: "chevron.down"
                )
                .frame(width: 220, height: 40)
                
                Text("Estilo selecionado: $$selectedStyle?.rawValue ?? "Nenhum")")
                    .padding()
                
                // Exemplo com outro tema
                AtomDropdownButton(
                    selectedOption: $selectedStyle,
                    options: [
                        (GradientStyle.linear, "Linear", "arrow.down.right.circle"),
                        (GradientStyle.radial, "Radial", "arrow.up.and.down.circle"),
                        (GradientStyle.angular, "Angular", "arrow.clockwise.circle")
                    ],
                    onSelect: { style in
                        print("Selecionado: $$style.rawValue)")
                    },
                    borderRadius: 16,
                    border: false,
                    backgroundColor: .black.opacity(0.8),
                    textColor: .white,
                    placeholderColor: .gray,
                    mainIconName: "wand.and.stars"
                )
                .frame(width: 220, height: 40)
            }
            .padding()
        }
    }
}