//
//  SettingsView.swift
//  FluentStep
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("preferredLanguage") private var preferredLanguage: String = "Russian"

    var body: some View {
        Form {
            Section("App") {
                HStack {
                    Text("App Name")
                    Spacer()
                    Text("FluentStep: Russian B1→C1")
                        .foregroundStyle(.secondary)
                }
                Picker("Learning Language", selection: $preferredLanguage) {
                    Text("Russian").tag("Russian")
                }
                .pickerStyle(.navigationLink)
            }

            Section("Data") {
                Button(role: .destructive) {
                    // In MVP, this just clears the demo counters.
                    ProgressViewModel.resetAllProgress()
                } label: {
                    Label("Reset Progress (Demo)", systemImage: "trash")
                }
            }

            Section("About") {
                Text("FluentStep helps learners go from B1/B2 to C1 with daily, real‑world tasks.")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("Settings")
    }
}
