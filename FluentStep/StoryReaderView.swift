//
//  StoryReaderView.swift
//  FluentStep
//

import SwiftUI

struct StoryReaderView: View {
    let story: Story

    // Translation state (no bubbles/overlays)
    @State private var selectedWord: StoryWord?
    @State private var showTranslationBar: Bool = false

    // Quiz sheet state
    @State private var showQuizSheet = false
    @State private var quizPeekDetent: PresentationDetent = .fraction(0.3)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: 12) {
                    WrappedWordsView(
                        words: story.words,
                        onTap: { word in
                            guard !word.isPunctuation else { return }
                            selectedWord = word
                            withAnimation(.easeInOut(duration: 0.15)) {
                                showTranslationBar = true
                            }
                        }
                    )
                    .padding(.horizontal)
                    .padding(.top, 12)
                }
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

            // Translation bar pinned at bottom (compact, reliable)
            if showTranslationBar, let word = selectedWord {
                TranslationBar(translation: word.translation ?? "No translation") {
                    withAnimation(.easeOut(duration: 0.15)) {
                        showTranslationBar = false
                    }
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(story.title)
        // Quiz as a resizable bottom sheet so the story remains visible underneath
        .sheet(isPresented: $showQuizSheet) {
            QuizSheetContainer(
                questions: story.quiz,
                onCollapse: {
                    // collapse to a smaller detent to re-read the story
                    quizPeekDetent = .fraction(0.2)
                }
            )
            .presentationDetents([.fraction(0.2), .medium, .large], selection: $quizPeekDetent)
            .presentationDragIndicator(.visible)
        }
    }
}

// MARK: - WrappedWordsView (simple wrapping, no geometry/overlays)
private struct WrappedWordsView: View {
    let words: [StoryWord]
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
                                .onTapGesture {
                                    onTap(w)
                                }
                        }
                    }
                }
            }
        }
    }

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

// MARK: - TranslationBar (compact bottom bar)
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
