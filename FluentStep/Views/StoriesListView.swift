//
//  StoriesListView.swift
//  FluentStep
//

import SwiftUI

struct StoriesListView: View {
    @StateObject var viewModel: StoriesViewModel

    var body: some View {
        List {
            ForEach(viewModel.stories) { story in
                NavigationLink {
                    StoryReaderView(story: story)
                } label: {
                    HStack {
                        Image(systemName: "book")
                            .foregroundStyle(.blue)
                        Text(story.title)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("Stories (A2–B1)")
    }
}
