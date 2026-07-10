//
//  Anime+LibraryEntry.swift
//  Animebox
//

import Foundation

extension Anime {
    /// Construye un Anime mínimo a partir de un LibraryEntry para navegar al
    /// detalle desde la biblioteca. AnimeDetailView completará el resto vía
    /// `refreshDetails()` contra Jikan al aparecer.
    @MainActor
    init(libraryEntry entry: LibraryEntry) {
        self.init(
            malId: entry.malId,
            url: nil,
            images: AnimeImages(
                jpg: ImageSet(
                    imageUrl: entry.imageURL,
                    smallImageUrl: entry.imageURL,
                    largeImageUrl: entry.imageURL
                ),
                webp: nil
            ),
            title: entry.title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            episodes: entry.totalEpisodes,
            status: nil,
            airing: nil,
            synopsis: nil,
            score: entry.animeScore,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            year: nil,
            season: nil,
            genres: nil,
            studios: nil
        )
    }
}
