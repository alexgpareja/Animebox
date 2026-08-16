//
//  MangaLibraryEntryProgressLabel.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryEntryProgressLabel: View {
    let progress: Int
    let total: Int?

    var body: some View {
        HStack(spacing: AppSpacing.microSpacing) {
            Image(systemName: "book.closed")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
            if let total {
                Text("\(progress) / \(total)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("\(progress) cap.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
