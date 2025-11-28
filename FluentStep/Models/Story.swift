//
//  Story.swift
//  FluentStep
//

import Foundation

struct Story: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let words: [StoryWord]   // tokenized words with optional translations
    let quiz: [StoryQuizQuestion]
}

struct StoryWord: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let translation: String? // nil if not found in mini-dictionary
    let isPunctuation: Bool
}

struct StoryQuizQuestion: Identifiable, Hashable {
    let id = UUID()
    let prompt: String
    let options: [String]
    let correctIndex: Int
}
