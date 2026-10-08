//
//  AnimeDetailInfoRow.swift
//  Animebox
//

import SwiftUI

struct AnimeDetailInfoRow: View {
    let anime: Anime

    var body: some View {
        HStack(spacing: AppSpacing.itemSpacing) {
            if let score = anime.score {
                StatTile(
                    icon: "star.fill",
                    value: Text(score, format: .number.precision(.fractionLength(2))),
                    title: "Score"
                )
            }
            if let episodes = anime.episodes {
                StatTile(
                    icon: "tv",
                    value: Text(episodes, format: .number),
                    title: "Episodios"
                )
            }
            if let status = anime.status {
                StatTile(
                    icon: "clock",
                    value: Text(AnimeAiringStatus(apiValue: status)?.displayName ?? status),
                    title: "Estado"
                )
            }
        }
    }
}
