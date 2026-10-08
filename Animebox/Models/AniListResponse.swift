//
//  AniListResponse.swift
//  Animebox
//

import Foundation

/// Formas de respuesta GraphQL de AniList — un único endpoint, el campo de
/// nivel superior ("Page", "Media", "MediaListCollection"...) varía según la
/// query/mutation, así que cada llamada decodifica su propio envoltorio en
/// vez de compartir uno genérico por REST como `MALListResponse`.
nonisolated struct AniListGraphQLEnvelope<T: Decodable & Sendable>: Decodable, Sendable {
    let data: T?
}

nonisolated struct AniListPageResponse: Decodable, Sendable {
    let Page: AniListMediaPage
}

nonisolated struct AniListMediaPage: Decodable, Sendable {
    let media: [AniListMediaNode]
}

nonisolated struct AniListMediaResponse: Decodable, Sendable {
    let Media: AniListMediaNode
}

nonisolated struct AniListMediaNode: Decodable, Sendable {
    let id: Int
    let title: AniListMediaTitle
    let coverImage: AniListCoverImage?
    let format: String?
    let status: String?
    let description: String?
    let averageScore: Int?
    let popularity: Int?
    let episodes: Int?
    let chapters: Int?
    let volumes: Int?
    let genres: [String]?
    let startDate: AniListFuzzyDate?
    let endDate: AniListFuzzyDate?
    let relations: AniListRelationConnection?
    /// Solo presente si la petición estaba autenticada — la entrada del
    /// usuario en su propia lista para este media, si existe. Tipo propio
    /// sin `media` anidado (a diferencia de `AniListMediaListEntry`) para
    /// no crear un ciclo de tipo valor de tamaño infinito.
    let mediaListEntry: AniListMediaListEntryRef?
}

nonisolated struct AniListMediaListEntryRef: Decodable, Sendable {
    let id: Int
    let status: String?
}

nonisolated struct AniListMediaTitle: Decodable, Sendable {
    let romaji: String?
    let english: String?
    let native: String?
}

nonisolated struct AniListCoverImage: Decodable, Sendable {
    let large: String?
    let medium: String?
}

nonisolated struct AniListFuzzyDate: Decodable, Sendable {
    let year: Int?
    let month: Int?
    let day: Int?

    /// A ISO8601 sin hora, mismo formato "yyyy-MM-dd" que ya sabe parsear
    /// `AiredDateFormatter` para MAL — así el bridge no necesita tocarlo.
    var isoString: String? {
        guard let year else { return nil }
        return String(format: "%04d-%02d-%02d", year, month ?? 1, day ?? 1)
    }
}

nonisolated struct AniListRelationConnection: Decodable, Sendable {
    let edges: [AniListRelationEdge]
}

nonisolated struct AniListRelationEdge: Decodable, Sendable {
    let relationType: String
    let node: AniListRelationNode
}

nonisolated struct AniListRelationNode: Decodable, Sendable {
    let id: Int
    let type: String
    let title: AniListMediaTitle
    let coverImage: AniListCoverImage?
}

// MARK: - Lista del usuario

nonisolated struct AniListMediaListCollectionResponse: Decodable, Sendable {
    let MediaListCollection: AniListMediaListCollection
}

nonisolated struct AniListMediaListCollection: Decodable, Sendable {
    let lists: [AniListMediaListGroup]
}

nonisolated struct AniListMediaListGroup: Decodable, Sendable {
    let entries: [AniListMediaListEntry]
}

nonisolated struct AniListMediaListEntry: Decodable, Sendable {
    let id: Int
    let status: String?
    let progress: Int?
    let score: Double?
    let media: AniListMediaNode?
}

nonisolated struct AniListSaveMediaListEntryResponse: Decodable, Sendable {
    let SaveMediaListEntry: AniListSavedEntry
}

nonisolated struct AniListSavedEntry: Decodable, Sendable {
    let id: Int
}

// MARK: - Ajustes de puntuación del usuario

nonisolated struct AniListViewerResponse: Decodable, Sendable {
    let Viewer: AniListViewer
}

nonisolated struct AniListViewer: Decodable, Sendable {
    let id: Int
    let name: String
    let mediaListOptions: AniListMediaListOptions?
}

nonisolated struct AniListMediaListOptions: Decodable, Sendable {
    let scoreFormat: String?
}
