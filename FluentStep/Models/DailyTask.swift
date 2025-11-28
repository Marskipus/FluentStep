//
//  DailyTask.swift
//  FluentStep
//

import Foundation
import SwiftUI

struct DailyTask: Identifiable, Hashable {
    let id = UUID()
    let type: TaskType
    let title: String
    let subtitle: String
    let iconName: String
    let tint: Color
    var completed: Bool = false
}
