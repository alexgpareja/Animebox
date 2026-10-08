//
//  Manga.swift
//  Animebox
//

import Foundation

nonisolated struct Manga: Identifiable, Codable, Hashable, Sendable, MediaSummary {
    let malId: Int
    let url: String?
    let images: MediaImages
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let type: String?
    let chapters: Int?
    let volumes: Int?
    let status: String?
    let publishing: Bool?
    let synopsis: String?
    let score: Double?
    let scoredBy: Int?
    let rank: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let genres: [NamedEntity]?
    let published: DateRange?
    let relations: [RelationGroup]?

    var id: Int { malId }

    var displayTitle: String {
        titleEnglish?.isEmpty == false ? (titleEnglish ?? title) : title
    }

    var posterURL: URL? { images.bestURL }

    /// Ver `Anime.relatedAnime` — mismo mecanismo, filtrado a tipo manga.
    var relatedManga: [RelatedEntry] { relations?.relatedEntries(ofType: "manga") ?? [] }

    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case url, images, title
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case type, chapters, volumes, status, publishing, synopsis, score
        case scoredBy = "scored_by"
        case rank, popularity, members, favorites, genres, published, relations
    }
}
