//
//  TaskType.swift
//  FluentStep
//

import Foundation

enum TaskType: String, Codable, CaseIterable, Hashable {
    case listening
    case vocab
    case rewriteTranslate
    case speaking

    var displayName: String {
        switch self {
        case .listening: return "Listening"
        case .vocab: return "Vocab"
        case .rewriteTranslate: return "Rewrite/Translate"
        case .speaking: return "Speaking"
        }
    }
}
