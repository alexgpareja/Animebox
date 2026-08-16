//
//  GenreChip.swift
//  Animebox
//

import SwiftUI

struct GenreChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.footnote)
                .padding(.horizontal, AppSpacing.itemSpacing)
                .padding(.vertical, AppSpacing.compactSpacing)
                .background(isSelected ? AppColors.primary : AppColors.cardBackground)
                .foregroundStyle(isSelected ? Color.white : AppColors.textPrimary)
                .clipShape(.capsule)
                .frame(minHeight: 44)
                .contentShape(.capsule)
        }
        .buttonStyle(.pressableCard(scale: 0.94))
        .animation(.easeInOut(duration: 0.2), value: isSelected)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .accessibilityHint(isSelected ? "Toca para deseleccionar" : "Toca para filtrar por este género")
    }
}
