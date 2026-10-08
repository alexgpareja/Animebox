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
    var sectionOrder: [HomeSectionSlot] = HomeSectionSlot.allCases

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
                    ForEach(sectionOrder) { slot in
                        section(for: slot)
                    }
                }
                .padding(.vertical, AppSpacing.padding)
            }
        }
    }

    @ViewBuilder
    private func section(for slot: HomeSectionSlot) -> some View {
        switch slot {
        case .continuing:
            WatchingNowSection(entries: watching)
        case .topRanked:
            HomeMediaSection(title: "Top Anime", items: topAnime)
        case .seasonal:
            HomeMediaSection(title: "En Emisión", items: currentSeason)
        }
    }
}
