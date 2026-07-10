//
//  LibraryView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @State private var selectedStatus: LibraryStatus = .watching
    @Query(sort: \LibraryEntry.updatedAt, order: .reverse) private var entries: [LibraryEntry]
    @Environment(\.modelContext) private var context

    @State private var presentingError = false
    @State private var errorMessage = ""

    var body: some View {
        VStack(spacing: 0) {
            LibraryStatusPicker(selection: $selectedStatus)
            LibraryContent(
                entries: filteredEntries,
                status: selectedStatus,
                onDelete: delete,
                onIncrement: increment
            )
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Biblioteca")
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime)
        }
        .alert("No se pudo guardar el cambio", isPresented: $presentingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var filteredEntries: [LibraryEntry] {
        entries.filter { $0.status == selectedStatus }
    }

    private func delete(at offsets: IndexSet) {
        let entriesToDelete = offsets.map { filteredEntries[$0] }
        for entry in entriesToDelete {
            context.delete(entry)
        }
        commit()
    }

    private func increment(_ entry: LibraryEntry) {
        entry.incrementProgress()
        commit()
    }

    private func commit() {
        do {
            try context.save()
        } catch {
            errorMessage = error.localizedDescription
            presentingError = true
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LibraryView()
    }
    .modelContainer(PreviewLibrary.makeContainer())
    .preferredColorScheme(.dark)
}
#endif
