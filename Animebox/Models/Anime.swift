//
//  Anime.swift
//  Animebox
//

import Foundation

nonisolated struct Anime: Identifiable, Codable, Hashable, Sendable, MediaSummary {
    let malId: Int
    let url: String?
    let images: MediaImages
    let title: String
    let titleEnglish: String?
    let titleJapanese: String?
    let type: String?
    let episodes: Int?
    let status: String?
    let airing: Bool?
    let synopsis: String?
    let score: Double?
    let scoredBy: Int?
    let rank: Int?
    let popularity: Int?
    let members: Int?
    let favorites: Int?
    let year: Int?
    let season: String?
    let genres: [NamedEntity]?
    let studios: [NamedEntity]?
    let aired: DateRange?
    let relations: [RelationGroup]?

    var id: Int { malId }

    var displayTitle: String {
        titleEnglish?.isEmpty == false ? (titleEnglish ?? title) : title
    }

    var posterURL: URL? { images.bestURL }

    /// Temporadas anteriores/siguientes, precuelas/secuelas — filtra
    /// `relations` a solo entradas de tipo anime (Jikan mezcla anime y
    /// manga en el mismo array, p. ej. "Adaptation" apunta al manga origen).
    var relatedAnime: [RelatedEntry] { relations?.relatedEntries(ofType: "anime") ?? [] }

    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case url, images, title
        case titleEnglish = "title_english"
        case titleJapanese = "title_japanese"
        case type, episodes, status, airing, synopsis, score
        case scoredBy = "scored_by"
        case rank, popularity, members, favorites, year, season, genres, studios, aired, relations
    }
}

nonisolated struct MediaImages: Codable, Hashable, Sendable {
    let jpg: ImageSet
    let webp: ImageSet?

    var bestURL: URL? {
        if let urlString = jpg.largeImageUrl ?? jpg.imageUrl {
            return URL(string: urlString)
        }
        return nil
    }
}

nonisolated struct ImageSet: Codable, Hashable, Sendable {
    let imageUrl: String?
    let smallImageUrl: String?
    let largeImageUrl: String?

    enum CodingKeys: String, CodingKey {
        case imageUrl = "image_url"
        case smallImageUrl = "small_image_url"
        case largeImageUrl = "large_image_url"
    }
}

nonisolated struct NamedEntity: Codable, Hashable, Sendable, Identifiable {
    let malId: Int
    let type: String?
    let name: String
    let url: String?

    var id: Int { malId }

    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case type, name, url
    }
}
