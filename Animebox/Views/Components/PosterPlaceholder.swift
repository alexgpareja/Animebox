//
//  PosterPlaceholder.swift
//  Animebox
//

import SwiftUI

struct PosterPlaceholder: View {
    var body: some View {
        ZStack {
            AppColors.cardBackground
            Image(systemName: "photo")
                .foregroundStyle(AppColors.textSecondary)
        }
    }
}
