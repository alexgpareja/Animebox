//
//  AnimeDetailGenres.swift
//  Animebox
//

import SwiftUI

struct AnimeDetailGenres: View {
    let genres: [NamedEntity]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Géneros")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal) {
                HStack(spacing: 6) {
                    ForEach(genres) { genre in
                        GenrePill(title: genre.name)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
