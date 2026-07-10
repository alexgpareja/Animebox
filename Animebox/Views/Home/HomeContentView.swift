//
//  HomeContentView.swift
//  Animebox
//

import SwiftUI

struct HomeContentView: View {
    let watching: [LibraryEntry]
    let topAnime: [Anime]
    let currentSeason: [Anime]
    let errorMessage: String?
    let retry: () -> Void

    var body: some View {
        if topAnime.isEmpty {
            if let errorMessage {
                ErrorView(message: errorMessage, retry: retry)
            } else {
                LoadingView()
            }
        } else {
            ScrollView {
                VStack(alignment: .leading, spacing: AppSpacing.padding * 1.5) {
                    WatchingNowSection(entries: watching)
                    HomeAnimeSection(title: "Top Anime", items: topAnime)
                    HomeAnimeSection(title: "En Emisión", items: currentSeason)
                }
                .padding(.vertical, AppSpacing.padding)
            }
        }
    }
}
