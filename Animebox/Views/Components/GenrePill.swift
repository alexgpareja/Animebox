//
//  GenrePill.swift
//  Animebox
//

import SwiftUI

struct GenrePill: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.caption)
            .padding(.horizontal, AppSpacing.itemSpacing)
            .padding(.vertical, AppSpacing.compactSpacing)
            .background(AppColors.cardBackground)
            .foregroundStyle(AppColors.textPrimary)
            .clipShape(.capsule)
    }
}
