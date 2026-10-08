//
//  AniListContentService.swift
//  Animebox
//

import Foundation

/// `ContentServicing` contra la API GraphQL de AniList — usado por
/// `ContentRouter` cuando la cuenta activa es AniList. A diferencia de MAL,
/// AniList sí soporta filtros de servidor reales (género, formato, fecha),
/// así que no hace falta el mecanismo de "pool amplio + filtro en cliente"
/// que sí necesita `MALContentService`.
///
/// **Limitaciones conocidas y aceptadas**: `rating` no tiene equivalente en
/// AniList (se ignora, igual que MAL); `genre_in` de AniList filtra por
/// nombre de género (`AniListGenres`), no por el ID de `MALGenres` — un
/// género seleccionado se traduce por nombre antes de mandarlo, así que solo
/// funciona para los géneros que existen en ambos catálogos con el mismo
/// nombre en inglés (la inmensa mayoría). `animeThemes()`/`mangaThemes()`
/// devuelven vacío — AniList no tiene un equivalente razonable a los ~50
/// temas de `MALGenres` (sus "tags" son un catálogo de cientos de entradas).
struct AniListContentService: ContentServicing {
    let api: AniListAPIService

    init(aniListSession: AniListSession) {
        self.api = AniListAPIService(aniListSession: aniListSession)
    }

    init(api: AniListAPIService) {
        self.api = api
    }

    private static let mediaFields = """
    id
    title { romaji english native }
    coverImage { large medium }
    format
    status
    description
    averageScore
    popularity
    episodes
    chapters
    volumes
    genres
    startDate { year month day }
    """

    private static let mediaDetailFields = mediaFields + """

    endDate { year month day }
    relations {
        edges {
            relationType
            node { id type title { romaji english native } coverImage { large medium } }
        }
    }
    """

    func topAnime(limit: Int = 25) async throws -> [Anime] {
        try await fetchPage(type: "ANIME", sort: "SCORE_DESC", limit: limit).map(Anime.init(aniListNode:))
    }

    func currentSeason(limit: Int = 25) async throws -> [Anime] {
        let (year, season) = Self.currentSeasonInfo()
        return try await fetchPage(
            type: "ANIME", sort: "POPULARITY_DESC", limit: limit, season: season, seasonYear: year
        ).map(Anime.init(aniListNode:))
    }

    func searchAnime(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        rating: String?,
        startDate: String?,
        endDate: String?,
        limit: Int = 25
    ) async throws -> [Anime] {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasFilters = status != nil || !(genres?.isEmpty ?? true) || type != nil || startDate != nil || endDate != nil
        guard !(trimmedQuery?.isEmpty ?? true) || hasFilters else { return [] }

        return try await fetchPage(
            type: "ANIME", sort: "POPULARITY_DESC", limit: limit,
            query: trimmedQuery, status: status, genres: genres, format: type,
            startDate: startDate, endDate: endDate
        ).map(Anime.init(aniListNode:))
    }

    func animeDetails(id: Int) async throws -> Anime {
        Anime(aniListNode: try await fetchMedia(id: id))
    }

    func animeGenres() async throws -> [NamedEntity] {
        AniListGenres.genres
    }

    /// Ver nota de limitaciones en el doc del tipo.
    func animeThemes() async throws -> [NamedEntity] { [] }

    func topManga(limit: Int = 25) async throws -> [Manga] {
        try await fetchPage(type: "MANGA", sort: "SCORE_DESC", limit: limit).map(Manga.init(aniListNode:))
    }

    func currentlyPublishingManga(limit: Int = 25) async throws -> [Manga] {
        try await fetchPage(
            type: "MANGA", sort: "POPULARITY_DESC", limit: limit, status: "publishing"
        ).map(Manga.init(aniListNode:))
    }

    func searchManga(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        startDate: String?,
        endDate: String?,
        limit: Int = 25
    ) async throws -> [Manga] {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasFilters = status != nil || !(genres?.isEmpty ?? true) || type != nil || startDate != nil || endDate != nil
        guard !(trimmedQuery?.isEmpty ?? true) || hasFilters else { return [] }

        return try await fetchPage(
            type: "MANGA", sort: "POPULARITY_DESC", limit: limit,
            query: trimmedQuery, status: status, genres: genres, format: type,
            startDate: startDate, endDate: endDate
        ).map(Manga.init(aniListNode:))
    }

    func mangaDetails(id: Int) async throws -> Manga {
        Manga(aniListNode: try await fetchMedia(id: id))
    }

    func mangaGenres() async throws -> [NamedEntity] {
        AniListGenres.genres
    }

    func mangaThemes() async throws -> [NamedEntity] { [] }

    // MARK: - Fetch

    private func fetchMedia(id: Int) async throws -> AniListMediaNode {
        let query = """
        query ($id: Int!) {
            Media(id: $id) {
                \(Self.mediaDetailFields)
            }
        }
        """
        let response = try await api.graphQL(
            query: query, variables: ["id": id], as: AniListMediaResponse.self
        )
        return response.Media
    }

