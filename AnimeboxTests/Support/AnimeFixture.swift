//
//  AnimeFixture.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

extension Anime {
    static func fixture(
        id: Int = 1,
        title: String = "Test Anime",
        score: Double? = 8.5
    ) -> Anime {
        Anime(
            malId: id,
            url: nil,
            images: AnimeImages(
                jpg: ImageSet(imageUrl: nil, smallImageUrl: nil, largeImageUrl: nil),
                webp: nil
            ),
            title: title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            episodes: nil,
            status: nil,
            airing: nil,
            synopsis: nil,
            score: score,
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
