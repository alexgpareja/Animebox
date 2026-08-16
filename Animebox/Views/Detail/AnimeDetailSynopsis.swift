//
//  AnimeDetailSynopsis.swift
//  Animebox
//

import SwiftUI

struct AnimeDetailSynopsis: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
            Text("Sinopsis")
                .font(.headline)
                .foregroundStyle(AppColors.textPrimary)
            Text(text)
                .font(.body)
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
