//
//  MangaLibraryEntryRow.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryEntryRow: View {
    let entry: MangaLibraryEntry
    /// Se muestra al buscar (los resultados abarcan todos los estados, no
    /// solo la pestaña activa) para que el usuario sepa dónde está sin
    /// necesidad de abrir el detalle.
    var showsStatus: Bool = false

    var body: some View {
        HStack(spacing: AppSpacing.itemSpacing) {
            LibraryEntryThumbnail(imageURL: entry.imageURL)
            VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
                Text(entry.title)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.textPrimary)
                    .lineLimit(2, reservesSpace: true)
                if showsStatus {
                    Text(entry.status.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(AppColors.primary)
                        .padding(.horizontal, AppSpacing.compactSpacing)
                        .padding(.vertical, 2)
                        .background(AppColors.primary.opacity(0.15), in: .capsule)
                }
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
