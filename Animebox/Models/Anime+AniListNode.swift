//
//  Anime+AniListNode.swift
//  Animebox
//

import Foundation

/// Traduce el shape GraphQL de AniList (`AniListMediaNode`) al `Anime` ya
/// existente en la app — mismo patrón de bridge explícito que
/// `Anime+MALNode.swift`, así ningún componente de UI necesita saber de
/// dónde vino el dato.
extension Anime {
    init(aniListNode node: AniListMediaNode) {
        self.init(
            malId: node.id,
            url: "https://anilist.co/anime/\(node.id)",
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
            episodes: node.episodes,
            status: node.status,
            airing: node.status == "RELEASING",
            synopsis: node.description?.strippingHTML(),
            score: node.averageScore.map { Double($0) / 10 },
            scoredBy: nil,
            rank: nil,
            popularity: node.popularity,
            members: node.popularity,
            favorites: nil,
            year: node.startDate?.year,
            season: nil,
            // AniList devuelve géneros como strings sueltos, sin ID propio.
            // `hashValue` es un ID opaco solo para Identifiable/ForEach en
            // este render — nunca se usa para filtrar (eso pasa por nombre,
            // ver `AniListContentService.searchAnime`), así que no importa
            // que no coincida con la numeración de `MALGenres`.
            genres: node.genres?.map { NamedEntity(malId: $0.hashValue, type: "anime", name: $0, url: nil) },
            studios: nil,
            aired: DateRange(from: node.startDate?.isoString, to: node.endDate?.isoString),
            relations: node.relations?.edges.map { $0.asRelationGroup() }
        )
    }
}

extension AniListRelationEdge {
    func asRelationGroup() -> RelationGroup {
        RelationGroup(
            relation: AniListRelationTypeMapping.titleCase(for: relationType),
            entry: [
                RelationGroupEntry(
                    malId: node.id,
                    type: node.type.lowercased(),
                    name: node.title.romaji ?? node.title.english ?? "",
                    images: MediaImages(
                        jpg: ImageSet(
                            imageUrl: node.coverImage?.medium,
                            smallImageUrl: node.coverImage?.medium,
                            largeImageUrl: node.coverImage?.large
                        ),
                        webp: nil
                    )
                )
            ]
        )
    }
}

/// El `MediaRelation` de AniList llega en SCREAMING_SNAKE_CASE (`PREQUEL`,
/// `SIDE_STORY`...) — se traduce al mismo Title Case que ya usa Tenrai
/// (`"Prequel"`, `"Side Story"`...) para que `RelationTypeLocalization`
/// funcione igual sin importar el backend.
enum AniListRelationTypeMapping {
    static func titleCase(for relationType: String) -> String {
        table[relationType] ?? "Other"
    }

    private static let table: [String: String] = [
        "PREQUEL": "Prequel",
        "SEQUEL": "Sequel",
        "SIDE_STORY": "Side Story",
        "PARENT": "Parent Story",
        "CHARACTER": "Character",
        "SUMMARY": "Summary",
        "ALTERNATIVE": "Alternative Version",
        "SPIN_OFF": "Spin-Off",
        "ADAPTATION": "Adaptation"
    ]
}

extension String {
    /// Las sinopsis de AniList vienen en HTML simple (`<br>`, `<i>`...) a
    /// diferencia del texto plano de Jikan/MAL — se limpia para mostrarla
    /// igual que las demás. No es un parser HTML completo, solo cubre las
    /// etiquetas que AniList realmente usa en descripciones.
    func strippingHTML() -> String {
        replacingOccurrences(of: "<br><br>", with: "\n\n")
            .replacingOccurrences(of: "<br>", with: "\n")
            .replacingOccurrences(of: "</p><p>", with: "\n\n")
            .replacingOccurrences(of: #"<[^>]+>"#, with: "", options: .regularExpression)
    }
}
