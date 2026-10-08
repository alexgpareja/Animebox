//
//  AnimeDetailView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct AnimeDetailView: View {
    @State private var viewModel: AnimeDetailViewModel
    @Query private var entries: [LibraryEntry]
    @Environment(LinkedAccount.self) private var linkedAccount
    @State private var isPresentingAddSheet = false

    init(anime: Anime, service: ContentServicing = JikanService()) {
        _viewModel = State(initialValue: AnimeDetailViewModel(initialAnime: anime, service: service))
        let id = anime.malId
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
                        MediaDetailHero(item: viewModel.anime)
                        AnimeDetailInfoRow(anime: viewModel.anime)
                        AddToLibraryButton(title: libraryButtonTitle) {
                            isPresentingAddSheet = true
                        }
                        if let genres = viewModel.anime.genres, !genres.isEmpty {
                            MediaDetailGenres(genres: genres)
                        }
                        MediaDetailBasics(
                            type: viewModel.anime.type,
                            dateRangeText: AiredDateFormatter.rangeString(from: viewModel.anime.aired),
                            dateLabel: "Emisión"
                        )
                        if let synopsis = viewModel.anime.synopsis, !synopsis.isEmpty {
                            AnimeDetailSynopsis(text: synopsis)
                        }
                        RelatedMediaSection(entries: viewModel.anime.relatedAnime) { Anime(relatedEntry: $0) }
                    }
                    .padding(AppSpacing.padding)
                }
            }
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

    /// `entries` filtra solo por `malId` (el `@Query` se declara en `init`,
    /// sin acceso al entorno) — el filtro por proveedor activo se aplica
    /// aquí para no confundir un show de MAL con uno de AniList que
    /// comparta número por coincidencia (espacios de ID distintos).
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
        AnimeDetailView(anime: PreviewSamples.animes[0], service: PreviewJikanService())
    }
    .modelContainer(for: LibraryEntry.self, inMemory: true)
    .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    .preferredColorScheme(.dark)
}
#endif
