//
//  RankModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 24/03/2025.
//
import FirebaseFirestore

struct Rank: Codable, AuditFields {
    // Campos do modelo
    @DocumentID var id: String?
    let nome: String?
    let pontuacao_min: Int?
    let top_min: Int?
    
    // Auditoria
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
