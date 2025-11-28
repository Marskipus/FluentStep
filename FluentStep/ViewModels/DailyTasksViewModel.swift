//
//  DailyTasksViewModel.swift
//  FluentStep
//

import Foundation
import SwiftUI
import Combine

@MainActor
final class DailyTasksViewModel: ObservableObject {
    @Published var tasks: [DailyTask] = []

    init() {
        loadToday()
    }

    func loadToday() {
        tasks = [
            DailyTask(type: .listening,
                      title: "Native‑speed Listening",
                      subtitle: "1 short clip · news/culture",
                      iconName: "headphones",
                      tint: .blue),
            DailyTask(type: .vocab,
                      title: "Targeted Vocab",
                      subtitle: "10 exposures · B2→C1 range",
                      iconName: "text.book.closed",
                      tint: .orange),
            DailyTask(type: .rewriteTranslate,
                      title: "Rewrite / Translate",
                      subtitle: "1 challenge · active production",
                      iconName: "pencil.and.outline",
                      tint: .purple),
            DailyTask(type: .speaking,
                      title: "Speaking Prompt",
                      subtitle: "Record + playback",
                      iconName: "mic.fill",
                      tint: .red)
        ]
    }

    func resetToday() {
        for i in tasks.indices {
            tasks[i].completed = false
        }
    }
}
