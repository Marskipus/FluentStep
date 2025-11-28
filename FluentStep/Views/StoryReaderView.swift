//
//  StoryReaderView.swift
//  FluentStep
//
//  Updated: anchored custom translation popup
//

import SwiftUI
import UIKit

// PreferenceKey to store each word's bounds as anchors
private struct WordBoundsKey: PreferenceKey {
    typealias Value = [UUID: Anchor<CGRect>]
    static var defaultValue: [UUID: Anchor<CGRect>] = [:]
    static func reduce(value: inout [UUID: Anchor<CGRect>], nextValue: () -> [UUID: Anchor<CGRect>]) {
        for (k, v) in nextValue() { value[k] = v }
    }
}

struct StoryReaderView: View {
    let story: Story

    // Which word is selected (by id) and currently-selected StoryWord for fallback text
    @State private var selectedWordID: UUID?
    @State private var selectedWord: StoryWord?

    // whether our custom popup is showing
    @State private var showPopup: Bool = false

    // A local cache of translations — your app can update this dictionary.
    @State private var cachedTranslations: [UUID: String] = [:]

    // Quiz sheet state (unchanged)
    @State private var showQuizSheet = false
    @State private var quizPeekDetent: PresentationDetent = .fraction(0.3)

    @EnvironmentObject private var reviewStore: ReviewStore

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                WrappedWordsView(
                    words: story.words,
                    selectedWordID: $selectedWordID,
                    showPopup: $showPopup,
                    cachedTranslations: $cachedTranslations,
                    onTap: { word in
                        guard !word.isPunctuation else { return }
                        selectedWord = word
                        selectedWordID = word.id
                        withAnimation(.easeInOut(duration: 0.12)) {
                            showPopup = true
                        }
                    }
                )
                .padding(.horizontal)
                .padding(.top, 12)
            }

            // Quiz button
            HStack {
                Button {
                    showQuizSheet = true
                } label: {
                    Label("Take Quiz", systemImage: "questionmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .navigationTitle(story.title)
        .sheet(isPresented: $showQuizSheet) {
            QuizSheetContainer(
                questions: story.quiz,
                onCollapse: {
                    quizPeekDetent = .fraction(0.2)
                }
            )
            .presentationDetents([.fraction(0.2), .medium, .large], selection: $quizPeekDetent)
            .presentationDragIndicator(.visible)
        }
        // seed cached translations from the story's inline translations
        .onAppear {
            for w in story.words {
                if let t = w.translation {
                    cachedTranslations[w.id] = t
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Refresh Cache") {
                    for w in story.words {
                        if cachedTranslations[w.id] == nil, let t = w.translation {
                            cachedTranslations[w.id] = t
                        }
                    }
                }
            }
        }
    }

    // Helper: get translation for selected id from cachedTranslations first then StoryWord translation
    private func translationForSelected(id: UUID) -> String {
        if let cached = cachedTranslations[id] { return cached }
        if let word = story.words.first(where: { $0.id == id }), let t = word.translation { return t }
        return "No translation"
    }
}

// MARK: - WrappedWordsView (publishes anchors and shows the custom popup)
private struct WrappedWordsView: View {
    let words: [StoryWord]

    // parent bindings
    @Binding var selectedWordID: UUID?
    @Binding var showPopup: Bool
    @Binding var cachedTranslations: [UUID: String]
    let onTap: (StoryWord) -> Void

    @State private var containerWidth: CGFloat = 0

    @EnvironmentObject private var reviewStore: ReviewStore

    var body: some View {
        // ZStack so popup is rendered above words in same coordinate space
        ZStack(alignment: .topLeading) {
            VStack(alignment: .leading, spacing: 10) {
                GeometryReader { geo in
                    Color.clear
                        .onAppear { containerWidth = geo.size.width }
                        .onChange(of: geo.size.width) { new in containerWidth = new }
                }
                .frame(height: 0)

                ForEach(makeLines(for: words, maxWidth: max(containerWidth, 10)), id: \.self) { line in
                    HStack(spacing: 6) {
                        ForEach(line) { w in
                            if w.isPunctuation {
                                Text(w.text)
                                    .font(.body)
                            } else {
                                Text(w.text)
                                    .font(.body)
                                    .foregroundStyle(.primary)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 3)
                                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 6))
                                    // publish this word's bounds as an anchor preference
                                    .anchorPreference(key: WordBoundsKey.self, value: .bounds) { anchor in
                                        [w.id: anchor]
                                    }
                                    .onTapGesture { onTap(w) }
                            }
                        }
                    }
                }
            }
            // read anchors and render popup positioned via a helper view
            .overlayPreferenceValue(WordBoundsKey.self) { preferences in
                GeometryReader { geo in
                    if let id = selectedWordID, let anchor = preferences[id], showPopup {
                        PositionedPopup(
                            rect: geo[anchor],
                            containerSize: geo.size,
                            translation: translationForSelected(id: id),
                            onSave: {
                                // Save to review store using the selected word and translation
                                if let word = words.first(where: { $0.id == id }) {
                                    let back = translationForSelected(id: id)
                                    reviewStore.addOrUpdate(front: word.text, back: back)
                                }
                                withAnimation(.easeOut(duration: 0.12)) {
                                    selectedWordID = nil
                                    showPopup = false
                                }
                            },
                            onClose: {
                                withAnimation(.easeOut(duration: 0.12)) {
                                    selectedWordID = nil
                                    showPopup = false
                                }
                            }
                        )
                    } else {
                        EmptyView()
                    }
                }
            }
        }
    }

    // Helper: get translation for selected id from cachedTranslations first then StoryWord translation
    private func translationForSelected(id: UUID) -> String {
        if let cached = cachedTranslations[id] { return cached }
        if let word = words.first(where: { $0.id == id }), let t = word.translation { return t }
        return "No translation"
    }

    // MARK: - Layout helpers (same as original)
    private func makeLines(for words: [StoryWord], maxWidth: CGFloat) -> [[StoryWord]] {
        var lines: [[StoryWord]] = [[]]
        var currentWidth: CGFloat = 0
        let space: CGFloat = 6

        for w in words {
            let tokenWidth = estimatedWidth(for: w)
            if currentWidth == 0 {
                lines[lines.count - 1].append(w)
                currentWidth = tokenWidth
            } else if currentWidth + space + tokenWidth <= maxWidth {
                lines[lines.count - 1].append(w)
                currentWidth += space + tokenWidth
            } else {
                lines.append([w])
                currentWidth = tokenWidth
            }
        }
        return lines
    }

    private func estimatedWidth(for word: StoryWord) -> CGFloat {
        let text = word.text as NSString
        let font = UIFont.preferredFont(forTextStyle: .body)
        let attrs: [NSAttributedString.Key: Any] = [.font: font]
        var width = text.size(withAttributes: attrs).width
        width += 12 // padding to match pill
        return ceil(width)
    }

    // MARK: - PositionedPopup helper (separates layout math from view-builder)
    private struct PositionedPopup: View {
        let rect: CGRect
        let containerSize: CGSize
        let translation: String
        let onSave: () -> Void
        let onClose: () -> Void

        @State private var popupSize: CGSize = .zero

        var body: some View {
            TranslationPopupView(translation: translation, onSave: onSave, onClose: onClose)
                .frame(maxWidth: 180) // <-- max width clamp
                .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(key: PopupSizeKey.self, value: geo.size)
                    }
                )
                .onPreferenceChange(PopupSizeKey.self) { size in
                    popupSize = size
                }
                .position(x: clampedX(), y: calculatedY())
                .zIndex(999)
        }

        // Clamp X to remain within container bounds
        private func clampedX() -> CGFloat {
            let halfWidth = popupSize.width / 2
            return min(max(rect.midX, halfWidth + 8), containerSize.width - halfWidth - 8)
        }

        // Decide Y based on available space
        private func calculatedY() -> CGFloat {
            let spaceBelow = containerSize.height - rect.maxY
            let showBelow = spaceBelow > (popupSize.height + 8)
            return showBelow ? (rect.maxY + popupSize.height / 2 + 8) : (rect.minY - popupSize.height / 2 - 8)
        }

        private struct PopupSizeKey: PreferenceKey {
            static var defaultValue: CGSize = .zero
            static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
                value = nextValue()
            }
        }
    }

}

// MARK: - Popup view
private struct TranslationPopupView: View {
    let translation: String
    let onSave: () -> Void
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) { // reduced spacing
            Text(translation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            HStack {
                Button(action: {
                    onSave()
                }) {
                    Text("Save")
                        .font(.footnote).bold()
                        .padding(.horizontal, 6) // smaller padding
                        .padding(.vertical, 4)   // smaller padding
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)

                Button(action: onClose) {
                    Text("Close")
                        .font(.footnote).bold()
                        .padding(.horizontal, 6)
                        .padding(.vertical, 4)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 6))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(8)
        .background(.regularMaterial)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    NavigationStack {
        StoryReaderView(story: StoriesViewModel().stories.first!)
            .environmentObject(ReviewStore())
    }
}
