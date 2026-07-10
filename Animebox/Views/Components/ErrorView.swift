//
//  ErrorView.swift
//  Animebox
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: () -> Void

    var body: some View {
        ContentUnavailableView {
            Label("Algo salió mal", systemImage: "exclamationmark.triangle.fill")
                .foregroundStyle(AppColors.accent)
        } description: {
            Text(message)
                .foregroundStyle(AppColors.textPrimary)
        } actions: {
            Button("Reintentar", action: retry)
                .buttonStyle(.borderedProminent)
                .tint(AppColors.primary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppColors.background.ignoresSafeArea())
    }
}
