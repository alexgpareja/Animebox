//
//  MediaResultsGrid.swift
//  Animebox
//

import SwiftUI

struct MediaResultsGrid<Item: MediaSummary>: View {
    let items: [Item]

    private let columns = [
        GridItem(.flexible(), spacing: AppSpacing.itemSpacing),
        GridItem(.flexible(), spacing: AppSpacing.itemSpacing)
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: AppSpacing.itemSpacing) {
            ForEach(items) { item in
                NavigationLink(value: item) {
                    MediaSearchResultCard(item: item)
                }
                .buttonStyle(.pressableCard)
            }
        }
        .padding(AppSpacing.padding)
    }
}
