//
//  UserModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 24/03/2025.
//
import FirebaseFirestore

struct User: Codable, AuditFields{
    // Campos do modelo
    @DocumentID var id: String?
    let identification: String?
    var id_rank: DocumentReference?
    let nome: String?
    let nickname: String?
    var pontuacao: Int?
    var streak_atual: Int?
    var telemovel: String?
    var email: String?
    var data_nascimento: Timestamp?
    var altura_cm: Int?
    var peso_kg: Int?
    var genero: String?
    
    // Auditoria
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}

// Modelo simplificado para UserDefaults
struct UserLocalStorage: Codable {
    var id: String?
    var identification: String?
    var id_rank: String?
    var nome: String?
    var nickname: String?
    var pontuacao: Int?
    var streak_atual: Int?
    var telemovel: String?
    var email: String?
    var data_nascimento: Date?
    var altura_cm: Int?
    var peso_kg: Int?
    var genero: String?
    
    // Campos de auditoria
    var createdAt: Date?
    var updatedAt: Date?
    var deletedAt: Date?
    
    init(from user: User) {
        self.id = user.id
        self.identification = user.identification
        
        // Converter DocumentReference para String (o path é a representação em String)
        self.id_rank = user.id_rank?.path
        
        self.nome = user.nome
        self.nickname = user.nickname
        self.pontuacao = user.pontuacao
        self.streak_atual = user.streak_atual
        self.telemovel = user.telemovel
        self.email = user.email
        self.altura_cm = user.altura_cm
        self.peso_kg = user.peso_kg
        self.genero = user.genero
        
        // Converter Timestamp para Date
        self.createdAt = user.createdAt?.dateValue()
        self.updatedAt = user.updatedAt?.dateValue()
        self.deletedAt = user.deletedAt?.dateValue()
        
        // Converter Timestamp para Date para data_nascimento, se não for nil
        if let timestamp = user.data_nascimento {
            self.data_nascimento = timestamp.dateValue()
        }
    }
    
    // Adicionar método para converter de volta para User
    func toUser() -> User {
        // Criar uma referência a partir do path, se existir
        let rankReference: DocumentReference? = id_rank != nil ?
            Firestore.firestore().document(id_rank!) : nil
            
        var user = User(
            id: id,
            identification: identification,
            id_rank: rankReference,
            nome: nome,
            nickname: nickname,
            pontuacao: pontuacao,
            streak_atual: streak_atual,
            telemovel: telemovel,
            email: email,
            data_nascimento: data_nascimento != nil ? Timestamp(date: data_nascimento!) : nil,
            altura_cm: altura_cm,
            peso_kg: peso_kg,
            genero: genero
        )
        
        // Converter Date para Timestamp para os campos de auditoria
        if let createdAt = createdAt {
            user.createdAt = Timestamp(date: createdAt)
        }
        
        if let updatedAt = updatedAt {
            user.updatedAt = Timestamp(date: updatedAt)
        }
        
        if let deletedAt = deletedAt {
            user.deletedAt = Timestamp(date: deletedAt)
        }
        
        return user
    }
}

