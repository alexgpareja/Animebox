//
//  MangaLibraryContent.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryContent: View {
    let entries: [MangaLibraryEntry]
    let status: MangaStatus
    var searchQuery: String = ""
    let onDelete: (IndexSet) -> Void
    let onIncrement: (MangaLibraryEntry) -> Void

    var body: some View {
        if entries.isEmpty {
            if searchQuery.isEmpty {
                MangaLibraryEmptyState(status: status)
            } else {
                ContentUnavailableView.search(text: searchQuery)
            }
        } else {
            MangaLibraryEntriesList(
                entries: entries,
                isSearching: !searchQuery.isEmpty,
                onDelete: onDelete,
                onIncrement: onIncrement
            )
        }
    }
}
