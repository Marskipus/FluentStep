//
//  FlashCardsViewModel.swift
//  FluentStep
//
//  Created by James Driscoll on 11/28/25.
//

import Foundation
import Combine
@MainActor
class FlashCardsViewModel: ObservableObject {
    @Published var cards: [FlashCard] = []
    @Published var currentIndex: Int = 0

    init() {
        loadCards()
    }

    func loadCards() {
        cards = [
            FlashCard(front: "магазин", back: "store"),
            FlashCard(front: "вопрос", back: "question"),
            FlashCard(front: "решать", back: "to solve"),
            FlashCard(front: "общество", back: "society"),
            FlashCard(front: "случай", back: "case, incident"),
            FlashCard(front: "сравнивать", back: "to compare"),
            FlashCard(front: "экономика", back: "economy"),
            FlashCard(front: "предлагать", back: "to offer, suggest"),
            FlashCard(front: "путешествие", back: "journey, travel"),
            FlashCard(front: "появляться", back: "to appear"),
            FlashCard(front: "разный", back: "different"),
            FlashCard(front: "статья", back: "article"),
            FlashCard(front: "выбирать", back: "to choose"),
            FlashCard(front: "использовать", back: "to use"),
            FlashCard(front: "помнить", back: "to remember"),
            FlashCard(front: "разрешать", back: "to allow, permit"),
            FlashCard(front: "быстро", back: "quickly"),
            FlashCard(front: "внимание", back: "attention"),
            FlashCard(front: "ситуация", back: "situation"),
            FlashCard(front: "представлять", back: "to imagine, introduce"),
        ]
        shuffle()
    }

    func shuffle() {
        cards.shuffle()
        currentIndex = 0
    }

    func reset() {
        currentIndex = 0
    }

    func next() {
        if currentIndex < cards.count - 1 {
            currentIndex += 1
        }
    }

    func previous() {
        if currentIndex > 0 {
            currentIndex -= 1
        }
    }
}
