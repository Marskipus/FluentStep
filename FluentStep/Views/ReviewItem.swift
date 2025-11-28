import Foundation

struct ReviewItem: Identifiable, Codable, Hashable {
    let id: UUID
    var front: String
    var back: String

    // Scheduling
    var ease: Double            // e.g. starts at 2.5, min 1.3
    var intervalDays: Int       // current interval in days
    var repetitions: Int        // successful repetitions
    var dueDate: Date           // when it becomes due
    var lastReviewed: Date?
    var createdAt: Date

    init(id: UUID = UUID(),
         front: String,
         back: String,
         ease: Double = 2.5,
         intervalDays: Int = 0,
         repetitions: Int = 0,
         dueDate: Date = Date(),
         lastReviewed: Date? = nil,
         createdAt: Date = Date()) {
        self.id = id
        self.front = front
        self.back = back
        self.ease = ease
        self.intervalDays = intervalDays
        self.repetitions = repetitions
        self.dueDate = dueDate
        self.lastReviewed = lastReviewed
        self.createdAt = createdAt
    }
}
