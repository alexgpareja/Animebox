//
//  SearchView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @Environment(MALSession.self) private var malSession
    @Binding var mediaKind: MediaKind
    @State private var viewModel: SearchViewModel
    @State private var mangaViewModel: MangaSearchViewModel
    @State private var isPresentingFilters = false

    init(
        mediaKind: Binding<MediaKind>,
        viewModel: SearchViewModel = SearchViewModel(),
        mangaViewModel: MangaSearchViewModel = MangaSearchViewModel()
    ) {
        _mediaKind = mediaKind
        _viewModel = State(initialValue: viewModel)
        _mangaViewModel = State(initialValue: mangaViewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        @Bindable var mangaViewModel = mangaViewModel
        VStack(spacing: 0) {
            MediaKindPicker(selection: $mediaKind)
            switch mediaKind {
            case .anime:
                SearchContent(
                    state: viewModel.state,
                    availableGenres: viewModel.availableGenres,
                    availableThemes: viewModel.availableThemes,
                    selectedGenreIDs: viewModel.selectedGenreIDs,
                    isLoadingGenres: viewModel.isLoadingGenres,
                    currentQuery: viewModel.query,
                    onGenreTap: viewModel.toggleGenre,
                    retry: viewModel.search
                )
            case .manga:
                MangaSearchContent(
                    state: mangaViewModel.state,
                    availableGenres: mangaViewModel.availableGenres,
                    availableThemes: mangaViewModel.availableThemes,
                    selectedGenreIDs: mangaViewModel.selectedGenreIDs,
                    isLoadingGenres: mangaViewModel.isLoadingGenres,
                    currentQuery: mangaViewModel.query,
                    onGenreTap: mangaViewModel.toggleGenre,
                    retry: mangaViewModel.search
                )
            }
        }
        .animation(.easeInOut(duration: 0.2), value: mediaKind)
        .animation(.easeInOut(duration: 0.2), value: viewModel.state)
        .animation(.easeInOut(duration: 0.2), value: mangaViewModel.state)
        .background(AppColors.background.ignoresSafeArea())
        .navigationTitle("Buscar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                let isActive = mediaKind == .anime ? viewModel.hasActiveFilters : mangaViewModel.hasActiveFilters
                Button {
                    isPresentingFilters = true
                } label: {
                    Label(
                        "Filtrar",
                        systemImage: isActive
                            ? "line.3.horizontal.decrease.circle.fill"
                            : "line.3.horizontal.decrease.circle"
                    )
                }
            }
        }
        .sheet(isPresented: $isPresentingFilters) {
            switch mediaKind {
            case .anime:
                AnimeSearchFiltersSheet(viewModel: viewModel)
            case .manga:
                MangaSearchFiltersSheet(viewModel: mangaViewModel)
            }
        }
        .safeAreaInset(edge: .bottom) {
            switch mediaKind {
            case .anime:
                SearchBar(text: $viewModel.query, onSubmit: viewModel.search)
            case .manga:
                SearchBar(text: $mangaViewModel.query, prompt: "Buscar manga…", onSubmit: mangaViewModel.search)
            }
        }
        .task(id: mediaKind) {
            switch mediaKind {
            case .anime: await viewModel.loadGenres()
            case .manga: await mangaViewModel.loadGenres()
            }
        }
        .onChange(of: viewModel.query) { _, _ in
            viewModel.search()
        }
        .onChange(of: mangaViewModel.query) { _, _ in
            mangaViewModel.search()
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime, service: ContentRouter(session: malSession))
        }
        .navigationDestination(for: Manga.self) { manga in
            MangaDetailView(manga: manga, service: ContentRouter(session: malSession))
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SearchView(
            mediaKind: .constant(.anime),
            viewModel: SearchViewModel(service: PreviewJikanService(), debounce: .zero),
            mangaViewModel: MangaSearchViewModel(service: PreviewJikanService(), debounce: .zero)
        )
    }
    .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
    .environment(MALSession())
    .preferredColorScheme(.dark)
}
#endif
