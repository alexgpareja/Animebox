//
//  SearchBar.swift
//  Animebox
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var prompt: String = "Buscar anime…"
    var onSubmit: () -> Void = {}

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(prompt, text: $text)
                .textFieldStyle(.plain)
                .submitLabel(.search)
                .onSubmit(onSubmit)
                .autocorrectionDisabled()
#if os(iOS)
                .textInputAutocapitalization(.never)
#endif
                .foregroundStyle(AppColors.textPrimary)

            if !text.isEmpty {
                Button("Borrar búsqueda", systemImage: "xmark.circle.fill") {
                    text = ""
                }
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, AppSpacing.itemSpacing)
        .padding(.vertical, AppSpacing.itemSpacing)
        .background(.regularMaterial, in: .capsule)
        .overlay {
            Capsule()
                .strokeBorder(AppColors.cardBackground.opacity(0.6), lineWidth: 1)
        }
        .padding(.horizontal, AppSpacing.padding)
        .padding(.bottom, 8)
    }
}
