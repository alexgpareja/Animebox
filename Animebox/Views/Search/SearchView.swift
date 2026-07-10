//
//  SearchView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct SearchView: View {
    @State private var viewModel: SearchViewModel

    init(viewModel: SearchViewModel = SearchViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        @Bindable var viewModel = viewModel
        ZStack {
            AppColors.background.ignoresSafeArea()
            SearchContent(
                state: viewModel.state,
                availableGenres: viewModel.availableGenres,
                selectedGenreID: viewModel.selectedGenreID,
                isLoadingGenres: viewModel.isLoadingGenres,
                currentQuery: viewModel.query,
                onGenreTap: viewModel.toggleGenre,
                retry: viewModel.search
            )
        }
        .navigationTitle("Buscar")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Estado", selection: $viewModel.statusFilter) {
                        ForEach(SearchStatusFilter.allCases) { filter in
                            Text(filter.displayName).tag(filter)
                        }
                    }
                } label: {
                    Label("Filtrar", systemImage: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            SearchBar(text: $viewModel.query, onSubmit: viewModel.search)
        }
        .task {
            await viewModel.loadGenres()
        }
        .onChange(of: viewModel.query) { _, _ in
            viewModel.search()
        }
        .onChange(of: viewModel.statusFilter) { _, _ in
            viewModel.search()
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime)
        }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        SearchView(viewModel: SearchViewModel(service: PreviewJikanService(), debounce: .zero))
    }
    .modelContainer(for: LibraryEntry.self, inMemory: true)
    .preferredColorScheme(.dark)
}
#endif
