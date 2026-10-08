//
//  HomeView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(LinkedAccount.self) private var linkedAccount
    @Binding var mediaKind: MediaKind
    @State private var viewModel: HomeViewModel
    @State private var mangaViewModel: MangaHomeViewModel
    @State private var sectionOrderSettings = HomeSectionOrderSettings()
    @State private var isPresentingOrderSheet = false
    @Query private var watchingEntries: [LibraryEntry]
    @Query private var readingEntries: [MangaLibraryEntry]

    init(
        mediaKind: Binding<MediaKind>,
        viewModel: HomeViewModel = HomeViewModel(),
        mangaViewModel: MangaHomeViewModel = MangaHomeViewModel()
    ) {
        _mediaKind = mediaKind
        _viewModel = State(initialValue: viewModel)
        _mangaViewModel = State(initialValue: mangaViewModel)
        let watchingRaw = LibraryStatus.watching.rawValue
        _watchingEntries = Query(
            filter: #Predicate<LibraryEntry> { $0.statusRaw == watchingRaw },
            sort: \LibraryEntry.updatedAt,
            order: .reverse
        )
        let readingRaw = MangaStatus.reading.rawValue
        _readingEntries = Query(
            filter: #Predicate<MangaLibraryEntry> { $0.statusRaw == readingRaw },
            sort: \MangaLibraryEntry.updatedAt,
            order: .reverse
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            MediaKindPicker(selection: $mediaKind)
            switch mediaKind {
            case .anime:
                HomeContentView(
                    watching: watchingEntries,
                    topAnime: viewModel.topAnime,
                    currentSeason: viewModel.currentSeason,
                    errorMessage: animeErrorMessage,
                    retry: reloadAnime,
                    sectionOrder: sectionOrderSettings.animeOrder
                )
            case .manga:
                MangaHomeContentView(
                    reading: readingEntries,
                    topManga: mangaViewModel.topManga,
                    currentlyPublishing: mangaViewModel.currentlyPublishing,
                    errorMessage: mangaErrorMessage,
                    retry: reloadManga,
                    sectionOrder: sectionOrderSettings.mangaOrder
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mediaKind)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Inicio")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isPresentingOrderSheet = true
                } label: {
                    Label("Ordenar Inicio", systemImage: "arrow.up.arrow.down.circle")
                }
            }
        }
        .sheet(isPresented: $isPresentingOrderSheet) {
            HomeSectionOrderSheet(mediaKind: mediaKind, settings: sectionOrderSettings)
        }
        .task(id: mediaKind) {
            switch mediaKind {
            case .anime:
                if viewModel.state == .idle { await viewModel.load() }
            case .manga:
                if mangaViewModel.state == .idle { await mangaViewModel.load() }
            }
        }
        .refreshable {
            switch mediaKind {
            case .anime: await viewModel.refresh()
            case .manga: await mangaViewModel.refresh()
            }
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime, service: ContentRouter(account: linkedAccount))
        }
        .navigationDestination(for: Manga.self) { manga in
            MangaDetailView(manga: manga, service: ContentRouter(account: linkedAccount))
        }
    }

    private var animeErrorMessage: String? {
        if case .error(let message) = viewModel.state {
            message
        } else {
            nil
        }
    }

    private var mangaErrorMessage: String? {
        if case .error(let message) = mangaViewModel.state {
            message
        } else {
            nil
        }
    }

    private func reloadAnime() {
        Task { await viewModel.load() }
    }

    private func reloadManga() {
        Task { await mangaViewModel.load() }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView(
            mediaKind: .constant(.anime),
            viewModel: HomeViewModel(service: PreviewJikanService()),
            mangaViewModel: MangaHomeViewModel(service: PreviewJikanService())
        )
    }
    .modelContainer(PreviewLibrary.makeContainer())
    .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    .preferredColorScheme(.dark)
}
#endif
