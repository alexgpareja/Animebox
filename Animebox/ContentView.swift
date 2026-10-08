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
    @Environment(LinkedAccount.self) private var linkedAccount
    @State private var selection: AppTab = .home
    @State private var mediaKind: MediaKind = .anime

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack {
                    HomeView(
                        mediaKind: $mediaKind,
                        viewModel: HomeViewModel(service: ContentRouter(account: linkedAccount)),
                        mangaViewModel: MangaHomeViewModel(service: ContentRouter(account: linkedAccount))
                    )
                }
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: AppTab.search) {
                NavigationStack {
                    SearchView(
                        mediaKind: $mediaKind,
                        viewModel: SearchViewModel(service: ContentRouter(account: linkedAccount)),
                        mangaViewModel: MangaSearchViewModel(service: ContentRouter(account: linkedAccount))
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
        .environment(LinkedAccount(mal: MALSession(), aniList: AniListSession()))
        .preferredColorScheme(.dark)
}
