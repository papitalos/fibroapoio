//
//  PainEntryModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 30/04/2025.
//

import SwiftUI

/// Registro de dor em uma zona do corpo
struct PainEntry: Identifiable {
    let id = UUID()
    let zone: BodyZone
    let level: Int
    let side: BodySide
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
    case leftThigh
    case rightThigh
    case leftKnee
    case rightKnee
    case leftShin
    case rightShin
    case leftFoot
    case rightFoot

    /// Nome amigável para exibir ao selecionar
    func displayName(for side: BodySide) -> String {
        switch (self, side) {
        case (.head, .front): return "Frente da Cabeça"
        case (.head, .back): return "Nuca"
        case (.chest, .front): return "Peito"
        case (.chest, .back): return "Costas Superiores"
        case (.abdomen, .front): return "Abdômen"
        case (.abdomen, .back): return "Lombar"
        case (.leftShoulder, .front): return "Frente do Ombro Esquerdo"
        case (.leftShoulder, .back): return "Trás do Ombro Esquerdo"
        case (.rightShoulder, .front): return "Frente do Ombro Direito"
        case (.rightShoulder, .back): return "Trás do Ombro Direito"
        case (.rightElbow, .front): return " Frente do Cotovelo Direito"
        case (.rightElbow, .back): return "Trás do Cotovelo Direito"
        case (.leftElbow, .front): return "Frente do Cotovelo Esquerdo"
        case (.leftElbow, .back): return "Trás do Cotovelo Esquerdo"
        case (.leftHand, .front): return "Frente da Mão Esquerda"
        case (.leftHand, .back): return "Trás da Mão Esquerda"
        case (.leftThigh, .front): return "Frente da Coxa Esquerda"
        case (.leftThigh, .back): return "Trás da Coxa Esquerda"
        case (.rightThigh, .front): return "Frente da Coxa Direita"
        case (.rightThigh, .back): return "Trás da Coxa Direita"
        case (.leftKnee, .front): return "Joelho Esquerdo"
        case (.leftKnee, .back): return "Trás do Joelho Esquerdo"
        case (.rightKnee, .front): return "Joelho Direito"
        case (.rightKnee, .back): return "Trás do Joelho Direito"
        case (.rightShin, .front): return "Frente da Canela Direita"
        case (.rightShin, .back): return "Trás da Canela Direita"
        case (.leftShin, .front): return "Frente da Canela Esquerda"
        case (.leftShin, .back): return "Trás da Canela Esquerda"
        case (.rightFoot, .front): return "Frente do Pé Direito"
        case (.rightFoot, .back): return "Trás do Pé Direito"
        case (.leftFoot, .front): return "Frente do Pé Esquerdo"
        case (.leftFoot, .back): return "Trás do Pé Esquerdo"
        case (.leftHip, .front): return "Frente da Cintura Esquerda"
        case (.leftHip, .back): return "Trás da Cintura Esquerda"
        case (.rightHip, .front): return "Frente da Cintura Direita"
        case (.rightHip, .back): return "Trás da Cintura Direita"
        default: return "Error: unknown zone"
        }
    }
}

// MARK: - Helper

/// Zona posicionada relativamente à imagem
struct Zone: Identifiable {
    let id = UUID()
    let zone: BodyZone
    let x: CGFloat
    let y: CGFloat
}
