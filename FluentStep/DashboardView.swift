//
//  DashboardView.swift
//  FluentStep
//

import SwiftUI

struct DashboardView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("FluentStep: Russian B1→C1")
                    .font(.largeTitle).bold()

                Text("Добро пожаловать! Today’s plan focuses on native-speed listening, targeted vocab, and active production.")
                    .font(.body)

                GroupBox("Today’s Goals") {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("1 native-speed clip", systemImage: "headphones")
                        Label("10 targeted vocab exposures", systemImage: "text.book.closed")
                        Label("1 rewrite/translate challenge", systemImage: "pencil.and.outline")
                        Label("1 speaking prompt", systemImage: "mic.fill")
                    }
                }

                NavigationLink {
                    DailyTasksView(viewModel: DailyTasksViewModel())
                } label: {
                    HStack {
                        Image(systemName: "checklist")
                        Text("Go to Daily Tasks")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                NavigationLink {
                    ReviewView(viewModel: ProgressViewModel())
                } label: {
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("Review Progress")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 12))
                }

                Spacer(minLength: 8)
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }
}
