//
//  AnimeDecodingTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

struct AnimeDecodingTests {

    @Test("Decodifica una respuesta paginada de Jikan")
    func decodesJikanListResponse() throws {
        let json = #"""
        {
          "data": [{
            "mal_id": 5114,
            "url": "https://myanimelist.net/anime/5114",
            "images": {
              "jpg": {
                "image_url": "https://cdn.myanimelist.net/images/anime/1208/94745.jpg",
                "small_image_url": null,
                "large_image_url": "https://cdn.myanimelist.net/images/anime/1208/94745l.jpg"
              },
              "webp": null
            },
            "title": "Fullmetal Alchemist: Brotherhood",
            "title_english": "Fullmetal Alchemist: Brotherhood",
            "title_japanese": null,
            "type": "TV",
            "episodes": 64,
            "status": "Finished Airing",
            "airing": false,
            "synopsis": "...",
            "score": 9.1,
            "scored_by": 2000000,
            "rank": 1,
            "popularity": 3,
            "members": 3000000,
            "favorites": 200000,
            "year": 2009,
            "season": null,
            "genres": [],
            "studios": []
          }],
          "pagination": {
            "last_visible_page": 1,
            "has_next_page": false,
            "current_page": 1,
            "items": { "count": 1, "total": 1, "per_page": 25 }
          }
        }
        """#.data(using: .utf8)!

        let response = try JSONDecoder().decode(JikanListResponse<Anime>.self, from: json)
        try #require(response.data.count == 1)
        let anime = response.data[0]
        #expect(anime.title == "Fullmetal Alchemist: Brotherhood")
        #expect(anime.score == 9.1)
        #expect(anime.images.bestURL?.absoluteString.hasSuffix("94745l.jpg") == true)
    }
}
