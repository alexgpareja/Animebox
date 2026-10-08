//
//  RelatedEntry.swift
//  Animebox
//

import Foundation

/// Rango de fechas crudo tal cual llega de cada backend — Jikan usa
/// datetime ISO8601 completo ("1999-10-20T00:00:00+00:00"), MAL v2 usa
/// solo fecha ("1999-10-20"). El parseo/formato para mostrar en pantalla
/// vive en `AiredDateFormatter`, no aquí.
nonisolated struct DateRange: Codable, Hashable, Sendable {
    let from: String?
    let to: String?
}

/// Shape de `relations` de Jikan (`/anime|manga/{id}/full`): grupos por tipo
/// de relación ("Sequel", "Prequel", "Adaptation"...), cada uno con una o
/// más entradas que pueden ser anime O manga indistintamente (p. ej.
/// "Adaptation" en un anime apunta a su manga origen) — de ahí el filtro
/// por `type` en `relatedEntries(ofType:)`.
nonisolated struct RelationGroup: Codable, Hashable, Sendable {
    let relation: String
    let entry: [RelationGroupEntry]
}

nonisolated struct RelationGroupEntry: Codable, Hashable, Sendable {
    let malId: Int
    let type: String
    let name: String
    let images: MediaImages?

    enum CodingKeys: String, CodingKey {
        case malId = "mal_id"
        case type, name, images
    }
}

/// Forma aplanada y ya filtrada por tipo — lo que consume la UI
/// (`RelatedMediaSection`), sin que le importe si vino de Jikan o de MAL.
nonisolated struct RelatedEntry: Hashable, Sendable, Identifiable {
    let malId: Int
    let title: String
    let imageURL: String?
    let relation: String

    var id: Int { malId }
}

extension Anime {
    /// Construye un Anime mínimo a partir de una entrada de `relatedAnime`
    /// para navegar a su detalle — mismo mecanismo que `init(libraryEntry:)`,
    /// AnimeDetailView completa el resto vía `refreshDetails()` al aparecer.
    init(relatedEntry entry: RelatedEntry) {
        self.init(
            malId: entry.malId,
            url: nil,
            images: MediaImages(
                jpg: ImageSet(imageUrl: entry.imageURL, smallImageUrl: entry.imageURL, largeImageUrl: entry.imageURL),
                webp: nil
            ),
            title: entry.title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            episodes: nil,
            status: nil,
            airing: nil,
            synopsis: nil,
            score: nil,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            year: nil,
            season: nil,
            genres: nil,
            studios: nil,
            aired: nil,
            relations: nil
        )
    }
}

extension Manga {
    /// Ver `Anime.init(relatedEntry:)` — mismo mecanismo para manga.
    init(relatedEntry entry: RelatedEntry) {
        self.init(
            malId: entry.malId,
            url: nil,
            images: MediaImages(
                jpg: ImageSet(imageUrl: entry.imageURL, smallImageUrl: entry.imageURL, largeImageUrl: entry.imageURL),
                webp: nil
            ),
            title: entry.title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            chapters: nil,
            volumes: nil,
            status: nil,
            publishing: nil,
            synopsis: nil,
            score: nil,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            genres: nil,
            published: nil,
            relations: nil
        )
    }
}

extension [RelationGroup] {
    func relatedEntries(ofType type: String) -> [RelatedEntry] {
        flatMap { group in
            group.entry
                .filter { $0.type == type }
                .map { entry in
                    RelatedEntry(
                        malId: entry.malId,
                        title: entry.name,
                        imageURL: entry.images?.bestURL?.absoluteString,
                        relation: group.relation
                    )
                }
        }
    }
}
