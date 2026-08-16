//
//  ContentView.swift
//  Animebox
//

import SwiftUI
import SwiftData

enum AppTab: Hashable {
    case home, search, library
}

struct ContentView: View {
    @Environment(MALSession.self) private var malSession
    @State private var selection: AppTab = .home
    @State private var mediaKind: MediaKind = .anime

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack {
                    HomeView(
                        mediaKind: $mediaKind,
                        viewModel: HomeViewModel(service: ContentRouter(session: malSession)),
                        mangaViewModel: MangaHomeViewModel(service: ContentRouter(session: malSession))
                    )
                }
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: AppTab.search) {
                NavigationStack {
                    SearchView(
                        mediaKind: $mediaKind,
                        viewModel: SearchViewModel(service: ContentRouter(session: malSession)),
                        mangaViewModel: MangaSearchViewModel(service: ContentRouter(session: malSession))
                    )
                }
            }
            Tab("Biblioteca", systemImage: "books.vertical.fill", value: AppTab.library) {
                NavigationStack {
                    LibraryView(mediaKind: $mediaKind)
                }
            }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [LibraryEntry.self, MangaLibraryEntry.self], inMemory: true)
        .environment(MALSession())
        .preferredColorScheme(.dark)
}
