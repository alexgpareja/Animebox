//
//  Manga+LibraryEntry.swift
//  Animebox
//

import Foundation

extension Manga {
    /// Construye un Manga mínimo a partir de un MangaLibraryEntry para navegar al
    /// detalle desde la biblioteca. MangaDetailView completará el resto vía
    /// `refreshDetails()` contra Jikan al aparecer.
    @MainActor
    init(libraryEntry entry: MangaLibraryEntry) {
        self.init(
            malId: entry.malId,
            url: nil,
            images: MediaImages(
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
            chapters: entry.totalChapters,
            volumes: entry.totalVolumes,
            status: nil,
            publishing: nil,
            synopsis: nil,
            score: entry.mangaScore,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            genres: nil,
            published: nil,
            relations: nil
        )
    }
}
