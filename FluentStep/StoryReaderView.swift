//
//  StoryReaderView.swift
//  FluentStep
//
//  Created by James Driscoll
//

import SwiftUI
import UIKit
#if canImport(Translation)
import Translation
#endif

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

    // Translation selection state
    @State private var selectedWord: StoryWord?
    @State private var selectedWordID: UUID?
    @State private var showTranslationOverlay: Bool = false

    // Quiz sheet state
    @State private var showQuizSheet = false
    @State private var quizPeekDetent: PresentationDetent = .fraction(0.3)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                WrappedWordsView(
                    words: story.words,
                    selectedWordID: $selectedWordID,
                    showTranslationOverlay: $showTranslationOverlay,
                    onTap: { word in
                        guard !word.isPunctuation else { return }
                        selectedWord = word
                        selectedWordID = word.id
                        withAnimation(.easeInOut(duration: 0.15)) {
                            showTranslationOverlay = true
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

            // Fallback translation bar pinned at bottom (used on older OS or as fallback)
            if showTranslationOverlay, let word = selectedWord {
                TranslationBar(translation: word.translation ?? "No translation") {
                    withAnimation(.easeOut(duration: 0.15)) {
                        showTranslationOverlay = false
                    }
                }
                .transition(AnyTransition.move(edge: .bottom).combined(with: .opacity))
            }
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
    }
}

// MARK: - WrappedWordsView (captures anchors and hosts iOS 18 translation overlay)
private struct WrappedWordsView: View {
    let words: [StoryWord]
    @Binding var selectedWordID: UUID?
    @Binding var showTranslationOverlay: Bool
    let onTap: (StoryWord) -> Void

    @State private var containerWidth: CGFloat = 0

    var body: some View {
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
                                // Publish this word's bounds as an anchor preference
                                .anchorPreference(key: WordBoundsKey.self, value: .bounds) { anchor in
                                    [w.id: anchor]
                                }
                                .onTapGesture { onTap(w) }
                        }
                    }
                }
            }
        }
        // Read anchors and attach the iOS 18+ translationPresentation when we have an anchor
        .overlayPreferenceValue(WordBoundsKey.self) { preferences in
            GeometryReader { geo in
                Group {
                    if #available(iOS 18, *), let id = selectedWordID, let anchor = preferences[id] {
                        // Resolve the Anchor<CGRect> to a concrete CGRect in this GeometryReader's coordinate space
                        let resolvedRect: CGRect = geo[anchor]

                        // Create an Anchor<CGRect>.Source from the resolved rect
                        let source: Anchor<CGRect>.Source = Anchor<CGRect>.Source.rect(resolvedRect)

                        // Use the fully-qualified PopoverAttachmentAnchor.rect(source) so the compiler knows the type
                        Color.clear
                            .translationPresentation(
                                isPresented: $showTranslationOverlay,
                                text: selectedWordText(),
                                attachmentAnchor: PopoverAttachmentAnchor.rect(source)
                            ) { translatedText in
                                // Default replacementAction — dismiss overlay.
                                // If you want to actually replace the word in your model,
                                // do that mutation here (and handle persistence as needed).
                                showTranslationOverlay = false
                                // e.g. replaceSelectedWord(with: translatedText)
                            }
                            .allowsHitTesting(false)
                    } else {
                        Color.clear.allowsHitTesting(false)
                    }
                }
            }
        }
    }

    private func selectedWordText() -> String {
        guard let id = selectedWordID,
              let word = words.first(where: { $0.id == id }) else {
            return ""
        }
        return word.text
    }

    // MARK: - Layout helpers (original logic preserved)
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
        // padding to match the pill background
        width += 12
        return ceil(width)
    }
}

// MARK: - TranslationBar (fallback bottom bar)
private struct TranslationBar: View {
    let translation: String
    let dismiss: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrowshape.turn.up.right.fill")
                .foregroundStyle(.secondary)
            Text(translation)
                .font(.subheadline)
                .foregroundStyle(.primary)
                .lineLimit(2)
            Spacer()
            Button {
                dismiss()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial)
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundStyle(Color.black.opacity(0.08)),
            alignment: .top
        )
    }
}
