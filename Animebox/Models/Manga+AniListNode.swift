//
//  Manga+AniListNode.swift
//  Animebox
//

import Foundation

extension Manga {
    init(aniListNode node: AniListMediaNode) {
        self.init(
            malId: node.id,
            url: "https://anilist.co/manga/\(node.id)",
            images: MediaImages(
                jpg: ImageSet(
                    imageUrl: node.coverImage?.medium,
                    smallImageUrl: node.coverImage?.medium,
                    largeImageUrl: node.coverImage?.large
                ),
                webp: nil
            ),
            title: node.title.romaji ?? node.title.english ?? "",
            titleEnglish: node.title.english,
            titleJapanese: node.title.native,
            type: node.format,
            chapters: node.chapters,
            volumes: node.volumes,
            status: node.status,
            publishing: node.status == "RELEASING",
            synopsis: node.description?.strippingHTML(),
            score: node.averageScore.map { Double($0) / 10 },
            scoredBy: nil,
            rank: nil,
            popularity: node.popularity,
            members: node.popularity,
            favorites: nil,
            genres: node.genres?.map { NamedEntity(malId: $0.hashValue, type: "manga", name: $0, url: nil) },
            published: DateRange(from: node.startDate?.isoString, to: node.endDate?.isoString),
            relations: node.relations?.edges.map { $0.asRelationGroup() }
        )
    }
}
