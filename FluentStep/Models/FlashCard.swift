//
//  FlashCard.swift
//  FluentStep
//
//  Created by James Driscoll on 11/28/25.
//

import Foundation

struct FlashCard: Identifiable, Hashable {
    let id = UUID()
    let front: String    // Russian word
    let back: String     // English translation
}
