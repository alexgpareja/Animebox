//
//  AnimeRatingFilter.swift
//  Animebox
//

import Foundation

/// No incluye "rx" (Hentai): `JikanService.searchAnime` ya fuerza `sfw=true`
/// en todas las búsquedas, así que ese rating nunca podría devolver resultados.
enum AnimeRatingFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case g
    case pg
    case pg13
    case r17
    case r

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: String(localized: "Todos")
        case .g: String(localized: "G - Todos los públicos")
        case .pg: String(localized: "PG - Infantil")
        case .pg13: String(localized: "PG-13")
        case .r17: String(localized: "R-17+")
        case .r: String(localized: "R+")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
