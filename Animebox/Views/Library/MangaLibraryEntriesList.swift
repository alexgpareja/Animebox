//
//  MangaLibraryEntriesList.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryEntriesList: View {
    let entries: [MangaLibraryEntry]
    let onDelete: (IndexSet) -> Void
    let onIncrement: (MangaLibraryEntry) -> Void

    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink(value: Manga(libraryEntry: entry)) {
                    MangaLibraryEntryRow(entry: entry)
                }
                .listRowBackground(AppColors.cardBackground)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if entry.status == .reading {
                        Button {
                            onIncrement(entry)
                        } label: {
                            Label("+1", systemImage: "plus.circle.fill")
                        }
                        .tint(AppColors.primary)
                    }
                }
            }
            .onDelete(perform: onDelete)
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
    }
}
