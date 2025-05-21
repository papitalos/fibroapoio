//
//  LocalStorageService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 26/03/2025.
//

import FirebaseFirestore
import Foundation

class LocalStorageService {
    private let userDefaults = UserDefaults.standard
    private let lastAccessDateKey = "lastAccessDate"

    init() {
        let now = Date()
        if let lastAccessDate = loadLastAccessDate() {
            if !Calendar.current.isDate(lastAccessDate, inSameDayAs: now) {
                print("📅 Novo dia detectado. Limpando cache local.")
                resetAll()
            } else {
                print("✅ Mesmo dia, mantendo cache.")
            }
        } else {
            print("📅 Nenhum acesso anterior registrado.")
        }

        saveLastAccessDate(now)
    }


    // MARK: - Welcome Screen
    private let hasSeenWelcomeScreenKey = "hasSeenWelcomeScreen"

    func saveWelcomeScreenState(hasSeen: Bool) {
        userDefaults.set(hasSeen, forKey: hasSeenWelcomeScreenKey)
    }

    func hasSeenWelcomeScreen() -> Bool {
        return userDefaults.bool(forKey: hasSeenWelcomeScreenKey)
    }

    func resetWelcomeScreenState() {
        userDefaults.removeObject(forKey: hasSeenWelcomeScreenKey)
    }

    // MARK: - User
    private let userKey = "currentUser"

    func saveUser(user: User) {
        let localUser = UserLocalStorage(from: user)
        if let encoded = try? JSONEncoder().encode(localUser) {
            userDefaults.set(encoded, forKey: userKey)
        } else {
            print("‼️ Erro ao salvar User no localStorage.")
        }
    }

    func loadUser() -> User? {
        guard let data = userDefaults.data(forKey: userKey),
              let localUser = try? JSONDecoder().decode(UserLocalStorage.self, from: data) else {
            return nil
        }
        return localUser.toUser()
    }

    func deleteUser() {
        userDefaults.removeObject(forKey: userKey)
    }

    // MARK: - Weekly Data
    private let weeklyDataKey = "userWeeklyData"

    func saveWeeklyData(_ data: UserWeeklyData) {
        if let encoded = try? JSONEncoder().encode(data) {
            userDefaults.set(encoded, forKey: weeklyDataKey)
        } else {
            print("‼️ Erro ao salvar dados semanais.")
        }
    }

    func loadWeeklyData() -> UserWeeklyData? {
        guard let data = userDefaults.data(forKey: weeklyDataKey),
              let decoded = try? JSONDecoder().decode(UserWeeklyData.self, from: data) else {
            return nil
        }
        return decoded
    }

    func deleteWeeklyData() {
        userDefaults.removeObject(forKey: weeklyDataKey)
    }
    
    // MARK: - Weekly Data Timestamp
    private let weeklyDataDateKey = "userWeeklyDataDate"

    func saveWeeklyDataDate(_ date: Date) {
        userDefaults.set(date, forKey: weeklyDataDateKey)
    }

    func loadWeeklyDataDate() -> Date? {
        return userDefaults.object(forKey: weeklyDataDateKey) as? Date
    }

    func deleteWeeklyDataDate() {
        userDefaults.removeObject(forKey: weeklyDataDateKey)
    }
    
    //MARK: - Last Access
    private func saveLastAccessDate(_ date: Date) {
        userDefaults.set(date, forKey: lastAccessDateKey)
    }

    private func loadLastAccessDate() -> Date? {
        return userDefaults.object(forKey: lastAccessDateKey) as? Date
    }

    private func deleteLastAccessDate() {
        userDefaults.removeObject(forKey: lastAccessDateKey)
    }

    
    // MARK: - Reset All
    func resetAll() {
        deleteUser()
        deleteWeeklyData()
        deleteWeeklyDataDate()
        resetWelcomeScreenState()
        deleteLastAccessDate()
    }

}
