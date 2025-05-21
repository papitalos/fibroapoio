//
//  Exercicio.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 23/04/2025.
//


import FirebaseFirestore

struct Exercicio: Codable, AuditFields {
    @DocumentID var id: String?

    var duracao_inicio: Timestamp?
    var duracao_fim: Timestamp?
    var duracao_minutos: Int?

    var id_recompensa: DocumentReference?
    var id_usuario: DocumentReference?

    var observacoes: String?
    var tipo_exercicio: String?

    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
