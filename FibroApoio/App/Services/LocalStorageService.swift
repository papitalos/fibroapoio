//
//  LocalStorageService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//


import Foundation

class LocalStorageService {
    
    // MARK: - User
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"

    func saveUser(user: Usuario) {
        if let encodedData = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedData, forKey: userKey)
            print("Usuário salvo no LocalStorage")
        } else {
            print("Erro ao salvar usuário não sensível no LocalStorage")
        }
    }

    func loadUser() -> Usuario? {
        if let encodedData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(Usuario.self, from: encodedData) {
            print("Usuário carregado do LocalStorage")
            return user
        } else {
            print("Usuário encontrado no LocalStorage")
            return nil
        }
    }

    func deleteUser() {
        userDefaults.removeObject(forKey: userKey)
        print("Usuário removido do LocalStorage")
    }
}
