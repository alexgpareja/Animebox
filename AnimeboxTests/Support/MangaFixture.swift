//
//  MangaFixture.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

extension Manga {
    static func fixture(
        id: Int = 1,
        title: String = "Test Manga",
        score: Double? = 8.5
    ) -> Manga {
        Manga(
            malId: id,
            url: nil,
            images: MediaImages(
                jpg: ImageSet(imageUrl: nil, smallImageUrl: nil, largeImageUrl: nil),
                webp: nil
            ),
            title: title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            chapters: nil,
            volumes: nil,
            status: nil,
            publishing: nil,
            synopsis: nil,
            score: score,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            genres: nil
        )
    }
}
