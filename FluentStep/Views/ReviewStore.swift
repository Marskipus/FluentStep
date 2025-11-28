import Foundation
import Combine

@MainActor
final class ReviewStore: ObservableObject {
    @Published private(set) var items: [ReviewItem] = []

    private let storageKey = "ReviewItems.v1"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    init() {
        load()
    }

    func addOrUpdate(front: String, back: String) {
        // Use (front, back) as a natural key for MVP
        if let idx = items.firstIndex(where: { $0.front == front && $0.back == back }) {
            // If exists, keep scheduling but update text if changed
            items[idx].front = front
            items[idx].back = back
            save()
            return
        }

        // New item: due now
        let new = ReviewItem(front: front, back: back, dueDate: Date())
        items.append(new)
        save()
    }

    func remove(itemID: UUID) {
        items.removeAll { $0.id == itemID }
        save()
    }

    func removeAll() {
        items.removeAll()
        save()
    }

    func itemsDue(on date: Date = Date()) -> [ReviewItem] {
        items.filter { $0.dueDate <= endOfDay(for: date) }
            .sorted { $0.dueDate < $1.dueDate }
    }

    func updateAfterReview(itemID: UUID, grade: ReviewGrade, now: Date = Date()) {
        guard let idx = items.firstIndex(where: { $0.id == itemID }) else { return }
        var item = items[idx]

        // Simplified SM-2 inspired scheduling
        let minEase = 1.3
        var ease = item.ease
        var reps = item.repetitions
        var interval = item.intervalDays

        switch grade {
        case .again:
            // reset repetitions and set short interval (1 day)
            reps = 0
            interval = 1
            ease = max(minEase, ease - 0.2)
        case .hard:
            reps = max(1, reps) // ensure at least 1
            interval = max(1, Int(Double(max(1, interval)) * 1.2))
            ease = max(minEase, ease - 0.15)
        case .good:
            reps += 1
            if reps == 1 {
                interval = 1
            } else if reps == 2 {
                interval = 3
            } else {
                interval = max(1, Int((Double(interval)) * ease))
            }
            // small positive adjustment
            ease = max(minEase, ease + 0.0)
        case .easy:
            reps += 1
            if reps <= 2 {
                interval = 4 // jump a bit faster early
            } else {
                interval = max(1, Int((Double(interval)) * (ease + 0.15)))
            }
            ease = max(minEase, ease + 0.05)
        }

        item.repetitions = reps
        item.intervalDays = interval
        item.ease = ease
        item.lastReviewed = now
        item.dueDate = Calendar.current.date(byAdding: .day, value: interval, to: now) ?? now

        items[idx] = item
        save()
    }

    // MARK: - Persistence
    private func load() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? decoder.decode([ReviewItem].self, from: data) else {
            items = []
            return
        }
        items = decoded
    }

    private func save() {
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
        objectWillChange.send()
    }

    // MARK: - Helpers
    private func endOfDay(for date: Date) -> Date {
        var cal = Calendar.current
        cal.timeZone = .current
        let start = cal.startOfDay(for: date)
        return cal.date(byAdding: DateComponents(day: 1, second: -1), to: start) ?? date
    }
}
