import SwiftUI

struct FlashcardsHubView: View {
    var body: some View {
        List {
            Section {
                NavigationLink {
                    FlashCardsView()
                } label: {
                    HStack {
                        Image(systemName: "bolt.fill")
                            .foregroundStyle(.orange)
                        VStack(alignment: .leading) {
                            Text("Learn")
                                .font(.headline)
                            Text("Practice with the current flashcard flow")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                NavigationLink {
                    FlashcardsReviewView()
                } label: {
                    HStack {
                        Image(systemName: "clock.arrow.circlepath")
                            .foregroundStyle(.blue)
                        VStack(alignment: .leading) {
                            Text("Review")
                                .font(.headline)
                            Text("Spaced review for saved words")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }

                NavigationLink {
                    AllFlashcardsView()
                } label: {
                    HStack {
                        Image(systemName: "tray.full.fill")
                            .foregroundStyle(.green)
                        VStack(alignment: .leading) {
                            Text("All Flashcards")
                                .font(.headline)
                            Text("Your saved words")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
        }
        .navigationTitle("Flashcards")
    }
}

// Review session UI powered by ReviewStore (unchanged from earlier message)
struct FlashcardsReviewView: View {
    @EnvironmentObject private var reviewStore: ReviewStore

    @State private var sessionItems: [ReviewItem] = []
    @State private var currentIndex: Int = 0
    @State private var showBack: Bool = false

    var body: some View {
        VStack(spacing: 16) {
            if sessionItems.isEmpty {
                EmptyStateView()
            } else {
                HeaderView(current: currentIndex + 1, total: sessionItems.count)

                CardView(front: sessionItems[currentIndex].front,
                         back: sessionItems[currentIndex].back,
                         showBack: $showBack)

                if showBack {
                    GradeBar { grade in
                        let id = sessionItems[currentIndex].id
                        reviewStore.updateAfterReview(itemID: id, grade: grade)
                        advance()
                    }
                } else {
                    Button {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showBack = true
                        }
                    } label: {
                        Text("Show Answer")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .padding(.horizontal)
                }
            }
        }
        .padding()
        .navigationTitle("Review")
        .onAppear {
            reloadSession()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    reloadSession()
                } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
        }
    }

    private func reloadSession() {
        let due = reviewStore.itemsDue()
        sessionItems = due
        currentIndex = 0
        showBack = false
    }

    private func advance() {
        if currentIndex + 1 < sessionItems.count {
            currentIndex += 1
            showBack = false
        } else {
            sessionItems = []
        }
    }

    @ViewBuilder
    private func HeaderView(current: Int, total: Int) -> some View {
        HStack {
            Text("Due: \(total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text("\(current)/\(total)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }

    private struct CardView: View {
        let front: String
        let back: String
        @Binding var showBack: Bool

        var body: some View {
            ZStack {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(showBack ? Color.blue.opacity(0.9) : Color.orange.opacity(0.9))
                    .shadow(radius: 6)

                VStack {
                    Text(showBack ? back : front)
                        .font(.title).bold()
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .frame(width: 300, height: 200)
            }
            .frame(width: 300, height: 200)
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    showBack.toggle()
                }
            }
            .accessibilityLabel(showBack ? back : front)
            .accessibilityAddTraits(.isButton)
        }
    }

    private struct GradeBar: View {
        var onGrade: (ReviewGrade) -> Void

        var body: some View {
            HStack(spacing: 12) {
                Button { onGrade(.again) } label: { Label("Again", systemImage: "arrow.uturn.left.circle") }
                    .buttonStyle(.bordered)

                Button { onGrade(.hard) } label: { Label("Hard", systemImage: "tortoise") }
                    .buttonStyle(.bordered)

                Button { onGrade(.good) } label: { Label("Good", systemImage: "hand.thumbsup") }
                    .buttonStyle(.borderedProminent)

                Button { onGrade(.easy) } label: { Label("Easy", systemImage: "bolt.fill") }
                    .buttonStyle(.bordered)
            }
            .labelStyle(.titleAndIcon)
            .padding(.top, 8)
        }
    }

    private struct EmptyStateView: View {
        var body: some View {
            VStack(spacing: 12) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                Text("No cards due")
                    .font(.title3).bold()
                Text("Tap Save on words in stories to add them here. When they’re due, they’ll appear for review.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.top, 40)
        }
    }
}

// All Flashcards now shows the saved items from ReviewStore
struct AllFlashcardsView: View {
    @EnvironmentObject private var reviewStore: ReviewStore

    var body: some View {
        List {
            if reviewStore.items.isEmpty {
                Section {
                    Text("No saved flashcards yet.")
                        .foregroundStyle(.secondary)
                }
            } else {
                Section("Saved") {
                    ForEach(reviewStore.items) { item in
                        HStack {
                            Text(item.front)
                                .font(.headline)
                            Spacer()
                            Text(item.back)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .onDelete { indexSet in
                        for index in indexSet {
                            let id = reviewStore.items[index].id
                            reviewStore.remove(itemID: id)
                        }
                    }
                }
            }
        }
        .navigationTitle("All Flashcards")
        .toolbar {
            EditButton()
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardsHubView()
            .environmentObject(ReviewStore())
    }
}
