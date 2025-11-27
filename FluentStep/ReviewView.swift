//
//  ReviewView.swift
//  FluentStep
//

import SwiftUI

struct ReviewView: View {
    @StateObject var viewModel: ProgressViewModel

    var body: some View {
        List {
            Section("Summary") {
                HStack {
                    Label("Days Active", systemImage: "calendar")
                    Spacer()
                    Text("\(viewModel.stats.daysActive)")
                        .monospacedDigit()
                }
                HStack {
                    Label("Clips at Native Speed", systemImage: "headphones")
                    Spacer()
                    Text("\(viewModel.stats.listeningClipsCompleted)")
                        .monospacedDigit()
                }
                HStack {
                    Label("Vocab Exposures", systemImage: "text.book.closed")
                    Spacer()
                    Text("\(viewModel.stats.vocabExposures)")
                        .monospacedDigit()
                }
                HStack {
                    Label("Production Tasks", systemImage: "pencil.and.outline")
                    Spacer()
                    Text("\(viewModel.stats.productionTasksCompleted)")
                        .monospacedDigit()
                }
            }

            Section("Notes") {
                Text("As you complete daily tasks, your listening speed and vocab coverage will increase. Charts and more detailed analytics will appear here later.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Review")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Seed Demo Data") {
                    viewModel.seedDemoData()
                }
            }
        }
    }
}
