//
//  MangaSearchContent.swift
//  Animebox
//

import SwiftUI

struct MangaSearchContent: View {
    let state: MangaSearchViewModel.LoadState
    let availableGenres: [NamedEntity]
    let availableThemes: [NamedEntity]
    let selectedGenreIDs: Set<Int>
    let isLoadingGenres: Bool
    let currentQuery: String
    let onGenreTap: (Int) -> Void
    let retry: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                if !availableGenres.isEmpty {
                    GenreChipsRow(
                        title: "Géneros",
                        genres: availableGenres,
                        selectedIDs: selectedGenreIDs,
                        onTap: onGenreTap
                    )
                }
                if !availableThemes.isEmpty {
                    GenreChipsRow(
                        title: "Temas",
                        genres: availableThemes,
                        selectedIDs: selectedGenreIDs,
                        onTap: onGenreTap
                    )
                }
                MangaSearchStateView(
                    state: state,
                    currentQuery: currentQuery,
                    hasGenresLoaded: !availableGenres.isEmpty,
                    isLoadingGenres: isLoadingGenres,
                    retry: retry
                )
            }
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
