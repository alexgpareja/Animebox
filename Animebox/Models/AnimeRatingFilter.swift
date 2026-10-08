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
        case .all: AppLanguage.current.string("Todos")
        case .g: AppLanguage.current.string("G - Todos los públicos")
        case .pg: AppLanguage.current.string("PG - Infantil")
        case .pg13: AppLanguage.current.string("PG-13")
        case .r17: AppLanguage.current.string("R-17+")
        case .r: AppLanguage.current.string("R+")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
