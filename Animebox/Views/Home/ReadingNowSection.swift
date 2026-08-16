//
//  ReadingNowSection.swift
//  Animebox
//

import SwiftUI

struct ReadingNowSection: View {
    let entries: [MangaLibraryEntry]

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text("Leyendo actualmente")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.padding)

                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: AppSpacing.itemSpacing) {
                        ForEach(entries) { entry in
                            let manga = Manga(libraryEntry: entry)
                            NavigationLink(value: manga) {
                                MediaCard(
                                    item: manga,
                                    progressLabel: progressLabel(for: entry),
                                    progressIcon: "book.closed"
                                )
                            }
                            .buttonStyle(.pressableCard)
                        }
                    }
                    .padding(.horizontal, AppSpacing.padding)
                }
                .scrollIndicators(.hidden)
            }
        }
    }

    private func progressLabel(for entry: MangaLibraryEntry) -> String {
        if let total = entry.totalChapters {
            "\(entry.chaptersRead)/\(total)"
        } else {
            "\(entry.chaptersRead)"
        }
    }
}
