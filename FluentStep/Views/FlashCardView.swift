import SwiftUI

struct FlashCardView: View {
    let card: FlashCard
    @State private var isFlipped = false

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(isFlipped ? Color.blue.opacity(0.9) : Color.orange.opacity(0.9))
                .shadow(radius: 6)

            // Content
            ZStack {
                // Front side
                VStack {
                    Text(card.front)
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .opacity(isFlipped ? 0 : 1)

                // Back side
                VStack {
                    Text(card.back)
                        .font(.largeTitle).bold()
                        .foregroundColor(.white)
                        .padding()
                        .multilineTextAlignment(.center)
                }
                .opacity(isFlipped ? 1 : 0)
                // <-- The crucial fix: rotate the back side 180° extra!
                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
            }
            .frame(width: 280, height: 180)
        }
        .frame(width: 280, height: 180)
        .rotation3DEffect(.degrees(isFlipped ? 180 : 0), axis: (x: 0, y: 1, z: 0))
        .animation(.spring(response: 0.5, dampingFraction: 0.65), value: isFlipped)
        .onTapGesture {
            isFlipped.toggle()
        }
        .accessibilityLabel(isFlipped ? card.back : card.front)
        .accessibilityAddTraits(.isButton)
    }
}
