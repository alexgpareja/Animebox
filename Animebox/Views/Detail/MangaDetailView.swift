//
//  MangaDetailView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct MangaDetailView: View {
    @State private var viewModel: MangaDetailViewModel
    @Query private var entries: [MangaLibraryEntry]
    @State private var isPresentingAddSheet = false

    init(manga: Manga, service: ContentServicing = JikanService()) {
        _viewModel = State(initialValue: MangaDetailViewModel(initialManga: manga, service: service))
        let id = manga.malId
        _entries = Query(filter: #Predicate { $0.malId == id })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.padding) {
                MediaDetailHero(item: viewModel.manga)
                MangaDetailInfoRow(manga: viewModel.manga)
                AddToLibraryButton(title: libraryButtonTitle) {
                    isPresentingAddSheet = true
                }
                if let genres = viewModel.manga.genres, !genres.isEmpty {
                    MediaDetailGenres(genres: genres)
                }
                if let synopsis = viewModel.manga.synopsis, !synopsis.isEmpty {
                    AnimeDetailSynopsis(text: synopsis)
                }
            }
            .padding(AppSpacing.padding)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(viewModel.manga.displayTitle)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            await viewModel.refreshDetails()
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            AddToMangaLibrarySheet(manga: viewModel.manga)
                .presentationDetents([.medium, .large])
        }
    }

    private var libraryButtonTitle: LocalizedStringKey {
        entries.isEmpty ? "Añadir a Mi Biblioteca" : "Editar en Mi Biblioteca"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MangaDetailView(manga: PreviewSamples.mangas[0], service: PreviewJikanService())
    }
    .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
    .preferredColorScheme(.dark)
}
#endif