    /// Construye y ejecuta la query `Page(media(...))` — `format`/`genres`
    /// (nombres, no IDs) / `search` / `status` / rango de fecha se aplican
    /// todos en el servidor cuando llegan, a diferencia de MAL.
    private func fetchPage(
        type: String,
        sort: String,
        limit: Int,
        query: String? = nil,
        status: String? = nil,
        genres: [Int]? = nil,
        format: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        season: String? = nil,
        seasonYear: Int? = nil
    ) async throws -> [AniListMediaNode] {
        var variables: [String: Any] = ["type": type, "sort": [sort], "perPage": limit]

        if let query, !query.isEmpty { variables["search"] = query }
        if let status = Self.aniListStatus(fromLocal: status) { variables["status"] = status }
        if let genres, !genres.isEmpty {
            let names = genres.compactMap(AniListGenres.name(forId:))
            if !names.isEmpty { variables["genre_in"] = names }
        }
        if let format = Self.aniListFormat(fromLocal: format) { variables["format"] = format }
        if let startDate, let fuzzy = Self.fuzzyDateInt(from: startDate) { variables["startDate_greater"] = fuzzy }
        if let endDate, let fuzzy = Self.fuzzyDateInt(from: endDate) { variables["startDate_lesser"] = fuzzy }
        if let season { variables["season"] = season }
        if let seasonYear { variables["seasonYear"] = seasonYear }

        let response = try await api.graphQL(query: Self.pageQuery, variables: variables, as: AniListPageResponse.self)
        return response.Page.media
    }

    /// La query siempre declara y **referencia** las 11 variables posibles
    /// en el cuerpo, aunque una llamada concreta no las necesite todas — a
    /// diferencia de lo que dice la sabiduría popular sobre GraphQL, AniList
    /// SÍ valida `NoUnusedVariables` en el servidor: una variable declarada
    /// en la cabecera que no aparece en ningún argumento del cuerpo es un
    /// error 400 (`"Variable \"$x\" is never used."`), confirmado contra la
    /// API real — antes `args` solo incluía las variables usadas por esa
    /// llamada concreta, así que top/search/season/manga fallaban siempre.
    /// Una variable referenciada pero ausente de `variables` (dict de Swift
    /// arriba) resuelve a `null` sin problema, ya que ninguna es `!`
    /// (non-null) en `variableDeclarations`.
    private static let variableDeclarations = """
    $type: MediaType, $sort: [MediaSort], $perPage: Int, $search: String, $status: MediaStatus,
    $genre_in: [String], $format: MediaFormat, $startDate_greater: FuzzyDateInt, $startDate_lesser: FuzzyDateInt,
    $season: MediaSeason, $seasonYear: Int
    """

    private static let pageQuery = """
    query (\(variableDeclarations)) {
        Page(perPage: $perPage) {
            media(
                type: $type, sort: $sort, search: $search, status: $status, genre_in: $genre_in,
                format: $format, startDate_greater: $startDate_greater, startDate_lesser: $startDate_lesser,
                season: $season, seasonYear: $seasonYear
            ) {
                \(mediaFields)
            }
        }
    }
    """

    private static func aniListStatus(fromLocal raw: String?) -> String? {
        switch raw {
        case "airing", "publishing": "RELEASING"
        case "complete": "FINISHED"
        case "upcoming": "NOT_YET_RELEASED"
        default: nil
        }
    }

    private static func aniListFormat(fromLocal raw: String?) -> String? {
        guard let raw else { return nil }
        let aliases: [String: String] = [
            "tv": "TV", "movie": "MOVIE", "ova": "OVA", "special": "SPECIAL",
            "ona": "ONA", "music": "MUSIC", "manga": "MANGA", "novel": "NOVEL",
            "lightnovel": "NOVEL", "oneshot": "ONE_SHOT", "doujin": "MANGA", "manhwa": "MANGA", "manhua": "MANGA"
        ]
        return aliases[raw.lowercased()]
    }

    /// `FuzzyDateInt` es `YYYYMMDD` como entero — `startDate` llega como
    /// año plano (`"2020"`) desde los filtros de búsqueda de la app.
    private static func fuzzyDateInt(from raw: String) -> Int? {
        guard let year = Int(raw.prefix(4)) else { return nil }
        return year * 10000
    }

    static func currentSeasonInfo(now: Date = .now, calendar: Calendar = .current) -> (year: Int, season: String) {
        let components = calendar.dateComponents([.year, .month], from: now)
        let month = components.month ?? 1
        let season: String
        switch month {
        case 1...3: season = "WINTER"
        case 4...6: season = "SPRING"
        case 7...9: season = "SUMMER"
        default: season = "FALL"
        }
        return (components.year ?? calendar.component(.year, from: now), season)
    }
}
