//
//  LoadingView.swift
//  Animebox
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            AppColors.background.opacity(0.6).ignoresSafeArea()
            ProgressView()
                .controlSize(.large)
                .tint(AppColors.primary)
        }
        .accessibilityLabel("Cargando")
    }
}
