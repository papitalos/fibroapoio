//
//  Medicacao.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 23/04/2025.
//

import FirebaseFirestore

struct Medicacao: Codable, AuditFields {
    @DocumentID var id: String?
    var data_consumo: Timestamp?
    var id_usuario: String?
    var nome: String?
    var observacoes: String?
    var periodo: Int?

    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id, data_consumo, id_usuario, nome, observacoes, periodo, createdAt, updatedAt, deletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        data_consumo = try container.decodeIfPresent(Timestamp.self, forKey: .data_consumo)
        id_usuario = try container.decodeIfPresent(String.self, forKey: .id_usuario)
        nome = try container.decodeIfPresent(String.self, forKey: .nome)
        observacoes = try container.decodeIfPresent(String.self, forKey: .observacoes)
        periodo = try container.decodeIfPresent(Int.self, forKey: .periodo)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Timestamp.self, forKey: .deletedAt)
    }

    init(
        id: String? = nil,
        data_consumo: Timestamp? = nil,
        id_usuario: String? = nil,
        nome: String? = nil,
        observacoes: String? = nil,
        periodo: Int? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil,
        deletedAt: Timestamp? = nil
    ) {
        self.id = id
        self.data_consumo = data_consumo
        self.id_usuario = id_usuario
        self.nome = nome
        self.observacoes = observacoes
        self.periodo = periodo
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(data_consumo, forKey: .data_consumo)
        try container.encodeIfPresent(id_usuario, forKey: .id_usuario)
        try container.encodeIfPresent(nome, forKey: .nome)
        try container.encodeIfPresent(observacoes, forKey: .observacoes)
        try container.encodeIfPresent(periodo, forKey: .periodo)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}
