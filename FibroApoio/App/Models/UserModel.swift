//
//  UserModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 24/03/2025.
//
import FirebaseFirestore

struct Usuario: Codable {
    let identification: String? //Id é o do governo
    let id_rank: DocumentReference?
    let nome: String?
    let nickname: String?
    var pontuacao: Int?
    var streak_atual: Int?
    var telemovel: String?
    var email: String?
    var data_nascimento: Timestamp?
    var altura_cm: Int?
    var genero: String?
}
