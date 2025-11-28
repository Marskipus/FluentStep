//
//  ContentView.swift
//  FluentStep
//
//  Created by James Driscoll on 11/27/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var reviewStore = ReviewStore()

    var body: some View {
        TabView {
            NavigationStack {
                DashboardView()
            }
            .tabItem {
                Label("Dashboard", systemImage: "house.fill")
            }

            NavigationStack {
                DailyTasksView(viewModel: DailyTasksViewModel())
            }
            .tabItem {
                Label("Daily", systemImage: "checklist")
            }

            NavigationStack {
                ReviewView(viewModel: ProgressViewModel())
            }
            .tabItem {
                Label("Review", systemImage: "chart.line.uptrend.xyaxis")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gearshape.fill")
            }
        }
        .environmentObject(reviewStore)
    }
}

#Preview {
    ContentView()
}
