//
//  SearchStateView.swift
//  Animebox
//

import SwiftUI

struct SearchStateView: View {
    let state: SearchViewModel.LoadState
    let currentQuery: String
    let hasGenresLoaded: Bool
    let isLoadingGenres: Bool
    let retry: () -> Void

    var body: some View {
        switch state {
        case .idle:
            SearchIdlePrompt(
                isLoadingGenres: isLoadingGenres,
                hasGenresLoaded: hasGenresLoaded
            )
        case .searching:
            LoadingView()
        case .results(let items):
            SearchResultsView(items: items)
        case .empty:
            ContentUnavailableView.search(text: currentQuery)
        case .error(let message):
            ErrorView(message: message, retry: retry)
        }
    }
}
