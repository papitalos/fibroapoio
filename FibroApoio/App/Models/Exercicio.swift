import FirebaseFirestore
import FirebaseFirestoreSwift

struct Exercicio: Codable, AuditFields {
    @DocumentID var id: String?
    
    var createdAt: Timestamp?
    
    /// Array contendo [início, fim, duração] — onde os dois primeiros são `Timestamp` e o terceiro é `Int` (minutos).
    var duracao: [FirestoreData]?
    
    var id_recompensa: DocumentReference?
    var id_usuario: DocumentReference?
    
    var observacoes: String?
    var tipo_exercicio: String?

    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
