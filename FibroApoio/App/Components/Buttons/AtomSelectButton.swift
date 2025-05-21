import SwiftUI

struct AtomSelectButton: View {
    // MARK: - Properties
    enum Selection {
        case left, right
    }

    @Binding var selection: Selection

    let buttons: [(String, () -> Void)]

    // Configurações visuais
    var borderRadius: CGFloat
    var border: Bool
    var mainBackgroundColor: Color
    var buttonBackgroundColor: Color
    var buttonTextColor: Color

    // MARK: - Init
    init(
        selection: Binding<Selection>,
        buttons: [(String, () -> Void)],
        borderRadius: CGFloat = 16,
        border: Bool = false,
        mainBackgroundColor: Color = .gray.opacity(0.2),
        buttonBackgroundColor: Color = .gray.opacity(0.5),
        buttonTextColor: Color = .black,
    ) {
        self._selection = selection
        self.buttons = buttons
        self.borderRadius = borderRadius
        self.border = border
        self.mainBackgroundColor = mainBackgroundColor
        self.buttonBackgroundColor = buttonBackgroundColor
        self.buttonTextColor = buttonTextColor
    }

    // MARK: - Body
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Fundo principal
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(mainBackgroundColor)
                    .frame(height: geometry.size.height)
                    .overlay(
                        RoundedRectangle(cornerRadius: borderRadius)
                            .stroke(border ? Color.gray : Color.clear, lineWidth: 1)
                    )

                // Indicador do botão selecionado
                RoundedRectangle(cornerRadius: borderRadius)
                    .fill(buttonBackgroundColor)
                    .frame(
                        width: geometry.size.width / CGFloat(buttons.count),
                        height: geometry.size.height
                    )
                    .offset(x: selection == .left ? 0 : geometry.size.width / CGFloat(buttons.count))
                    .animation(.easeInOut(duration: 0.3), value: selection)

                HStack(spacing: 0) {
                    // Botão esquerdo (se existir)
                    if buttons.indices.contains(0) {
                        Button(action: {
                            withAnimation {
                                selection = .left
                                buttons[0].1()
                            }
                        }) {
                            Text(buttons[0].0)
                                .foregroundColor(buttonTextColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: geometry.size.width / CGFloat(buttons.count),
                               height: geometry.size.height)
                        // fundo do não-selecionado
                        .background(Color.clear)
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }

                    // Botão direito (se existir)
                    if buttons.indices.contains(1) {
                        Button(action: {
                            withAnimation {
                                selection = .right
                                buttons[1].1()
                            }
                        }) {
                            Text(buttons[1].0)
                                .foregroundColor(buttonTextColor)
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .frame(width: geometry.size.width / CGFloat(buttons.count),
                               height: geometry.size.height)
                        .background(Color.clear)
                        .contentShape(Rectangle())
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
        .frame(width: 200, height: 32)
    }
}

// MARK: - Preview

struct AtomSelectButton_Preview: PreviewProvider {
    static var previews: some View {
        PreviewWrapper()
    }

    struct PreviewWrapper: View {
        @State private var sel1: AtomSelectButton.Selection = .left
        @State private var sel2: AtomSelectButton.Selection = .left

        var body: some View {
            VStack(spacing: 20) {
                AtomSelectButton(
                    selection: $sel1,
                    buttons: [
                        ("Opção A", { print("A") }),
                        ("Opção B", { print("B") })
                    ],
                    borderRadius: 8,
                    border: true,
                    mainBackgroundColor: .yellow.opacity(0.3),
                    buttonBackgroundColor: .blue,
                    buttonTextColor: .white
                )
                Text("Selecionado: \(sel1 == .left ? "A" : "B")")
            }
            .padding()
        }
    }
}
