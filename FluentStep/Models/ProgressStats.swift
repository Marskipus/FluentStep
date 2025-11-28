//
//  ProgressStats.swift
//  FluentStep
//

import Foundation

struct ProgressStats: Codable, Hashable {
    var daysActive: Int = 0
    var listeningClipsCompleted: Int = 0
    var vocabExposures: Int = 0
    var productionTasksCompleted: Int = 0
}
