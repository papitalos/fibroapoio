//
//  ActivityViewModel.swift
//  FibroApoio
//
//  Created by Italo Teofilo Filho on 08/04/2025.
//

import Firebase
import FirebaseFirestore
import SwiftUI
import Combine

class ActivityScreenViewModel: ObservableObject {
    @Published var activityItems: [AtomListItem] = []

    @Service var userService: UserService
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Data Reactive
    init() {
        userService.$weeklyData
            .receive(on: DispatchQueue.main)
            .sink { data in
                self.activityItems = self.createActivityItems(from: data)
            }
            .store(in: &cancellables)
    }

    func load() {
        let data = userService.weeklyData
        self.activityItems = self.createActivityItems(from: data)
    }

    func createActivityItems(from data: UserWeeklyData) -> [AtomListItem] {
            var items: [AtomListItem] = []

            for ex in data.exercicios {
                if let date = ex.createdAt?.dateValue() {
                    items.append(AtomListItem(
                        title: ex.tipo ?? "Exercício",
                        subtitle: Self.relativeDate(from: date),
                        subtitleDate: date,
                        image: Image(systemName: "dumbbell.fill"),
                        tag: nil,
                        tagBackgroundColor: nil,
                        tagTextColor: nil,
                        imageBackground: .purple.opacity(0.3),
                        actions: []
                    ))
                }
            }

            for dor in data.dores {
                if let date = dor.createdAt?.dateValue() {
                    items.append(AtomListItem(
                        title: "Registro de Dor",
                        subtitle: Self.relativeDate(from: date),
                        subtitleDate: date,
                        image: Image(systemName: "bandage.fill"),
                        tag: nil,
                        tagBackgroundColor: nil,
                        tagTextColor: nil,
                        imageBackground: .red.opacity(0.3),
                        actions: []
                    ))
                }
            }

            for checkin in data.checkins {
                guard checkin.status_streak != -1 else { continue }
                if let date = checkin.createdAt?.dateValue() {
                    let title: String = switch checkin.status_streak {
                    case 0: "Perdeu sequência"
                    case 1: "Check-in Diário"
                    case 2: "Sequência Congelada"
                    default: "Check-in"
                    }

                    items.append(AtomListItem(
                        title: title,
                        subtitle: Self.relativeDate(from: date),
                        subtitleDate: date,
                        image: Image(systemName: "calendar"),
                        tag: nil,
                        tagBackgroundColor: nil,
                        tagTextColor: nil,
                        imageBackground: .green.opacity(0.3),
                        actions: []
                    ))
                }
            }

            for med in data.medicacoes {
                if let date = med.createdAt?.dateValue() {
                    items.append(AtomListItem(
                        title: med.nome ?? "Medicação",
                        subtitle: Self.relativeDate(from: date),
                        subtitleDate: date,
                        image: Image(systemName: "pills.fill"),
                        tag: nil,
                        tagBackgroundColor: nil,
                        tagTextColor: nil,
                        imageBackground: .blue.opacity(0.3),
                        actions: []
                    ))
                }
            }
        for item in items.sorted(by: { ($0.subtitleDate ?? .distantPast) > ($1.subtitleDate ?? .distantPast) }) {
            print("🧪 Item: \(item.title), data: \(item.subtitleDate ?? .distantPast)")
        }

            return items
                .sorted(by: { ($0.subtitleDate ?? .distantPast) > ($1.subtitleDate ?? .distantPast) })
                .prefix(70)
                .map { $0 }
    }

    private static func relativeDate(from date: Date) -> String {
        let now = Date()
        let diff = now.timeIntervalSince(date)
        if diff < 60 {
            return "agora mesmo"
        } else if diff < 3600 {
            return "\(Int(diff / 60))min atrás"
        } else if diff < 86400 {
            return "\(Int(diff / 3600))h atrás"
        } else {
            return "\(Int(diff / 86400))d atrás"
        }
    }
}
