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
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(AppColors.cardBackground)
            .foregroundStyle(AppColors.textPrimary)
            .clipShape(.capsule)
    }
}
