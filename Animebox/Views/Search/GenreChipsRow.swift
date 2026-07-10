//
//  GenreChipsRow.swift
//  Animebox
//

import SwiftUI

struct GenreChipsRow: View {
    let genres: [NamedEntity]
    let selectedID: Int?
    let onTap: (Int) -> Void

    var body: some View {
        ScrollView(.horizontal) {
            HStack(spacing: 8) {
                ForEach(genres) { genre in
                    GenreChip(
                        title: genre.name,
                        isSelected: genre.malId == selectedID
                    ) {
                        onTap(genre.malId)
                    }
                }
            }
            .padding(.horizontal, AppSpacing.padding)
        }
        .scrollIndicators(.hidden)
        .padding(.vertical, 8)
    }
}
