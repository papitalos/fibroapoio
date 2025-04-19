//
//  LocalStorageService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import FirebaseFirestore
import Foundation

class LocalStorageService {
    // MARK: - Welcome Screen
    private let hasSeenWelcomeScreenKey = "hasSeenWelcomeScreen"

    /// Salva o estado de visualização da tela de boas-vindas
    func saveWelcomeScreenState(hasSeen: Bool) {
           print("\n- SALVANDO ESTADO DA TELA DE BOAS-VINDAS -")
           userDefaults.set(hasSeen, forKey: hasSeenWelcomeScreenKey)
           print(" RESULTADO: \(hasSeen ? "Usuário já viu a tela de boas-vindas ✅" : "Estado resetado para não visto 🔁")")
    }
    
    /// Verifica se o usuário já viu a tela de boas-vindas
    func hasSeenWelcomeScreen() -> Bool {
           let hasSeen = userDefaults.bool(forKey: hasSeenWelcomeScreenKey)
           print("\n- VERIFICANDO ESTADO DA TELA DE BOAS-VINDAS -")
           print(" RESULTADO: \(hasSeen ? "Usuário já viu a tela de boas-vindas ✅" : "Usuário ainda não viu a tela de boas-vindas ⚠️")")
           return hasSeen
    }
    
    /// Reseta o estado da tela de boas-vindas (para testes ou quando necessário)
    func resetWelcomeScreenState() {
        print("\n- RESETANDO ESTADO DA TELA DE BOAS-VINDAS -")
        userDefaults.removeObject(forKey: hasSeenWelcomeScreenKey)
        print(" RESULTADO: Estado resetado 🔁")
    }
    
    // MARK: - User
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"

    func saveUser(user: User) {
        print("\n- SALVANDO USUÁRIO DO LOCALSTORAGE - ")
        let localUser = UserLocalStorage(from: user)

        if let encodedData = try? JSONEncoder().encode(localUser) {
            userDefaults.set(encodedData, forKey: userKey)
            print(" RESULTADO: Salvo ✅\n ID: \(String(describing: localUser.id)) ")
            
        } else {
            print(" RESULTADO: Falha ao salvar usuário no LocalStorage ‼️")
        }
    }

    func loadUser() -> User? {
        print("\n - PROCURANDO USUÁRIO DO LOCALSTORAGE - ")
        
        if let encodedData = userDefaults.data(forKey: userKey),
           let localUser = try? JSONDecoder().decode(UserLocalStorage.self, from: encodedData) {
            print(" RESULTADO: Encontrado ✅\n ID: \(String(describing: localUser.id)) ")
            
            return User(
               id: localUser.id,
               identification: nil,
               id_rank: nil,
               nome: localUser.nome,
               nickname: localUser.nickname,
               pontuacao: localUser.pontuacao,
               streak_atual: localUser.streak_atual,
               telemovel: nil,
               email: localUser.email,
               data_nascimento: nil,
               altura_cm: localUser.altura_cm,
               genero: localUser.genero,
               createdAt: localUser.createdAt != nil ? Timestamp(date: localUser.createdAt!) : nil,
                   updatedAt: localUser.updatedAt != nil ? Timestamp(date: localUser.updatedAt!) : nil,
                   deletedAt: localUser.deletedAt != nil ? Timestamp (date: localUser.deletedAt!) : nil
           )
        } else {
            print(" RESULTADO: Não Encontrado ⚠️")
            return nil
        }
    }

    func deleteUser() {
        userDefaults.removeObject(forKey: userKey)
    }
}
