import Foundation

class LocalStorageService {
    private let userDefaults = UserDefaults.standard
    private let userKey = "currentUser"

    func saveUser(user: Usuario) {
        if let encodedData = try? JSONEncoder().encode(user) {
            userDefaults.set(encodedData, forKey: userKey)
            print("Usuário salvo no LocalStorage")
        } else {
            print("Erro ao salvar usuário no LocalStorage")
        }
    }

    func loadUser() -> Usuario? {
        if let encodedData = userDefaults.data(forKey: userKey),
           let user = try? JSONDecoder().decode(Usuario.self, from: encodedData) {
            print("Usuário carregado do LocalStorage")
            return user
        } else {
            print("Usuário não encontrado no LocalStorage")
            return nil
        }
    }

    func deleteUser() {
        userDefaults.removeObject(forKey: userKey)
        print("Usuário removido do LocalStorage")
    }
}