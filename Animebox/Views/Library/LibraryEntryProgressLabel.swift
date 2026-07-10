//
//  LibraryEntryProgressLabel.swift
//  Animebox
//

import SwiftUI

struct LibraryEntryProgressLabel: View {
    let progress: Int
    let total: Int?

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "tv")
                .font(.caption2)
                .foregroundStyle(AppColors.textSecondary)
            if let total {
                Text("\(progress) / \(total)")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            } else {
                Text("\(progress) ep.")
                    .font(.caption)
                    .foregroundStyle(AppColors.textSecondary)
            }
        }
    }
}
