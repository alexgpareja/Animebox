//
//  SearchContent.swift
//  Animebox
//

import SwiftUI

struct SearchContent: View {
    let state: SearchViewModel.LoadState
    let availableGenres: [NamedEntity]
    let selectedGenreID: Int?
    let isLoadingGenres: Bool
    let currentQuery: String
    let onGenreTap: (Int) -> Void
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            if !availableGenres.isEmpty {
                GenreChipsRow(
                    genres: availableGenres,
                    selectedID: selectedGenreID,
                    onTap: onGenreTap
                )
            }
            SearchStateView(
                state: state,
                currentQuery: currentQuery,
                hasGenresLoaded: !availableGenres.isEmpty,
                isLoadingGenres: isLoadingGenres,
                retry: retry
            )
        }
    }
}
