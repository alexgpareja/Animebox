//
//  MediaDetailBasics.swift
//  Animebox
//

import SwiftUI

/// Bloque "Detalles" entre Géneros y Sinopsis — tipo (TV/OVA/Movie...) y
/// fecha de emisión/publicación. Compartido entre anime y manga (como
/// `AnimeDetailSynopsis`, a pesar del nombre no es anime-específico) — solo
/// cambia la etiqueta de la fecha ("Emisión" vs "Publicación").
struct MediaDetailBasics: View {
    let type: String?
    let dateRangeText: String?
    let dateLabel: LocalizedStringKey

    var body: some View {
        if type != nil || dateRangeText != nil {
            VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
                Text("Detalles")
                    .font(.headline)
                    .foregroundStyle(AppColors.textPrimary)

                VStack(alignment: .leading, spacing: AppSpacing.microSpacing) {
                    if let type {
                        line(label: "Tipo", value: type)
                    }
                    if let dateRangeText {
                        line(label: dateLabel, value: dateRangeText)
                    }
                }
                .padding(AppSpacing.padding)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(AppColors.cardBackground)
                .clipShape(.rect(cornerRadius: AppSpacing.cornerRadius))
            }
        }
    }

    private func line(label: LocalizedStringKey, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(AppColors.textSecondary)
            Spacer()
            Text(value)
                .foregroundStyle(AppColors.textPrimary)
        }
        .font(.subheadline)
    }
}

#if DEBUG
#Preview {
    VStack {
        MediaDetailBasics(type: "TV", dateRangeText: "Apr 5, 2020 - Sep 27, 2020", dateLabel: "Emisión")
    }
    .padding()
    .background(AppColors.background.ignoresSafeArea())
    .preferredColorScheme(.dark)
}
#endif
