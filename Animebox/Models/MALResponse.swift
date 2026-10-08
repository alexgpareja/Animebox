//
//  MALResponse.swift
//  Animebox
//

import Foundation

/// Formas de respuesta de la API oficial de MAL v2 — distintas de las de
/// Jikan (`JikanResponse.swift`): las listas envuelven cada elemento en un
/// `node` (más `list_status` si el endpoint es la lista del usuario), y la
/// paginación es un cursor `paging.next`, no offset/página.
nonisolated struct MALListResponse<Node: Decodable & Sendable>: Decodable, Sendable {
    let data: [MALListNode<Node>]
    let paging: MALPaging?
}

nonisolated struct MALListNode<Node: Decodable & Sendable>: Decodable, Sendable {
    let node: Node
    let listStatus: MALAnimeListStatus?

    enum CodingKeys: String, CodingKey {
        case node
        case listStatus = "list_status"
    }
}

nonisolated struct MALPaging: Decodable, Sendable {
    let next: String?
}

// MARK: - Nodo de anime

nonisolated struct MALAnimeNode: Decodable, Sendable {
    let id: Int
    let title: String
    let mainPicture: MALMainPicture?
    let alternativeTitles: MALAlternativeTitles?
    let synopsis: String?
    let mean: Double?
    let rank: Int?
    let popularity: Int?
    let numListUsers: Int?
    let genres: [MALGenre]?
    let studios: [MALGenre]?
    let mediaType: String?
    let status: String?
    let numEpisodes: Int?
    let startSeason: MALStartSeason?
    let startDate: String?
    let endDate: String?
    let relatedAnime: [MALRelatedNode]?

    enum CodingKeys: String, CodingKey {
        case id, title, synopsis, mean, rank, popularity, genres, studios, status
        case mainPicture = "main_picture"
        case alternativeTitles = "alternative_titles"
        case numListUsers = "num_list_users"
        case mediaType = "media_type"
        case numEpisodes = "num_episodes"
        case startSeason = "start_season"
        case startDate = "start_date"
        case endDate = "end_date"
        case relatedAnime = "related_anime"
    }
}

// MARK: - Nodo de manga

nonisolated struct MALMangaNode: Decodable, Sendable {
    let id: Int
    let title: String
    let mainPicture: MALMainPicture?
    let alternativeTitles: MALAlternativeTitles?
    let synopsis: String?
    let mean: Double?
    let rank: Int?
    let popularity: Int?
    let numListUsers: Int?
    let genres: [MALGenre]?
    let mediaType: String?
    let status: String?
    let numChapters: Int?
    let numVolumes: Int?
    let startDate: String?
    let endDate: String?
    let relatedManga: [MALRelatedNode]?

    enum CodingKeys: String, CodingKey {
        case id, title, synopsis, mean, rank, popularity, genres, status
        case mainPicture = "main_picture"
        case alternativeTitles = "alternative_titles"
        case numListUsers = "num_list_users"
        case mediaType = "media_type"
        case numChapters = "num_chapters"
        case numVolumes = "num_volumes"
        case startDate = "start_date"
        case endDate = "end_date"
        case relatedManga = "related_manga"
    }
}

// MARK: - Tipos compartidos

nonisolated struct MALMainPicture: Decodable, Sendable {
    let medium: String?
    let large: String?
}

nonisolated struct MALAlternativeTitles: Decodable, Sendable {
    let en: String?
    let ja: String?
}

nonisolated struct MALGenre: Decodable, Sendable {
    let id: Int
    let name: String
}

nonisolated struct MALStartSeason: Decodable, Sendable {
    let year: Int?
    let season: String?
}

/// `related_anime`/`related_manga` — a diferencia de `relations` de Jikan
/// (que mezcla anime y manga en el mismo array), MAL ya separa por campo
/// según el tipo del recurso padre, así que no hace falta un `type` aquí.
nonisolated struct MALRelatedNode: Decodable, Sendable {
    let node: MALRelatedNodeInfo
    let relationTypeFormatted: String?

    enum CodingKeys: String, CodingKey {
        case node
        case relationTypeFormatted = "relation_type_formatted"
    }
}

nonisolated struct MALRelatedNodeInfo: Decodable, Sendable {
    let id: Int
    let title: String
    let mainPicture: MALMainPicture?

    enum CodingKeys: String, CodingKey {
        case id, title
        case mainPicture = "main_picture"
    }
}

extension MALRelatedNode {
    /// Empaqueta como un `RelationGroup` de una sola entrada — mismo shape
    /// canónico que usa el bridge de Jikan (`RelatedEntry`), para que
    /// `Anime.relatedAnime`/`Manga.relatedManga` no necesiten saber de
    /// dónde vino el dato.
    func asRelationGroup(entryType: String) -> RelationGroup {
        RelationGroup(
            relation: relationTypeFormatted ?? "Other",
            entry: [
                RelationGroupEntry(
                    malId: node.id,
                    type: entryType,
                    name: node.title,
                    images: MediaImages(
                        jpg: ImageSet(
                            imageUrl: node.mainPicture?.medium,
                            smallImageUrl: node.mainPicture?.medium,
                            largeImageUrl: node.mainPicture?.large
                        ),
                        webp: nil
                    )
                )
            ]
        )
    }
}

/// `list_status` embebido cuando se lee `/v2/users/@me/animelist` o
/// `/mangalist` — campos de anime y manga combinados (cada lado solo rellena
/// los suyos), porque MAL usa el mismo shape con distinto subconjunto activo.
nonisolated struct MALAnimeListStatus: Decodable, Sendable {
    let status: String?
    let score: Int?
    let numEpisodesWatched: Int?
    let numChaptersRead: Int?
    let numVolumesRead: Int?
    let startDate: String?
    let finishDate: String?
    let updatedAt: String?

    enum CodingKeys: String, CodingKey {
        case status, score
        case numEpisodesWatched = "num_episodes_watched"
        case numChaptersRead = "num_chapters_read"
        case numVolumesRead = "num_volumes_read"
        case startDate = "start_date"
        case finishDate = "finish_date"
        case updatedAt = "updated_at"
    }
}
