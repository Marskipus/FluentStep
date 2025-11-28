//
//  DailyTasksView.swift
//  FluentStep
//

import SwiftUI

struct DailyTasksView: View {
    @StateObject var viewModel: DailyTasksViewModel

    var body: some View {
        List {
            ForEach(viewModel.tasks) { task in
                NavigationLink {
                    TaskDetailPlaceholderView(task: task)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: task.iconName)
                            .foregroundStyle(task.tint)
                        VStack(alignment: .leading) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.subtitle)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if task.completed {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Daily Tasks")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    viewModel.resetToday()
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                }
                .help("Reset today’s demo progress")
            }
        }
    }
}

struct TaskDetailPlaceholderView: View {
    let task: DailyTask

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label(task.title, systemImage: task.iconName)
                .font(.title2).bold()
                .foregroundStyle(task.tint)

            Text("This is a placeholder screen for the “\(task.type.displayName)” task.")
                .font(.body)

            GroupBox("What this will include") {
                VStack(alignment: .leading, spacing: 8) {
                    switch task.type {
                    case .listening:
                        Text("• Native-speed audio player")
                        Text("• Optional transcript toggle")
                        Text("• Comprehension checks")
                    case .vocab:
                        Text("• Targeted vocab exposures")
                        Text("• Example sentences with context")
                        Text("• Light spaced repetition later")
                    case .rewriteTranslate:
                        Text("• Prompt + text editor")
                        Text("• Compare to model answer / feedback")
                    case .speaking:
                        Text("• Record and playback")
                        Text("• Prompt and guidance")
                        Text("• Later: evaluation with LLM")
                    }
                }
            }

            Spacer()
        }
        .padding()
        .navigationTitle(task.type.displayName)
    }
}
