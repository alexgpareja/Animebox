//
//  MangaMALNodeMappingTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@Suite("Manga(malNode:)")
struct MangaMALNodeMappingTests {
    @Test("Mapea los campos básicos del nodo de MAL al Manga existente")
    func mapsBasicFields() throws {
        let json = """
        {
            "id": 2,
            "title": "Berserk",
            "main_picture": {"medium": "https://cdn.example/medium.jpg", "large": "https://cdn.example/large.jpg"},
            "alternative_titles": {"en": "Berserk"},
            "synopsis": "...",
            "mean": 9.4,
            "rank": 2,
            "popularity": 5,
            "num_list_users": 500000,
            "genres": [{"id": 1, "name": "Action"}],
            "media_type": "manga",
            "status": "currently_publishing",
            "num_chapters": 0,
            "num_volumes": 0
        }
        """.data(using: .utf8)!

        let node = try JSONDecoder().decode(MALMangaNode.self, from: json)
        let manga = Manga(malNode: node)

        #expect(manga.malId == 2)
        #expect(manga.title == "Berserk")
        #expect(manga.titleEnglish == "Berserk")
        #expect(manga.score == 9.4)
        #expect(manga.publishing == true)
        #expect(manga.genres?.map(\.name) == ["Action"])
        #expect(manga.url == "https://myanimelist.net/manga/2")
    }

    @Test("status distinto de currently_publishing se traduce a publishing == false")
    func mapsFinishedStatus() throws {
        let json = """
        {"id": 1, "title": "Terminado", "status": "finished"}
        """.data(using: .utf8)!

        let node = try JSONDecoder().decode(MALMangaNode.self, from: json)
        #expect(Manga(malNode: node).publishing == false)
    }
}
