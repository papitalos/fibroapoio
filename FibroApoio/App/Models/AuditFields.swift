//
//  AuditFields.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 18/04/2025.
//


import FirebaseFirestore
import Foundation

protocol AuditFields: Codable {
    var createdAt: Timestamp? { get set }
    var updatedAt: Timestamp? { get set }
    var deletedAt: Timestamp? { get set }
}

extension AuditFields {
    var isSoftDeleted: Bool {
        return deletedAt != nil
    }
}

extension Timestamp {
    /// Converte um Timestamp do Firebase para uma string formatada no estilo "17 de dezembro de 2024"
    func toFormattedDateString(locale: Locale = Locale(identifier: "pt_BR")) -> String {
        let date = self.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = "d 'de' MMMM 'de' yyyy"
        
        return dateFormatter.string(from: date)
    }
    
    /// Versão que permite personalizar o formato
    func toFormattedString(with format: String = "d 'de' MMMM 'de' yyyy",
                           locale: Locale = Locale(identifier: "pt_BR")) -> String {
        let date = self.dateValue()
        
        let dateFormatter = DateFormatter()
        dateFormatter.locale = locale
        dateFormatter.dateFormat = format
        
        return dateFormatter.string(from: date)
    }
}
