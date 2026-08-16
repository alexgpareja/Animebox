//
//  SearchIdlePrompt.swift
//  Animebox
//

import SwiftUI

struct SearchIdlePrompt: View {
    let isLoadingGenres: Bool
    let hasGenresLoaded: Bool
    var mediaKind: MediaKind = .anime

    var body: some View {
        if isLoadingGenres && !hasGenresLoaded {
            LoadingView()
        } else if hasGenresLoaded {
            ContentUnavailableView(
                "Empieza por elegir un género",
                systemImage: "tag.fill",
                description: Text(mediaKind == .anime
                    ? "O escribe en la barra de búsqueda para encontrar un anime concreto."
                    : "O escribe en la barra de búsqueda para encontrar un manga concreto.")
            )
        } else {
            ContentUnavailableView(
                mediaKind == .anime ? "Busca tu próximo anime" : "Busca tu próximo manga",
                systemImage: "magnifyingglass",
                description: Text("Empieza a escribir para buscar en MyAnimeList.")
            )
        }
    }
}
