//
//  MangaDetailInfoRow.swift
//  Animebox
//

import SwiftUI

struct MangaDetailInfoRow: View {
    let manga: Manga

    var body: some View {
        HStack(spacing: AppSpacing.itemSpacing) {
            if let score = manga.score {
                StatTile(
                    icon: "star.fill",
                    value: Text(score, format: .number.precision(.fractionLength(2))),
                    title: "Score"
                )
            }
            if let chapters = manga.chapters {
                StatTile(
                    icon: "book.closed",
                    value: Text(chapters, format: .number),
                    title: "Capítulos"
                )
            }
            if let status = manga.status {
                StatTile(
                    icon: "clock",
                    value: Text(status),
                    title: "Estado"
                )
            }
        }
    }
}
