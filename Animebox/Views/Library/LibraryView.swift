//
//  LibraryView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(LinkedAccount.self) private var linkedAccount
    @Binding var mediaKind: MediaKind
    @State private var selectedStatus: LibraryStatus = .watching
    @State private var selectedMangaStatus: MangaStatus = .reading
    @Query(sort: \LibraryEntry.updatedAt, order: .reverse) private var allEntries: [LibraryEntry]
    @Query(sort: \MangaLibraryEntry.updatedAt, order: .reverse) private var allMangaEntries: [MangaLibraryEntry]

    private var entries: [LibraryEntry] { allEntries.filter { $0.provider == linkedAccount.libraryProvider } }
    private var mangaEntries: [MangaLibraryEntry] { allMangaEntries.filter { $0.provider == linkedAccount.libraryProvider } }
    @Environment(\.modelContext) private var context

    @State private var presentingError = false
    @State private var errorMessage = ""
    @State private var isPresentingSettings = false
    @State private var searchQuery = ""
    @State private var sortOption: LibrarySortOption = .recentlyAdded
    @State private var sortAscending = LibrarySortOption.recentlyAdded.defaultAscending

    var body: some View {
        VStack(spacing: 0) {
            MediaKindPicker(selection: $mediaKind)
            switch mediaKind {
            case .anime:
                LibraryStatusPicker(selection: $selectedStatus)
                LibraryContent(
                    entries: filteredEntries,
                    status: selectedStatus,
                    searchQuery: searchQuery,
                    onDelete: deleteAnime,
                    onIncrement: incrementAnime
                )
            case .manga:
                MangaStatusPicker(selection: $selectedMangaStatus)
                MangaLibraryContent(
                    entries: filteredMangaEntries,
                    status: selectedMangaStatus,
                    searchQuery: searchQuery,
                    onDelete: deleteManga,
                    onIncrement: incrementManga
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mediaKind)
        .animation(.easeInOut(duration: 0.2), value: selectedStatus)
        .animation(.easeInOut(duration: 0.2), value: selectedMangaStatus)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Biblioteca")
        .searchable(text: $searchQuery, prompt: Text("Buscar en tu biblioteca"))
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isPresentingSettings = true
                } label: {
                    Label(
                        "Ajustes",
                        systemImage: linkedAccount.isSignedIn ? "gearshape.fill" : "gearshape"
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    ForEach(LibrarySortOption.allCases) { option in
                        Button {
                            if sortOption == option {
                                sortAscending.toggle()
                            } else {
                                sortOption = option
                                sortAscending = option.defaultAscending
                            }
                        } label: {
                            let isSelected = sortOption == option
                            let ascending = isSelected ? sortAscending : option.defaultAscending
                            HStack {
                                Label(option.label(ascending: ascending), systemImage: option.systemImage)
                                if isSelected {
                                    Spacer()
                                    Image(systemName: ascending ? "chevron.up" : "chevron.down")
                                }
                            }
                        }
                    }
                } label: {
                    Label("Ordenar", systemImage: "arrow.up.arrow.down")
                }
            }
        }
        .sheet(isPresented: $isPresentingSettings) {
            SettingsSheet(viewModel: AccountViewModel(account: linkedAccount))
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime, service: ContentRouter(account: linkedAccount))
        }
        .navigationDestination(for: Manga.self) { manga in
            MangaDetailView(manga: manga, service: ContentRouter(account: linkedAccount))
        }
        .alert("No se pudo guardar el cambio", isPresented: $presentingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    private var filteredEntries: [LibraryEntry] {
        let base = searchQuery.isEmpty
            ? entries.filter { $0.status == selectedStatus }
            : entries.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        return base.sorted(by: sortOption, ascending: sortAscending)
    }

    private var filteredMangaEntries: [MangaLibraryEntry] {
        let base = searchQuery.isEmpty
            ? mangaEntries.filter { $0.status == selectedMangaStatus }
            : mangaEntries.filter { $0.title.localizedCaseInsensitiveContains(searchQuery) }
        return base.sorted(by: sortOption, ascending: sortAscending)
    }

    private var coordinator: LibrarySyncCoordinator {
        LibrarySyncCoordinator(context: context, account: linkedAccount)
    }

    private func deleteAnime(at offsets: IndexSet) {
        let entriesToDelete = offsets.map { filteredEntries[$0] }
        withAnimation(.easeInOut(duration: 0.25)) {
            commit { for entry in entriesToDelete { try coordinator.deleteAnime(entry) } }
        }
    }

    private func incrementAnime(_ entry: LibraryEntry) {
        withAnimation(.easeInOut(duration: 0.25)) {
            commit { try coordinator.incrementAnimeProgress(entry) }
        }
    }

    private func deleteManga(at offsets: IndexSet) {
        let entriesToDelete = offsets.map { filteredMangaEntries[$0] }
        withAnimation(.easeInOut(duration: 0.25)) {
            commit { for entry in entriesToDelete { try coordinator.deleteManga(entry) } }
        }
    }

    private func incrementManga(_ entry: MangaLibraryEntry) {
        withAnimation(.easeInOut(duration: 0.25)) {
            commit { try coordinator.incrementMangaProgress(entry) }
        }
    }

    private func commit(_ operation: () throws -> Void) {
        do {
            try operation()
        } catch {
            errorMessage = error.localizedDescription
            presentingError = true
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        LibraryView(mediaKind: .constant(.anime))
    }
    .modelContainer(PreviewLibrary.makeContainer())
    .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    .preferredColorScheme(.dark)
}
#endif
