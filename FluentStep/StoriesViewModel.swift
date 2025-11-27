//
//  StoriesViewModel.swift
//  FluentStep
//

import Foundation
import Combine

@MainActor
final class StoriesViewModel: ObservableObject {
    @Published private(set) var stories: [Story] = []

    init() {
        loadStories()
    }

    func loadStories() {
        stories = [
            Self.makeStory1(),
            Self.makeStory2(),
            Self.makeStory3()
        ]
    }
}

// MARK: - Sample content builders
private extension StoriesViewModel {
    static func tokenize(_ text: String, dict: [String: String]) -> [StoryWord] {
        let separators = CharacterSet.whitespacesAndNewlines
        var result: [StoryWord] = []

        let roughTokens = text.components(separatedBy: separators).filter { !$0.isEmpty }
        for token in roughTokens {
            if let last = token.last, ",.!?:;".contains(last) {
                let wordPart = String(token.dropLast())
                if !wordPart.isEmpty {
                    let key = wordPart.lowercased()
                    result.append(StoryWord(text: wordPart,
                                            translation: dict[key],
                                            isPunctuation: false))
                }
                result.append(StoryWord(text: String(last),
                                        translation: nil,
                                        isPunctuation: true))
            } else {
                let key = token.lowercased()
                result.append(StoryWord(text: token,
                                        translation: dict[key],
                                        isPunctuation: false))
            }
        }
        return result
    }

    static func makeStory1() -> Story {
        let title = "Утро Анны"
        let text = """
        Анна просыпается рано. Она пьёт чай и слушает музыку. Потом она идёт на работу пешком. Ей нравится свежий воздух и тишина.
        """
        let dict: [String: String] = [
            "анна": "Anna",
            "просыпается": "wakes up",
            "рано": "early",
            "она": "she",
            "пьёт": "drinks",
            "чай": "tea",
            "и": "and",
            "слушает": "listens to",
            "музыку": "music",
            "потом": "then",
            "идёт": "goes",
            "на": "to/on",
            "работу": "work",
            "пешком": "on foot",
            "ей": "to her",
            "нравится": "likes",
            "свежий": "fresh",
            "воздух": "air",
            "тишина": "silence"
        ]
        let quiz: [StoryQuizQuestion] = [
            StoryQuizQuestion(
                prompt: "Что Анна делает утром?",
                options: ["Она идёт в магазин", "Она пьёт чай и слушает музыку", "Она играет в футбол"],
                correctIndex: 1
            ),
            StoryQuizQuestion(
                prompt: "Как Анна добирается на работу?",
                options: ["На автобусе", "На машине", "Пешком"],
                correctIndex: 2
            ),
            StoryQuizQuestion(
                prompt: "Что Анне нравится по дороге?",
                options: ["Шум города", "Свежий воздух и тишина", "Сильный ветер"],
                correctIndex: 1
            )
        ]
        return Story(title: title, words: tokenize(text, dict: dict), quiz: quiz)
    }

    static func makeStory2() -> Story {
        let title = "Вечер у Ивана"
        let text = """
        Иван готовит ужин дома. Он читает рецепт и режет овощи. После ужина он смотрит короткий фильм и звонит другу.
        """
        let dict: [String: String] = [
            "иван": "Ivan",
            "готовит": "cooks/prepares",
            "ужин": "dinner",
            "дома": "at home",
            "он": "he",
            "читает": "reads",
            "рецепт": "recipe",
            "режет": "cuts",
            "овощи": "vegetables",
            "после": "after",
            "смотрит": "watches",
            "короткий": "short",
            "фильм": "film/movie",
            "звонит": "calls",
            "другу": "a friend"
        ]
        let quiz: [StoryQuizQuestion] = [
            StoryQuizQuestion(
                prompt: "Что Иван делает вечером?",
                options: ["Он бегает в парке", "Он готовит ужин дома", "Он едет в офис"],
                correctIndex: 1
            ),
            StoryQuizQuestion(
                prompt: "Что он делает после ужина?",
                options: ["Смотрит короткий фильм и звонит другу", "Идёт в магазин", "Спит"],
                correctIndex: 0
            ),
            StoryQuizQuestion(
                prompt: "Что он режет?",
                options: ["Фрукты", "Хлеб", "Овощи"],
                correctIndex: 2
            )
        ]
        return Story(title: title, words: tokenize(text, dict: dict), quiz: quiz)
    }

    static func makeStory3() -> Story {
        let title = "Новая книга"
        let text = """
        Мария покупает новую книгу в маленьком магазине. Она читает по вечерам и делает заметки. Ей интересно узнавать новые слова.
        """
        let dict: [String: String] = [
            "мария": "Maria",
            "покупает": "buys",
            "новую": "new (accusative feminine)",
            "книгу": "book (accusative)",
            "в": "in",
            "маленьком": "small (prepositional)",
            "магазине": "shop/store (prepositional)",
            "она": "she",
            "читает": "reads",
            "по": "in/at",
            "вечерам": "evenings",
            "делает": "makes",
            "заметки": "notes",
            "ей": "to her",
            "интересно": "it is interesting",
            "узнавать": "to learn/find out",
            "новые": "new (plural)",
            "слова": "words"
        ]
        let quiz: [StoryQuizQuestion] = [
            StoryQuizQuestion(
                prompt: "Где Мария покупает книгу?",
                options: ["В большом супермаркете", "В маленьком магазине", "В библиотеке"],
                correctIndex: 1
            ),
            StoryQuizQuestion(
                prompt: "Когда она читает?",
                options: ["Утром", "Днём", "По вечерам"],
                correctIndex: 2
            ),
            StoryQuizQuestion(
                prompt: "Что ей интересно?",
                options: ["Слушать музыку", "Узнавать новые слова", "Готовить еду"],
                correctIndex: 1
            )
        ]
        return Story(title: title, words: tokenize(text, dict: dict), quiz: quiz)
    }
}
