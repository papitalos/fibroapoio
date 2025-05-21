import FirebaseFirestore
import FirebaseFirestoreSwift

struct HistoricoPeso: Codable, AuditFields {
    @DocumentID var id: String?
    var data_registro: Timestamp?
    var id_usuario: DocumentReference?
    var peso_kg: Double? // ou Int, se quiser manter como inteiro (mas Double é mais flexível)

    // Campos de auditoria
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
