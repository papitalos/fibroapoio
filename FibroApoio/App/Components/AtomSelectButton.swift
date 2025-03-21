import SwiftUI

struct AtomSelectButton: View {
    //MARK: - Properties
    // State
    enum Selection {
        case left, right
    }

    @Binding var selection: Selection

    // Configurações
    let buttons: [(String, () -> Void)] // Array de tuples para garantir a ordem
    

    // Estilos
    var borderRadius: CGFloat = 16
    var border: Bool = false
    var mainBackgroundColor: Color = .gray.opacity(0.2)
    var buttonBackgroundColor: Color = .gray.opacity(0.5)
    var buttonTextColor: Color = .black
    var unselectedTextColor: Color = .gray

    //MARK: - Init

    init(
        selection: Binding<Selection>,
        buttons: [(String, () -> Void)],
        borderRadius: CGFloat = 16,
        border: Bool = false,
        mainBackgroundColor: Color = .gray.opacity(0.2),
        buttonBackgroundColor: Color = .gray.opacity(0.5),
        buttonTextColor: Color = .black,
        unselectedTextColor: Color = .gray
    ) {
        self._selection = selection
        self.buttons = buttons
        self.borderRadius = borderRadius
        self.border = border
        self.mainBackgroundColor = mainBackgroundColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonTextColor = buttonTextColor
        self.unselectedTextColor = unselectedTextColor
    }

    //MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Retângulo de fundo com borderRadius
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(mainBackgroundColor)
                    .frame(height: geometry.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
                    )

                // Retângulo do botão selecionado
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(buttonBackgroundColor)
                    .frame(
                        width: geometry.size.width / CGFloat(buttons.count),
                        height: geometry.size.height
                    )
                    .offset(x: selection == .left ? 0 : (buttons.count > 1 ? geometry.size.width / CGFloat(buttons.count) : 0))
                    .animation(.easeInOut(duration: 0.3), value: selection)

                // Toggle Button
                HStack(spacing: 0) {
                    if buttons.count > 0 {
                        // Left button
                        Button(action: {
                            withAnimation {
                                selection = .left
                                buttons[0].1() // Executa a ação do primeiro botão
                            }
                        }) {
                            Text(buttons[0].0) // Exibe o título do primeiro botão
                                .foregroundColor(selection == .left ? buttonTextColor : unselectedTextColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(
                            width: geometry.size.width / CGFloat(buttons.count),
                            height: geometry.size.height
                        )
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }

                    if buttons.count > 1 {
                        // Right button
                        Button(action: {
                            withAnimation {
                                selection = .right
                                buttons[1].1() // Executa a ação do segundo botão
                            }
                        }) {
                            Text(buttons[1].0) // Exibe o título do segundo botão
                                .foregroundColor(selection == .right ? buttonTextColor : unselectedTextColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(
                            width: geometry.size.width / CGFloat(buttons.count),
                            height: geometry.size.height
                        )
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .contentShape(Rectangle())
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(width: 200, height: 32)
    }
}

//MARK: - Preview

struct AtomSelectButton_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State var selection1: AtomSelectButton.Selection = .left
        @State var selection2: AtomSelectButton.Selection = .left

        var body: some View {
            VStack {
                AtomSelectButton(
                    selection: $selection1,
                    buttons: [
                        ("Opção A", { print("Opção A selecionada") }),
                        ("Opção B", { print("Opção B selecionada") }),
                    ],
                    borderRadius: 5,
                    border: true,
                    buttonBackgroundColor: .blue,
                    buttonTextColor: .white
                )
                AtomSelectButton(
                    selection: $selection2,
                    buttons: [
                        ("Única", { print("Única opção") })
                    ],
                    borderRadius: 5,
                    border: true,
                    buttonBackgroundColor: .green,
                    buttonTextColor: .white
                )
                
                Text("Selection \(selection1)")
            }
        }
    }
}
