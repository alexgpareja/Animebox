//
//  StatTile.swift
//  Animebox
//

import SwiftUI

struct StatTile: View {
    let icon: String
    let value: Text
    let title: String

    var body: some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundStyle(AppColors.accent)
            value
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(title)
                .font(.caption)
                .foregroundStyle(AppColors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, AppSpacing.itemSpacing)
        .background(AppColors.cardBackground)
        .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))
    }
}
