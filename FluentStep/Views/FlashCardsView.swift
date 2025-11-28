import SwiftUI

struct FlashCardsView: View {
    @StateObject private var viewModel = FlashCardsViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("Russian B1 Flashcards")
                .font(.title).bold()
            if !viewModel.cards.isEmpty {
                FlashCardView(card: viewModel.cards[viewModel.currentIndex])

                HStack {
                    Button {
                        viewModel.previous()
                    } label: {
                        Image(systemName: "chevron.backward")
                            .font(.title)
                    }
                    .disabled(viewModel.currentIndex == 0)

                    Spacer()

                    Text("\(viewModel.currentIndex + 1) / \(viewModel.cards.count)")
                        .font(.subheadline)
                        .monospacedDigit()

                    Spacer()

                    Button {
                        viewModel.next()
                    } label: {
                        Image(systemName: "chevron.forward")
                            .font(.title)
                    }
                    .disabled(viewModel.currentIndex == viewModel.cards.count - 1)
                }
                .padding(.horizontal, 48)
                .padding(.top)

                HStack(spacing: 24) {
                    Button("Shuffle") {
                        viewModel.shuffle()
                    }
                    Button("Reset") {
                        viewModel.reset()
                    }
                }
                .padding(.top, 8)
            } else {
                Text("No flashcards available.")
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
    }
}

#Preview {
    FlashCardsView()
}
