//
//  RankModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 24/03/2025.
//

import FirebaseFirestore
import Combine

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

extension Rank {
    /// Retorna o nome, ou string vazia se for nulo.
    func getName() -> String {
        return self.nome ?? ""
    }
}

extension Publisher where Output == Rank?, Failure == Error {
    /// Mapeia `Rank?` para `String` (usando `Rank.getName()`) e nunca falha.
    func getName() -> AnyPublisher<String, Never> {
        self
            .map { $0?.getName() ?? "" }
            .replaceError(with: "")
            .eraseToAnyPublisher()
    }
}
