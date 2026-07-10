//
//  AnimeFromLibraryEntryTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@MainActor
struct AnimeFromLibraryEntryTests {

    @Test("Anime se construye a partir de LibraryEntry preservando los campos clave")
    func preservesIdentifyingFields() {
        let entry = LibraryEntry(
            malId: 42,
            title: "Mi Anime",
            imageURL: "https://example.com/poster.jpg",
            status: .watching,
            progress: 5,
            totalEpisodes: 12
        )

        let anime = Anime(libraryEntry: entry)

        #expect(anime.malId == 42)
        #expect(anime.title == "Mi Anime")
        #expect(anime.episodes == 12)
        #expect(anime.images.jpg.imageUrl == "https://example.com/poster.jpg")
        #expect(anime.images.bestURL?.absoluteString == "https://example.com/poster.jpg")
    }

    @Test("Si el entry no tiene imageURL el Anime conserva nil y bestURL es nil")
    func handlesMissingImageURL() {
        let entry = LibraryEntry(malId: 1, title: "Sin imagen")

        let anime = Anime(libraryEntry: entry)

        #expect(anime.images.jpg.imageUrl == nil)
        #expect(anime.images.bestURL == nil)
    }

    @Test("Sin totalEpisodes el Anime.episodes queda en nil")
    func handlesMissingTotalEpisodes() {
        let entry = LibraryEntry(malId: 99, title: "Sin episodios")

        let anime = Anime(libraryEntry: entry)

        #expect(anime.episodes == nil)
    }

    @Test("animeScore del entry se propaga al Anime.score")
    func preservesAnimeScore() {
        let entry = LibraryEntry(malId: 1, title: "x", animeScore: 8.42)

        let anime = Anime(libraryEntry: entry)

        #expect(anime.score == 8.42)
    }
}
