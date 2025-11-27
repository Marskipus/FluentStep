//
//  ProgressViewModel.swift
//  FluentStep
//

import Foundation
import Combine

@MainActor
final class ProgressViewModel: ObservableObject {
    @Published private(set) var stats: ProgressStats

    init() {
        self.stats = Self.load()
    }

    func seedDemoData() {
        stats.daysActive += 1
        stats.listeningClipsCompleted += 1
        stats.vocabExposures += 10
        stats.productionTasksCompleted += 2
        Self.save(stats)
        objectWillChange.send()
    }

    // MARK: - Persistence (very simple for MVP)

    private static let key = "ProgressStats"

    static func load() -> ProgressStats {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode(ProgressStats.self, from: data) {
            return decoded
        }
        return ProgressStats()
    }

    static func save(_ stats: ProgressStats) {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    static func resetAllProgress() {
        let empty = ProgressStats()
        save(empty)
    }
}
