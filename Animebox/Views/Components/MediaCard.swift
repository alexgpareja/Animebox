//
//  MediaCard.swift
//  Animebox
//

import SwiftUI

struct MediaCard<Item: MediaSummary>: View {
    let item: Item
    var width: Double = 140
    var progressLabel: String? = nil
    var progressIcon: String = "tv"

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
            poster
            Text(item.displayTitle)
                .font(.footnote)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(2, reservesSpace: true)
                .multilineTextAlignment(.leading)
                .frame(width: width, alignment: .leading)
            HStack(spacing: AppSpacing.microSpacing) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(AppColors.accent)
                Group {
                    if let score = item.score {
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
                    Image(systemName: progressIcon)
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
        .accessibilityLabel(Text(item.displayTitle))
    }

    private var poster: some View {
        RemoteImage(url: item.posterURL)
            .frame(width: width, height: width * 1.4)
            .clipped()
            .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))
    }
}
