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
                    ReadingNowSection(entries: reading)
                    HomeMediaSection(title: "Top Manga", items: topManga)
                    HomeMediaSection(title: "En Publicación", items: currentlyPublishing)
                }
                .padding(.vertical, AppSpacing.padding)
            }
        }
    }
}
