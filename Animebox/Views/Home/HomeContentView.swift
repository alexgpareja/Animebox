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
                VStack(alignment: .leading, spacing: AppSpacing.sectionSpacing) {
                    WatchingNowSection(entries: watching)
                    HomeMediaSection(title: "Top Anime", items: topAnime)
                    HomeMediaSection(title: "En Emisión", items: currentSeason)
                }
                .padding(.vertical, AppSpacing.padding)
            }
        }
    }
}
