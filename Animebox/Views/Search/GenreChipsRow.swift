//
//  GenreChipsRow.swift
//  Animebox
//

import SwiftUI

/// Contenedor titulado de chips en wrap, con opción de "Ver más"/"Ver menos"
/// cuando hay más elementos que `collapsedLimit`. Se reutiliza tanto para
/// géneros como para temas — visualmente son dos contenedores, pero
/// funcionalmente comparten `selectedIDs`/`onTap` (el mismo conjunto de IDs
/// seleccionados en el ViewModel).
struct GenreChipsRow: View {
    let title: String
    let genres: [NamedEntity]
    let selectedIDs: Set<Int>
    let onTap: (Int) -> Void
    var collapsedLimit: Int = 12

    @State private var isExpanded = false

    private var visibleGenres: ArraySlice<NamedEntity> {
        isExpanded || genres.count <= collapsedLimit ? genres[...] : genres.prefix(collapsedLimit)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.compactSpacing) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppColors.textSecondary)
                .padding(.horizontal, AppSpacing.padding)

            FlowLayout(spacing: AppSpacing.compactSpacing) {
                ForEach(visibleGenres) { genre in
                    GenreChip(
                        title: genre.name,
                        isSelected: selectedIDs.contains(genre.malId)
                    ) {
                        onTap(genre.malId)
                    }
                }
                if genres.count > collapsedLimit {
                    Button(isExpanded ? "Ver menos" : "Ver más") {
                        withAnimation(.easeInOut(duration: 0.2)) { isExpanded.toggle() }
                    }
                    .font(.footnote.weight(.medium))
                    .foregroundStyle(AppColors.primary)
                    .padding(.horizontal, AppSpacing.itemSpacing)
                    .frame(minHeight: 44)
                }
            }
            .padding(.horizontal, AppSpacing.padding)
        }
        .padding(.vertical, AppSpacing.compactSpacing)
    }
}
