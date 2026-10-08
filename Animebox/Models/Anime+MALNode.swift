//
//  Anime+MALNode.swift
//  Animebox
//

import Foundation

/// Traduce el shape de MAL v2 (`MALAnimeNode`) al `Anime` ya existente en la
/// app, siguiendo el mismo patrón de bridge explícito que `Anime+LibraryEntry.swift`
/// en vez de una segunda conformidad `Codable` — así ningún componente de UI
/// (`MediaCard`, `MediaDetailHero`...) necesita saber de dónde vino el dato.
extension Anime {
    init(malNode node: MALAnimeNode) {
        self.init(
            malId: node.id,
            url: "https://myanimelist.net/anime/\(node.id)",
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
            episodes: node.numEpisodes,
            status: node.status,
            airing: node.status == "currently_airing",
            synopsis: node.synopsis,
            score: node.mean,
            scoredBy: node.numListUsers,
            rank: node.rank,
            popularity: node.popularity,
            members: node.numListUsers,
            favorites: nil,
            year: node.startSeason?.year,
            season: node.startSeason?.season,
            genres: node.genres?.map { NamedEntity(malId: $0.id, type: "anime", name: $0.name, url: nil) },
            studios: node.studios?.map { NamedEntity(malId: $0.id, type: "anime", name: $0.name, url: nil) },
            aired: DateRange(from: node.startDate, to: node.endDate),
            relations: node.relatedAnime?.map { $0.asRelationGroup(entryType: "anime") }
        )
    }
}
