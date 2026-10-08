//
//  MediaDetailGenres.swift
//  Animebox
//

import SwiftUI

struct MediaDetailGenres: View {
    let genres: [NamedEntity]

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
            Text("Géneros")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)

            ScrollView(.horizontal) {
                HStack(spacing: AppSpacing.microSpacing) {
                    ForEach(genres) { genre in
                        GenrePill(title: genre.localizedDisplayName)
                    }
                }
            }
            .scrollIndicators(.hidden)
        }
    }
}
