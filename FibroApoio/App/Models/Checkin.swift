import FirebaseFirestore
import FirebaseFirestoreSwift

struct Checkin: Codable, AuditFields {
    @DocumentID var id: String?
    var data_checkin: Timestamp?
    var id_usuario: DocumentReference?
    var id_recompensa: DocumentReference?
    var status_streak: Int?
    
    // Auditoria (opcional, se quiser aplicar no checkin também)
    var createdAt: Timestamp?
    var updatedAt: Timestamp?
    var deletedAt: Timestamp?
}
