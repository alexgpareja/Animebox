//
//  LibraryContent.swift
//  Animebox
//

import SwiftUI

struct LibraryContent: View {
    let entries: [LibraryEntry]
    let status: LibraryStatus
    var searchQuery: String = ""
    let onDelete: (IndexSet) -> Void
    let onIncrement: (LibraryEntry) -> Void

    var body: some View {
        if entries.isEmpty {
            if searchQuery.isEmpty {
                LibraryEmptyState(status: status)
            } else {
                ContentUnavailableView.search(text: searchQuery)
            }
        } else {
            LibraryEntriesList(
                entries: entries,
                isSearching: !searchQuery.isEmpty,
                onDelete: onDelete,
                onIncrement: onIncrement
            )
        }
    }
}
