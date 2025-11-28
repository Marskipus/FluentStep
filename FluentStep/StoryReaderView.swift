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
                        // Optionally prefill cachedTranslations here if you already have it.
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
                        // resolve the anchor inline as an expression (no local let/var statements that break view builder)
                        PositionedPopup(
                            rect: geo[anchor],
                            containerSize: geo.size,
                            translation: translationForSelected(id: id),
                            onClose: {
                                // close the popup and clear selection
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
        let onClose: () -> Void

        // compute layout inside body (allowed)
        var body: some View {
            // constants
            let popupMaxWidth: CGFloat = 150
            let horizontalPadding: CGFloat = 12
            let popupHeightEstimate: CGFloat = 64

            // compute X center clamped to container
            var centerX = rect.midX
            centerX = max(popupMaxWidth/2 + horizontalPadding, centerX)
            centerX = min(containerSize.width - popupMaxWidth/2 - horizontalPadding, centerX)

            // decide above or below
            let spaceBelow = containerSize.height - rect.maxY
            let showBelow = spaceBelow > (popupHeightEstimate + 16)

            // determine Y
            let centerY: CGFloat = showBelow ? (rect.maxY + popupHeightEstimate/2 + 8) : (rect.minY - popupHeightEstimate/2 - 8)

            return TranslationPopupView(
                translation: translation,
                onClose: onClose
            )
            .frame(maxWidth: popupMaxWidth)
            .position(x: centerX, y: centerY)
            .zIndex(999)
        }
    }
}

// MARK: - Popup view
private struct TranslationPopupView: View {
    let translation: String
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(translation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)

            HStack {
                Spacer()
                Button(action: onClose) {
                    Text("Close")
                        .font(.footnote).bold()
                        .padding(.horizontal, 8)
                        .padding(.vertical, 6)
                        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(.regularMaterial)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.12), radius: 6, x: 0, y: 4)
    }
}
#Preview {
    NavigationStack {
        StoryReaderView(story: StoriesViewModel().stories.first!)
    }
}
