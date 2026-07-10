//
//  SearchResultsView.swift
//  Animebox
//

import SwiftUI

struct SearchResultsView: View {
    let items: [Anime]

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.itemSpacing),
        GridItem(.flexible(), spacing: AppSpacing.itemSpacing)
    ]

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: AppSpacing.itemSpacing) {
                ForEach(items) { anime in
                    NavigationLink(value: anime) {
                        SearchResultCard(anime: anime)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(AppSpacing.padding)
        }
        .scrollDismissesKeyboard(.interactively)
    }
}
