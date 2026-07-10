//
//  LibraryContent.swift
//  Animebox
//

import SwiftUI

struct LibraryContent: View {
    let entries: [LibraryEntry]
    let status: LibraryStatus
    let onDelete: (IndexSet) -> Void
    let onIncrement: (LibraryEntry) -> Void

    var body: some View {
        if entries.isEmpty {
            LibraryEmptyState(status: status)
        } else {
            LibraryEntriesList(
                entries: entries,
                onDelete: onDelete,
                onIncrement: onIncrement
            )
        }
    }
}
