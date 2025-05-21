//
//  PainEntry 2.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 30/04/2025.
//


/// Registro de dor em uma zona do corpo
struct PainEntry: Identifiable {
    let id = UUID()
    let zone: BodyZone
    let level: Int
}

/// Lado do corpo: frente ou trás
enum BodySide: String {
    case front
    case back
}

/// Zonas clicáveis do corpo
enum BodyZone: String, CaseIterable, Identifiable {
    var id: String { rawValue }
    case head
    case leftShoulder
    case rightShoulder
    case leftElbow
    case rightElbow
    case leftHand
    case rightHand
    case chest
    case abdomen
    case leftHip
    case rightHip
    case leftKnee
    case rightKnee
    case leftFoot
    case rightFoot

    /// Nome amigável para exibir ao selecionar
    var displayName: String {
        switch self {
        case .head: return "Cabeça"
        case .leftShoulder: return "Ombro Esquerdo"
        case .rightShoulder: return "Ombro Direito"
        case .leftElbow: return "Cotovelo Esquerdo"
        case .rightElbow: return "Cotovelo Direito"
        case .leftHand: return "Mão Esquerda"
        case .rightHand: return "Mão Direita"
        case .chest: return "Peito"
        case .abdomen: return "Abdômen"
        case .leftHip: return "Quadril Esquerdo"
        case .rightHip: return "Quadril Direito"
        case .leftKnee: return "Joelho Esquerdo"
        case .rightKnee: return "Joelho Direito"
        case .leftFoot: return "Pé Esquerdo"
        case .rightFoot: return "Pé Direito"
        }
    }
}

// MARK: - Helper

/// Zona posicionada relativamente à imagem
private struct Zone: Identifiable {
    let id = UUID()
    let zone: BodyZone
    let x: CGFloat
    let y: CGFloat
}