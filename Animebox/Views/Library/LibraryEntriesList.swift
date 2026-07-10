//
//  LibraryEntriesList.swift
//  Animebox
//

import SwiftUI

struct LibraryEntriesList: View {
    let entries: [LibraryEntry]
    let onDelete: (IndexSet) -> Void
    let onIncrement: (LibraryEntry) -> Void

    var body: some View {
        List {
            ForEach(entries) { entry in
                NavigationLink(value: Anime(libraryEntry: entry)) {
                    LibraryEntryRow(entry: entry)
                }
                .listRowBackground(AppColors.cardBackground)
                .listRowSeparator(.hidden)
                .swipeActions(edge: .leading, allowsFullSwipe: true) {
                    if entry.status == .watching {
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
