//
//  StoryQuizView.swift
//  FluentStep
//

import SwiftUI

// A container that adds a compact header and exposes a collapse action
struct QuizSheetContainer: View {
    let questions: [StoryQuizQuestion]
    let onCollapse: () -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var currentIndex: Int = 0
    @State private var selectedIndex: Int? = nil
    @State private var score: Int = 0
    @State private var finished: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Compact header (like a peek)
            HStack {
                Capsule()
                    .fill(Color.secondary.opacity(0.4))
                    .frame(width: 36, height: 5)
                    .padding(.top, 8)
                    .padding(.bottom, 6)
                    .frame(maxWidth: .infinity)
            }
            HStack {
                Text("Quiz")
                    .font(.headline)
                Spacer()
                Text("\(min(currentIndex + 1, questions.count))/\(questions.count)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Button {
                    onCollapse()
                } label: {
                    Image(systemName: "chevron.down")
                        .font(.headline)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            .padding(.bottom, 6)

            Divider()

            if finished {
                VStack(spacing: 16) {
                    Text("Quiz Complete")
                        .font(.title3).bold()
                    Text("Score: \(score) / \(questions.count)")
                        .font(.headline)
                    Button("Done") {
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                let q = questions[currentIndex]

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(q.prompt)
                            .font(.title3).bold()

                        VStack(spacing: 10) {
                            ForEach(q.options.indices, id: \.self) { idx in
                                Button {
                                    selectedIndex = idx
                                } label: {
                                    HStack {
                                        Text(q.options[idx])
                                        Spacer()
                                        if selectedIndex == idx {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(.blue)
                                        }
                                    }
                                    .padding()
                                    .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                                }
                                .buttonStyle(.plain)
                            }
                        }

                        Button {
                            guard let selected = selectedIndex else { return }
                            if selected == q.correctIndex {
                                score += 1
                            }
                            if currentIndex + 1 < questions.count {
                                currentIndex += 1
                                selectedIndex = nil
                            } else {
                                finished = true
                            }
                        } label: {
                            Text(currentIndex + 1 < questions.count ? "Next" : "Finish")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 8)
                    }
                    .padding()
                }
            }
        }
    }
}
