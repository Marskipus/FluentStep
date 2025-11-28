import SwiftUI

struct FlashCardsView: View {
    @StateObject private var viewModel = FlashCardsViewModel()
    @EnvironmentObject private var reviewStore: ReviewStore
    @State private var didSaveBriefly = false

    var body: some View {
        VStack(spacing: 24) {
            Text("Russian B1 Flashcards")
                .font(.title).bold()

            if !viewModel.cards.isEmpty {
                // The flashcard
                FlashCardView(card: viewModel.cards[viewModel.currentIndex])

                // Arrows + counter
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

                // Save button (between arrows/counter and Shuffle/Reset)
                Button {
                    let current = viewModel.cards[viewModel.currentIndex]
                    reviewStore.addOrUpdate(front: current.front, back: current.back)
                    // brief visual confirmation
                    didSaveBriefly = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        didSaveBriefly = false
                    }
                } label: {
                    Label(didSaveBriefly ? "Saved" : "Save to Review", systemImage: didSaveBriefly ? "checkmark.circle.fill" : "tray.and.arrow.down.fill")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyleProminentCompat()
                .padding(.horizontal, 48)

                // Shuffle / Reset row
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

private extension View {
    @ViewBuilder
    func buttonStyleProminentCompat() -> some View {
        if #available(iOS 15.0, macOS 12.0, *) {
            self.buttonStyle(.borderedProminent)
        } else {
            self.buttonStyle(DefaultButtonStyle())
        }
    }
}

#Preview {
    FlashCardsView()
        .environmentObject(ReviewStore())
}
