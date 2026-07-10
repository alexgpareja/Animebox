//
//  SearchIdlePrompt.swift
//  Animebox
//

import SwiftUI

struct SearchIdlePrompt: View {
    let isLoadingGenres: Bool
    let hasGenresLoaded: Bool

    var body: some View {
        if isLoadingGenres && !hasGenresLoaded {
            LoadingView()
        } else if hasGenresLoaded {
            ContentUnavailableView(
                "Empieza por elegir un género",
                systemImage: "tag.fill",
                description: Text("O escribe en la barra de búsqueda para encontrar un anime concreto.")
            )
        } else {
            ContentUnavailableView(
                "Busca tu próximo anime",
                systemImage: "magnifyingglass",
                description: Text("Empieza a escribir para buscar en MyAnimeList.")
            )
        }
    }
}
