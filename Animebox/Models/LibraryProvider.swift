//
//  LibraryProvider.swift
//  Animebox
//

import Foundation

/// De qué cuenta oficial viene una entrada guardada — MAL y Tenrai (su
/// contenido) comparten el mismo espacio de `mal_id`, así que todo lo
/// existente antes de esta feature es implícitamente `.mal`. AniList tiene
/// su propio espacio de IDs (`Media.id`), por eso `malId` deja de ser único
/// globalmente y pasa a serlo solo junto con `provider` — ver
/// `LibraryStore`/`MangaStore.entry(for:)`.
enum LibraryProvider: String, Codable, Sendable {
    case mal
    case aniList
}
