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
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            Tab("Inicio", systemImage: "house.fill", value: AppTab.home) {
                NavigationStack {
                    HomeView()
                }
            }
            Tab("Buscar", systemImage: "magnifyingglass", value: AppTab.search) {
                NavigationStack {
                    SearchView()
                }
            }
            Tab("Biblioteca", systemImage: "books.vertical.fill", value: AppTab.library) {
                NavigationStack {
                    LibraryView()
                }
            }
        }
        .tint(AppColors.primary)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LibraryEntry.self, inMemory: true)
        .preferredColorScheme(.dark)
}
