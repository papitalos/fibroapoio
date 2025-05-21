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
    var id_usuario: String?
    var local_dor: String?
    var nivel_dor: Int?

    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id, has_pain, id_usuario, local_dor, nivel_dor, createdAt, updatedAt, deletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        has_pain = try container.decodeIfPresent(Bool.self, forKey: .has_pain)
        id_usuario = try container.decodeIfPresent(String.self, forKey: .id_usuario)
        local_dor = try container.decodeIfPresent(String.self, forKey: .local_dor)
        nivel_dor = try container.decodeIfPresent(Int.self, forKey: .nivel_dor)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Timestamp.self, forKey: .deletedAt)
    }
    
    init(
        id: String? = nil,
        has_pain: Bool? = nil,
        id_usuario: String? = nil,
        local_dor: String? = nil,
        nivel_dor: Int? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil,
        deletedAt: Timestamp? = nil
    ) {
        self.id = id
        self.has_pain = has_pain
        self.id_usuario = id_usuario
        self.local_dor = local_dor
        self.nivel_dor = nivel_dor
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(has_pain, forKey: .has_pain)
        try container.encodeIfPresent(id_usuario, forKey: .id_usuario)
        try container.encodeIfPresent(local_dor, forKey: .local_dor)
        try container.encodeIfPresent(nivel_dor, forKey: .nivel_dor)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}
