//
//  MangaLibraryEntryRow.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryEntryRow: View {
    let entry: MangaLibraryEntry

    var body: some View {
        HStack(spacing: AppSpacing.itemSpacing) {
            LibraryEntryThumbnail(imageURL: entry.imageURL)
            VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
                Text(entry.title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2, reservesSpace: true)
                MangaLibraryEntryProgressLabel(
                    progress: entry.chaptersRead,
                    total: entry.totalChapters
                )
                if let score = entry.personalScore {
                    HStack(spacing: AppSpacing.microSpacing) {
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
        .padding(.vertical, AppSpacing.compactSpacing)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(entry.title)
    }
}
