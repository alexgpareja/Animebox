//
//  MediaDetailHero.swift
//  Animebox
//

import SwiftUI

struct MediaDetailHero<Item: MediaSummary>: View {
    let item: Item
    var height: Double = 320

    var body: some View {
        Group {
            if let url = item.posterURL {
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
        .frame(height: height)
        .frame(maxWidth: .infinity)
        .clipped()
        .overlay {
            LinearGradient(
                colors: [
                    AppColors.background.opacity(0),
                    AppColors.background.opacity(0.95)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .overlay(alignment: .bottomLeading) {
            VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
                Text(item.displayTitle)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(AppColors.textPrimary)
                if let japanese = item.titleJapanese {
                    Text(japanese)
                        .font(.footnote)
                        .foregroundStyle(AppColors.textSecondary)
                }
            }
            .padding(AppSpacing.padding)
        }
        .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(item.displayTitle))
    }
}
