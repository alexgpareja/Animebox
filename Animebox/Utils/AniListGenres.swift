//
//  AniListGenres.swift
//  Animebox
//

import Foundation

/// AniList expone un `GenreCollection` fijo de ~18 géneros, iguales para
/// anime y manga (a diferencia de MAL/Jikan, no separa "temas" como una
/// categoría propia — sus "tags" son un catálogo de cientos de entradas sin
/// equivalente razonable a `MALGenres`' ~50 temas, así que
/// `AniListContentService.animeThemes()/mangaThemes()` devuelven vacío en
/// vez de construir algo a medias). IDs asignados aquí mismo (AniList no da
/// un ID por género, son strings) — `AniListContentService.searchAnime`
/// convierte de vuelta a nombre antes de pedir `genre_in` a la API.
nonisolated enum AniListGenres {
    static let genres: [NamedEntity] = [
        "Action", "Adventure", "Comedy", "Drama", "Ecchi", "Fantasy", "Hentai",
        "Horror", "Mahou Shoujo", "Mecha", "Music", "Mystery", "Psychological",
        "Romance", "Sci-Fi", "Slice of Life", "Sports", "Supernatural", "Thriller"
    ].enumerated().map { index, name in
        NamedEntity(malId: index, type: "anilist", name: name, url: nil)
    }

    static func name(forId id: Int) -> String? {
        genres.first(where: { $0.malId == id })?.name
    }
}
