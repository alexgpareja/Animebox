//
//  WatchingNowSection.swift
//  Animebox
//

import SwiftUI

struct WatchingNowSection: View {
    let entries: [LibraryEntry]

    var body: some View {
        if !entries.isEmpty {
            VStack(alignment: .leading, spacing: AppSpacing.itemSpacing) {
                Text("Viendo actualmente")
                    .font(.title3)
                    .bold()
                    .foregroundStyle(AppColors.textPrimary)
                    .padding(.horizontal, AppSpacing.padding)

                ScrollView(.horizontal) {
                    LazyHStack(alignment: .top, spacing: AppSpacing.itemSpacing) {
                        ForEach(entries) { entry in
                            let anime = Anime(libraryEntry: entry)
                            NavigationLink(value: anime) {
                                MediaCard(
                                    item: anime,
                                    progressLabel: progressLabel(for: entry)
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

    private func progressLabel(for entry: LibraryEntry) -> String {
        if let total = entry.totalEpisodes {
            "\(entry.progress)/\(total)"
        } else {
            "\(entry.progress)"
        }
    }
}
