//
//  Dor.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 23/04/2025.
//

import FirebaseFirestore

struct Dor: Codable, AuditFields {
    @DocumentID var id: String?
    var has_pain: Bool?
    var id_recompensa: DocumentReference?
    var id_usuario: DocumentReference?
    var local_dor: String?
    var nivel_dor: Int?
    var observacoes: String?
    var regiao_corpo: String?

    // Campos de auditoria
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
