//
//  Checkin.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 21/04/2025.
//


import FirebaseFirestore

struct Checkin: Codable, AuditFields {
    @DocumentID var id: String?
    var id_usuario: String?
    var status_streak: Int?

    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id, id_usuario, status_streak, createdAt, updatedAt, deletedAt
    }

    
    init(id: String? = nil,
         id_usuario: String? = nil,
         status_streak: Int? = nil,
         createdAt: Timestamp? = nil,
         updatedAt: Timestamp? = nil,
         deletedAt: Timestamp? = nil) {
        self.id = id
        self.id_usuario = id_usuario
        self.status_streak = status_streak
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }


    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id_usuario, forKey: .id_usuario)
        try container.encodeIfPresent(status_streak, forKey: .status_streak)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}
