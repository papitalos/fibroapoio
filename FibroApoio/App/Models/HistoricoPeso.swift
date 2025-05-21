//
//  HistoricoPeso.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 22/04/2025.
//

import FirebaseFirestore

struct HistoricoPeso: Codable, AuditFields {
    @DocumentID var id: String?
    var data_registro: Timestamp?
    var id_usuario: String?
    var peso_kg: Double?

    // Campos de auditoria
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
