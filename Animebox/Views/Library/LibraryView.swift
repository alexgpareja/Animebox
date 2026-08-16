//
//  LibraryView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct LibraryView: View {
    @Environment(MALSession.self) private var malSession
    @Binding var mediaKind: MediaKind
    @State private var selectedStatus: LibraryStatus = .watching
    @State private var selectedMangaStatus: MangaStatus = .reading
    @Query(sort: \LibraryEntry.updatedAt, order: .reverse) private var entries: [LibraryEntry]
    @Query(sort: \MangaLibraryEntry.updatedAt, order: .reverse) private var mangaEntries: [MangaLibraryEntry]
    @Environment(\.modelContext) private var context

    @State private var presentingError = false
    @State private var errorMessage = ""
    @State private var isPresentingImport = false
    @State private var isPresentingAccount = false

    var body: some View {
        VStack(spacing: 0) {
            MediaKindPicker(selection: $mediaKind)
            switch mediaKind {
            case .anime:
                LibraryStatusPicker(selection: $selectedStatus)
                LibraryContent(
                    entries: filteredEntries,
                    status: selectedStatus,
                    onDelete: deleteAnime,
                    onIncrement: incrementAnime
                )
            case .manga:
                MangaStatusPicker(selection: $selectedMangaStatus)
                MangaLibraryContent(
                    entries: filteredMangaEntries,
                    status: selectedMangaStatus,
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
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    isPresentingAccount = true
                } label: {
                    Label(
                        "Cuenta",
                        systemImage: malSession.isSignedIn ? "person.crop.circle.fill" : "person.crop.circle"
                    )
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingImport = true
                } label: {
                    Label("Importar", systemImage: "square.and.arrow.down")
                }
            }
        }
        .sheet(isPresented: $isPresentingImport) {
            ImportListSheet()
        }
        .sheet(isPresented: $isPresentingAccount) {
            AccountSheet(viewModel: AccountViewModel(session: malSession))
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime, service: ContentRouter(session: malSession))
        }
        .navigationDestination(for: Manga.self) { manga in
            MangaDetailView(manga: manga, service: ContentRouter(session: malSession))
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

    private var filteredMangaEntries: [MangaLibraryEntry] {
        mangaEntries.filter { $0.status == selectedMangaStatus }
    }

    private var coordinator: LibrarySyncCoordinator {
        LibrarySyncCoordinator(context: context, session: malSession)
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
    .environment(MALSession())
    .preferredColorScheme(.dark)
}
#endif
