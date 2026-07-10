//
//  LibraryEntryRow.swift
//  Animebox
//

import SwiftUI

struct LibraryEntryRow: View {
    let entry: LibraryEntry

    var body: some View {
        HStack(spacing: AppSpacing.itemSpacing) {
            LibraryEntryThumbnail(imageURL: entry.imageURL)
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2, reservesSpace: true)
                LibraryEntryProgressLabel(
                    progress: entry.progress,
                    total: entry.totalEpisodes
                )
                if let score = entry.personalScore {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(AppColors.accent)
                        Text("\(score) / 10")
                            .font(.caption)
                            .foregroundStyle(AppColors.textSecondary)
                    }
                }
            }
            Spacer(minLength: 0)
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.title)
    }
}
