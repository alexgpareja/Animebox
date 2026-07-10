//
//  AnimeCard.swift
//  Animebox
//

import SwiftUI

struct AnimeCard: View {
    let anime: Anime
    var width: Double = 140
    var progressLabel: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            poster
            Text(anime.displayTitle)
                .font(.footnote)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(width: width, alignment: .leading)
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
                .lineLimit(1)

                if let progressLabel {
                    Spacer(minLength: 6)
                    Image(systemName: "tv")
                        .font(.caption2)
                        .foregroundStyle(AppColors.textSecondary)
                    Text(progressLabel)
                        .font(.caption)
                        .foregroundStyle(AppColors.textSecondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .frame(width: width, alignment: .leading)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(anime.displayTitle))
    }

    @ViewBuilder
    private var poster: some View {
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
                .id(url.absoluteString)
            } else {
                PosterPlaceholder()
            }
        }
        .frame(width: width, height: width * 1.4)
        .clipped()
        .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))
    }
}
