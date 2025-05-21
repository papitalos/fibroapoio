import FirebaseFirestore

struct Exercicio: Codable, AuditFields {
    var id: String?
    var id_usuario: String?
    var tipo: String?
    var duracao_inicio: Timestamp?
    var duracao_fim: Timestamp?
    var duracao_minutos: Int?
    var observacoes: String?

    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?

    enum CodingKeys: String, CodingKey {
        case id
        case id_usuario
        case tipo
        case duracao_inicio
        case duracao_fim
        case duracao_minutos
        case observacoes
        case createdAt
        case updatedAt
        case deletedAt
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        id_usuario = try container.decodeIfPresent(String.self, forKey: .id_usuario)
        tipo = try container.decodeIfPresent(String.self, forKey: .tipo)
        duracao_inicio = try container.decodeIfPresent(Timestamp.self, forKey: .duracao_inicio)
        duracao_fim = try container.decodeIfPresent(Timestamp.self, forKey: .duracao_fim)
        duracao_minutos = try container.decodeIfPresent(Int.self, forKey: .duracao_minutos)
        observacoes = try container.decodeIfPresent(String.self, forKey: .observacoes)
        createdAt = try container.decodeIfPresent(Timestamp.self, forKey: .createdAt)
        updatedAt = try container.decodeIfPresent(Timestamp.self, forKey: .updatedAt)
        deletedAt = try container.decodeIfPresent(Timestamp.self, forKey: .deletedAt)
    }

    init(
        id: String? = nil,
        id_usuario: String? = nil,
        tipo: String? = nil,
        duracao_inicio: Timestamp? = nil,
        duracao_fim: Timestamp? = nil,
        duracao_minutos: Int? = nil,
        observacoes: String? = nil,
        createdAt: Timestamp? = nil,
        updatedAt: Timestamp? = nil,
        deletedAt: Timestamp? = nil
    ) {
        self.id = id
        self.id_usuario = id_usuario
        self.tipo = tipo
        self.duracao_inicio = duracao_inicio
        self.duracao_fim = duracao_fim
        self.duracao_minutos = duracao_minutos
        self.observacoes = observacoes
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encodeIfPresent(id, forKey: .id)
        try container.encodeIfPresent(id_usuario, forKey: .id_usuario)
        try container.encodeIfPresent(tipo, forKey: .tipo)
        try container.encodeIfPresent(duracao_inicio, forKey: .duracao_inicio)
        try container.encodeIfPresent(duracao_fim, forKey: .duracao_fim)
        try container.encodeIfPresent(duracao_minutos, forKey: .duracao_minutos)
        try container.encodeIfPresent(observacoes, forKey: .observacoes)
        try container.encodeIfPresent(createdAt, forKey: .createdAt)
        try container.encodeIfPresent(updatedAt, forKey: .updatedAt)
        try container.encodeIfPresent(deletedAt, forKey: .deletedAt)
    }
}
