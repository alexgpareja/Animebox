//
//  MangaLibraryContent.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryContent: View {
    let entries: [MangaLibraryEntry]
    let status: MangaStatus
    let onDelete: (IndexSet) -> Void
    let onIncrement: (MangaLibraryEntry) -> Void

    var body: some View {
        if entries.isEmpty {
            MangaLibraryEmptyState(status: status)
        } else {
            MangaLibraryEntriesList(
                entries: entries,
                onDelete: onDelete,
                onIncrement: onIncrement
            )
        }
    }
}
