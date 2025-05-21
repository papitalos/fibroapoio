import SwiftUI

struct AtomListItem: Identifiable {
    let id = UUID() // Identificação única
    let title: String
    let subtitle: String?
    let image: Image?
    let tag: String?
    let actions: [(name: String, action: () -> Void)] // Array de ações
}