//
//  AnimeMALNodeMappingTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@Suite("Anime(malNode:)")
struct AnimeMALNodeMappingTests {
    @Test("Mapea los campos básicos del nodo de MAL al Anime existente")
    func mapsBasicFields() throws {
        let json = """
        {
            "id": 5114,
            "title": "Fullmetal Alchemist: Brotherhood",
            "main_picture": {"medium": "https://cdn.example/medium.jpg", "large": "https://cdn.example/large.jpg"},
            "alternative_titles": {"en": "FMA Brotherhood", "ja": "鋼の錬金術師"},
            "synopsis": "Dos hermanos alquimistas...",
            "mean": 9.1,
            "rank": 1,
            "popularity": 3,
            "num_list_users": 2000000,
            "genres": [{"id": 1, "name": "Action"}, {"id": 8, "name": "Drama"}],
            "studios": [{"id": 4, "name": "Bones"}],
            "media_type": "tv",
            "status": "finished_airing",
            "num_episodes": 64,
            "start_season": {"year": 2009, "season": "spring"}
        }
        """.data(using: .utf8)!

        let node = try JSONDecoder().decode(MALAnimeNode.self, from: json)
        let anime = Anime(malNode: node)

        #expect(anime.malId == 5114)
        #expect(anime.title == "Fullmetal Alchemist: Brotherhood")
        #expect(anime.titleEnglish == "FMA Brotherhood")
        #expect(anime.titleJapanese == "鋼の錬金術師")
        #expect(anime.images.jpg.largeImageUrl == "https://cdn.example/large.jpg")
        #expect(anime.score == 9.1)
        #expect(anime.rank == 1)
        #expect(anime.episodes == 64)
        #expect(anime.type == "tv")
        #expect(anime.year == 2009)
        #expect(anime.season == "spring")
        #expect(anime.airing == false)
        #expect(anime.genres?.map(\.name) == ["Action", "Drama"])
        #expect(anime.studios?.map(\.name) == ["Bones"])
        #expect(anime.url == "https://myanimelist.net/anime/5114")
    }

    @Test("status == currently_airing se traduce a airing == true")
    func mapsCurrentlyAiringStatus() throws {
        let json = """
        {"id": 1, "title": "En emisión", "status": "currently_airing"}
        """.data(using: .utf8)!

        let node = try JSONDecoder().decode(MALAnimeNode.self, from: json)
        #expect(Anime(malNode: node).airing == true)
    }

    @Test("Campos opcionales ausentes no rompen la decodificación")
    func handlesMissingOptionalFields() throws {
        let json = """
        {"id": 42, "title": "Solo con lo mínimo"}
        """.data(using: .utf8)!

        let node = try JSONDecoder().decode(MALAnimeNode.self, from: json)
        let anime = Anime(malNode: node)

        #expect(anime.malId == 42)
        #expect(anime.episodes == nil)
        #expect(anime.genres == nil)
    }
}
