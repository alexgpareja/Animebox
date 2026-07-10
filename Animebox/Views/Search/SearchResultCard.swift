//
//  SearchResultCard.swift
//  Animebox
//

import SwiftUI

struct SearchResultCard: View {
    let anime: Anime

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Group {
                if let url = anime.images.bestURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image.resizable().scaledToFill()
                        case .failure:
                            PosterPlaceholder()
                        case .empty:
                            AppColors.cardBackground
                                .overlay { ProgressView().tint(AppColors.primary) }
                        @unknown default:
                            AppColors.cardBackground
                        }
                    }
                } else {
                    PosterPlaceholder()
                }
            }
            .aspectRatio(2.0/3.0, contentMode: .fill)
            .frame(maxWidth: .infinity)
            .clipped()
            .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))

            Text(anime.displayTitle)
                .font(.footnote)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColors.accent)
                Group {
                    if let score = anime.score {
                        Text(score, format: .number.precision(.fractionLength(2)))
                    } else {
                        Text("—")
                    }
                }
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(anime.displayTitle))
    }
}
