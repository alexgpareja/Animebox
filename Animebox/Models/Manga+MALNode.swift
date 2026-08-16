//
//  Manga+MALNode.swift
//  Animebox
//

import Foundation

extension Manga {
    init(malNode node: MALMangaNode) {
        self.init(
            malId: node.id,
            url: "https://myanimelist.net/manga/\(node.id)",
            images: MediaImages(
                jpg: ImageSet(
                    imageUrl: node.mainPicture?.medium,
                    smallImageUrl: node.mainPicture?.medium,
                    largeImageUrl: node.mainPicture?.large
                ),
                webp: nil
            ),
            title: node.title,
            titleEnglish: node.alternativeTitles?.en,
            titleJapanese: node.alternativeTitles?.ja,
            type: node.mediaType,
            chapters: node.numChapters,
            volumes: node.numVolumes,
            status: node.status,
            publishing: node.status == "currently_publishing",
            synopsis: node.synopsis,
            score: node.mean,
            scoredBy: node.numListUsers,
            rank: node.rank,
            popularity: node.popularity,
            members: node.numListUsers,
            favorites: nil,
            genres: node.genres?.map { NamedEntity(malId: $0.id, type: "manga", name: $0.name, url: nil) }
        )
    }
}
