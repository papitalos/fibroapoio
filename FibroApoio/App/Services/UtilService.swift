//
//  UtilService.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 07/05/2025.
//

import Foundation

class UtilService {
    // MARK: - Date

    /// Retorna a data de hoje com hora zerada (00:00:00)
    static var startOfToday: Date {
        return Calendar.current.startOfDay(for: Date())
    }

    /// Retorna a data de hoje com hora máxima (23:59:59)
    static var endOfToday: Date {
        let calendar = Calendar.current
        return calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date()
    }

    /// Retorna o intervalo da semana atual (início e fim)
    static var currentWeekInterval: (startOfWeek: Date, endOfWeek: Date)? {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1

        guard let start = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
              let end = calendar.date(byAdding: .day, value: 6, to: start) else {
            return nil
        }

        let startOfWeek = calendar.startOfDay(for: start)
        let endOfWeek = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!

        return (startOfWeek, endOfWeek)
    }
    
    /// Retorna o intervalo da semana atual estendido (início 2 dias antes do domingo)
    static func extendedWeekInterval(extraDaysBefore: Int = 2) -> (startOfWeek: Date, endOfWeek: Date)? {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let daysToSubtract = weekday - 1 + extraDaysBefore

        guard let start = calendar.date(byAdding: .day, value: -daysToSubtract, to: today),
              let end = calendar.date(byAdding: .day, value: 6, to: start) else {
            return nil
        }

        let startOfWeek = calendar.startOfDay(for: start)
        let endOfWeek = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: end)!

        return (startOfWeek, endOfWeek)
    }


    /// Retorna a data de ontem com hora inicial (00:00:00)
    static var startOfYesterday: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: startOfToday) ?? Date()
    }

    /// Retorna a data de ontem com hora final (23:59:59)
    static var endOfYesterday: Date {
        return Calendar.current.date(byAdding: .second, value: 86399, to: startOfYesterday) ?? Date()
    }

    /// Retorna o índice do dia da semana (0 = domingo)
    static func weekdayIndex(from date: Date) -> Int {
        return Calendar.current.component(.weekday, from: date) - 1
    }
}
