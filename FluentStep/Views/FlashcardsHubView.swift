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
                            Text("Spaced review (coming soon)")
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
                            Text("Browse the full B1 set")
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

// Placeholder for upcoming spaced review flow
struct FlashcardsReviewView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "clock.arrow.circlepath")
                .font(.system(size: 48))
                .foregroundStyle(.blue)
            Text("Review")
                .font(.title2).bold()
            Text("We’ll add spaced review controls here next.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .navigationTitle("Review")
    }
}

// Simple list of all cards from the current model
struct AllFlashcardsView: View {
    @StateObject private var vm = FlashCardsViewModel()

    var body: some View {
        List {
            ForEach(vm.cards) { card in
                HStack {
                    Text(card.front)
                        .font(.headline)
                    Spacer()
                    Text(card.back)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("All Flashcards")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    vm.shuffle()
                } label: {
                    Label("Shuffle", systemImage: "shuffle")
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        FlashcardsHubView()
    }
}
