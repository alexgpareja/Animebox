//
//  HomeView.swift
//  Animebox
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var viewModel: HomeViewModel
    @Query private var watchingEntries: [LibraryEntry]

    init(viewModel: HomeViewModel = HomeViewModel()) {
        _viewModel = State(initialValue: viewModel)
        let watchingRaw = LibraryStatus.watching.rawValue
        _watchingEntries = Query(
            filter: #Predicate<LibraryEntry> { $0.statusRaw == watchingRaw },
            sort: \LibraryEntry.updatedAt,
            order: .reverse
        )
    }

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            HomeContentView(
                watching: watchingEntries,
                topAnime: viewModel.topAnime,
                currentSeason: viewModel.currentSeason,
                errorMessage: errorMessage,
                retry: reload
            )
        }
        .navigationTitle("Inicio")
        .task {
            if viewModel.state == .idle {
                await viewModel.load()
            }
        }
        .refreshable {
            await viewModel.refresh()
        }
        .navigationDestination(for: Anime.self) { anime in
            AnimeDetailView(anime: anime)
        }
    }

    private var errorMessage: String? {
        if case .error(let message) = viewModel.state {
            message
        } else {
            nil
        }
    }

    private func reload() {
        Task { await viewModel.load() }
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        HomeView(viewModel: HomeViewModel(service: PreviewJikanService()))
    }
    .modelContainer(PreviewLibrary.makeContainer())
    .preferredColorScheme(.dark)
}
#endif
