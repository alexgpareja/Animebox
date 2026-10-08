//
//  MangaDetailView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct MangaDetailView: View {
    @State private var viewModel: MangaDetailViewModel
    @Query private var entries: [MangaLibraryEntry]
    @Environment(LinkedAccount.self) private var linkedAccount
    @State private var isPresentingAddSheet = false

    init(manga: Manga, service: ContentServicing = JikanService()) {
        _viewModel = State(initialValue: MangaDetailViewModel(initialManga: manga, service: service))
        let id = manga.malId
        _entries = Query(filter: #Predicate { $0.malId == id })
    }

    var body: some View {
        Group {
            if case .error(let message) = viewModel.state {
                ErrorView(message: message) {
                    Task { await viewModel.refreshDetails() }
                }
            } else {
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
                        MediaDetailBasics(
                            type: viewModel.manga.type,
                            dateRangeText: AiredDateFormatter.rangeString(from: viewModel.manga.published),
                            dateLabel: "Publicación"
                        )
                        if let synopsis = viewModel.manga.synopsis, !synopsis.isEmpty {
                            AnimeDetailSynopsis(text: synopsis)
                        }
                        RelatedMediaSection(entries: viewModel.manga.relatedManga) { Manga(relatedEntry: $0) }
                    }
                    .padding(AppSpacing.padding)
                }
            }
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

    /// Ver el comentario equivalente en `AnimeDetailView.libraryButtonTitle`.
    private var libraryButtonTitle: LocalizedStringKey {
        let provider = linkedAccount.activeProvider ?? .mal
        return entries.contains(where: { $0.provider == provider })
            ? "Editar en Mi Biblioteca"
            : "Añadir a Mi Biblioteca"
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        MangaDetailView(manga: PreviewSamples.mangas[0], service: PreviewJikanService())
    }
    .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
    .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    .preferredColorScheme(.dark)
}
#endif
