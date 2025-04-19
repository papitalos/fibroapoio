import FirebaseFirestore

protocol AuditFields: Codable {
    var createdAt: Timestamp? { get set }
    var updatedAt: Timestamp? { get set }
    var deletedAt: Timestamp? { get set }
}