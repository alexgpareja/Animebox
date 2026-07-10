//
//  AnimeDetailView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct AnimeDetailView: View {
    @State private var viewModel: AnimeDetailViewModel
    @Query private var entries: [LibraryEntry]
    @State private var isPresentingAddSheet = false

    init(anime: Anime, service: JikanServicing = JikanService()) {
        _viewModel = State(initialValue: AnimeDetailViewModel(initialAnime: anime, service: service))
        let id = anime.malId
        _entries = Query(filter: #Predicate { $0.malId == id })
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppSpacing.padding) {
                AnimeDetailHero(anime: viewModel.anime)
                AnimeDetailInfoRow(anime: viewModel.anime)
                AddToLibraryButton(title: libraryButtonTitle) {
                    isPresentingAddSheet = true
                }
                if let genres = viewModel.anime.genres, !genres.isEmpty {
                    AnimeDetailGenres(genres: genres)
                }
                if let synopsis = viewModel.anime.synopsis, !synopsis.isEmpty {
                    AnimeDetailSynopsis(text: synopsis)
                }
            }
            .padding(AppSpacing.padding)
        }
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle(viewModel.anime.displayTitle)
#if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
#endif
        .task {
            await viewModel.refreshDetails()
        }
        .sheet(isPresented: $isPresentingAddSheet) {
            AddToLibrarySheet(anime: viewModel.anime)
                .presentationDetents([.medium, .large])
        }
    }

    private var libraryButtonTitle: String {
        entries.isEmpty ? "Añadir a Mi Biblioteca" : "Editar en Mi Biblioteca"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        AnimeDetailView(anime: PreviewSamples.animes[0], service: PreviewJikanService())
    }
    .modelContainer(for: LibraryEntry.self, inMemory: true)
    .preferredColorScheme(.dark)
}
#endif
