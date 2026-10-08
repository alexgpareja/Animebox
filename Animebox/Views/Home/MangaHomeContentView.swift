//
//  MangaHomeContentView.swift
//  Animebox
//

import SwiftUI

struct MangaHomeContentView: View {
    let reading: [MangaLibraryEntry]
    let topManga: [Manga]
    let currentlyPublishing: [Manga]
    let errorMessage: String?
    let retry: () -> Void
    var sectionOrder: [HomeSectionSlot] = HomeSectionSlot.allCases

    var body: some View {
        if topManga.isEmpty {
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
            ReadingNowSection(entries: reading)
        case .topRanked:
            HomeMediaSection(title: "Top Manga", items: topManga)
        case .seasonal:
            HomeMediaSection(title: "En Publicación", items: currentlyPublishing)
        }
    }
}
