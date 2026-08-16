//
//  MALContentService.swift
//  Animebox
//

import Foundation

/// `ContentServicing` contra la API oficial de MAL v2 — usado por
/// `ContentRouter` cuando hay sesión iniciada. Limitaciones conocidas y
/// aceptadas frente a Jikan (documentadas, no descubiertas por sorpresa):
/// MAL no tiene filtros de género/tipo/rating/fecha en servidor ni endpoint
/// de lista de géneros, así que esos filtros se aplican en cliente sobre un
/// pool más amplio de resultados (búsqueda por texto si hay `q`, ranking si
/// no lo hay, ya que `q` es obligatorio en `/v2/anime`). El filtro de
/// `rating` no se aplica (los códigos de Jikan/`AnimeRatingFilter` no
/// coinciden 1:1 con los de MAL) — queda fuera de v1.
struct MALContentService: ContentServicing {
    let api: APIServicing

    init(malSession: MALSession) {
        self.api = MALAPIService(malSession: malSession)
    }

    init(api: APIServicing) {
        self.api = api
    }

    static let animeFields = "id,title,main_picture,alternative_titles,synopsis,mean,rank,popularity,"
        + "num_list_users,genres,studios,media_type,status,num_episodes,start_season"
    static let mangaFields = "id,title,main_picture,alternative_titles,synopsis,mean,rank,popularity,"
        + "num_list_users,genres,media_type,status,num_chapters,num_volumes"

    func topAnime(limit: Int = 25) async throws -> [Anime] {
        try await fetchAnimeNodes(path: "anime/ranking", extra: [
            URLQueryItem(name: "ranking_type", value: "all")
        ], limit: limit).map(Anime.init(malNode:))
    }

    func currentSeason(limit: Int = 25) async throws -> [Anime] {
        let (year, season) = Self.currentSeasonInfo()
        return try await fetchAnimeNodes(
            path: "anime/season/\(year)/\(season)",
            extra: [URLQueryItem(name: "sort", value: "anime_num_list_users")],
            limit: limit
        ).map(Anime.init(malNode:))
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
        let hasFilters = !(genres?.isEmpty ?? true) || type != nil || startDate != nil || endDate != nil
        guard !(trimmedQuery?.isEmpty ?? true) || hasFilters else { return [] }

        let pool = try await animePool(query: trimmedQuery, limit: limit)
        let filtered = pool.filter { node in
            matchesGenres(node.genres?.map(\.id), selected: genres)
                && matchesType(node.mediaType, selected: type)
                && matchesYear(node.startSeason?.year, startDate: startDate, endDate: endDate)
        }
        return Array(filtered.prefix(limit)).map(Anime.init(malNode:))
    }

    func animeDetails(id: Int) async throws -> Anime {
        let url = try makeURL(path: "anime/\(id)", query: [
            URLQueryItem(name: "fields", value: Self.animeFields)
        ])
        return Anime(malNode: try await api.get(url, as: MALAnimeNode.self))
    }

    func animeGenres() async throws -> [NamedEntity] {
        MALGenres.animeGenres
    }

    func animeThemes() async throws -> [NamedEntity] {
        MALGenres.animeThemes
    }

    func topManga(limit: Int = 25) async throws -> [Manga] {
        try await fetchMangaNodes(path: "manga/ranking", extra: [
            URLQueryItem(name: "ranking_type", value: "all")
        ], limit: limit).map(Manga.init(malNode:))
    }

    /// MAL no tiene un `ranking_type` de "en publicación" (a diferencia de
    /// `anime/season/...` para "en emisión") — se pide un pool amplio del
    /// ranking y se filtra en cliente por `status`, mismo mecanismo que ya
    /// se usa para los filtros de búsqueda cuando hay sesión iniciada.
    func currentlyPublishingManga(limit: Int = 25) async throws -> [Manga] {
        let pool = try await fetchMangaNodesPaginated(
            path: "manga/ranking",
            extra: [URLQueryItem(name: "ranking_type", value: "all")],
            maxPages: Self.maxRankingPages
        )
        return pool
            .filter { $0.status == "currently_publishing" }
            .prefix(limit)
            .map(Manga.init(malNode:))
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
        let hasFilters = !(genres?.isEmpty ?? true) || type != nil || startDate != nil || endDate != nil
        guard !(trimmedQuery?.isEmpty ?? true) || hasFilters else { return [] }

        let pool = try await mangaPool(query: trimmedQuery, limit: limit)
        let filtered = pool.filter { node in
            matchesGenres(node.genres?.map(\.id), selected: genres)
                && matchesType(node.mediaType, selected: type)
        }
        return Array(filtered.prefix(limit)).map(Manga.init(malNode:))
    }

    func mangaDetails(id: Int) async throws -> Manga {
        let url = try makeURL(path: "manga/\(id)", query: [
            URLQueryItem(name: "fields", value: Self.mangaFields)
        ])
        return Manga(malNode: try await api.get(url, as: MALMangaNode.self))
    }

    func mangaGenres() async throws -> [NamedEntity] {
        MALGenres.mangaGenres
    }

    func mangaThemes() async throws -> [NamedEntity] {
        MALGenres.mangaThemes
    }

    // MARK: - Pools (texto si hay query, ranking si no — q es obligatorio en /v2/anime)

    /// Sin texto, el pool sale del ranking general — un género/tema poco
    /// representado entre los más populares (p. ej. Horror, Harem) puede no
    /// aparecer nunca en una sola página de 100. Se pagina el ranking hasta
    /// `maxRankingPages` páginas para darle a esos géneros una oportunidad
    /// real de aparecer, en vez de devolver 0 resultados silenciosamente.
    private static let maxRankingPages = 5

    private func animePool(query: String?, limit: Int) async throws -> [MALAnimeNode] {
        if let query, !query.isEmpty {
            return try await fetchAnimeNodes(
                path: "anime",
                extra: [URLQueryItem(name: "q", value: query)],
                limit: min(limit * 3, 100)
            )
        }
        return try await fetchAnimeNodesPaginated(
            path: "anime/ranking",
            extra: [URLQueryItem(name: "ranking_type", value: "all")],
            maxPages: Self.maxRankingPages
        )
    }

    private func mangaPool(query: String?, limit: Int) async throws -> [MALMangaNode] {
        if let query, !query.isEmpty {
            return try await fetchMangaNodes(
                path: "manga",
                extra: [URLQueryItem(name: "q", value: query)],
                limit: min(limit * 3, 100)
            )
        }
        return try await fetchMangaNodesPaginated(
            path: "manga/ranking",
            extra: [URLQueryItem(name: "ranking_type", value: "all")],
            maxPages: Self.maxRankingPages
        )
    }

    // MARK: - Filtrado en cliente

    private func matchesGenres(_ nodeGenreIDs: [Int]?, selected: [Int]?) -> Bool {
        guard let selected, !selected.isEmpty else { return true }
        guard let nodeGenreIDs else { return false }
        return Set(selected).isSubset(of: Set(nodeGenreIDs))
    }

    private func matchesType(_ nodeType: String?, selected: String?) -> Bool {
        guard let selected else { return true }
        return nodeType?.caseInsensitiveCompare(selected) == .orderedSame
    }

    private func matchesYear(_ nodeYear: Int?, startDate: String?, endDate: String?) -> Bool {
        guard startDate != nil || endDate != nil else { return true }
        guard let nodeYear else { return false }
        let from = startDate.flatMap { Int($0.prefix(4)) }
        let to = endDate.flatMap { Int($0.prefix(4)) }
        if let from, nodeYear < from { return false }
        if let to, nodeYear > to { return false }
        return true
    }

    // MARK: - Fetch + paginado plano de un único bloque `fields=`/`limit=`

    private func fetchAnimeNodes(path: String, extra: [URLQueryItem], limit: Int) async throws -> [MALAnimeNode] {
        let url = try makeURL(path: path, query: extra + [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: Self.animeFields)
        ])
        let response: MALListResponse<MALAnimeNode> = try await api.get(url, as: MALListResponse<MALAnimeNode>.self)
        return response.data.map(\.node)
    }

    private func fetchMangaNodes(path: String, extra: [URLQueryItem], limit: Int) async throws -> [MALMangaNode] {
        let url = try makeURL(path: path, query: extra + [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "fields", value: Self.mangaFields)
        ])
        let response: MALListResponse<MALMangaNode> = try await api.get(url, as: MALListResponse<MALMangaNode>.self)
        return response.data.map(\.node)
    }

    /// Pide `maxPages` páginas de 100 en paralelo vía `offset` (el ranking de
    /// MAL soporta paginado plano por offset) en vez de encadenar
    /// `paging.next` secuencialmente — más rápido para una búsqueda interactiva.
    private func fetchAnimeNodesPaginated(path: String, extra: [URLQueryItem], maxPages: Int) async throws -> [MALAnimeNode] {
        try await withThrowingTaskGroup(of: (Int, [MALAnimeNode]).self) { group in
            for page in 0..<maxPages {
                group.addTask {
                    let url = try makeURL(path: path, query: extra + [
                        URLQueryItem(name: "limit", value: "100"),
                        URLQueryItem(name: "offset", value: String(page * 100)),
                        URLQueryItem(name: "fields", value: Self.animeFields)
                    ])
                    let response: MALListResponse<MALAnimeNode> = try await api.get(url, as: MALListResponse<MALAnimeNode>.self)
                    return (page, response.data.map(\.node))
                }
            }
            var pages: [Int: [MALAnimeNode]] = [:]
            for try await (page, nodes) in group { pages[page] = nodes }
            return (0..<maxPages).flatMap { pages[$0] ?? [] }
        }
    }

    /// Pide `maxPages` páginas de 100 en paralelo vía `offset`. Ver
    /// `fetchAnimeNodesPaginated`.
    private func fetchMangaNodesPaginated(path: String, extra: [URLQueryItem], maxPages: Int) async throws -> [MALMangaNode] {
        try await withThrowingTaskGroup(of: (Int, [MALMangaNode]).self) { group in
            for page in 0..<maxPages {
                group.addTask {
                    let url = try makeURL(path: path, query: extra + [
                        URLQueryItem(name: "limit", value: "100"),
                        URLQueryItem(name: "offset", value: String(page * 100)),
                        URLQueryItem(name: "fields", value: Self.mangaFields)
                    ])
                    let response: MALListResponse<MALMangaNode> = try await api.get(url, as: MALListResponse<MALMangaNode>.self)
                    return (page, response.data.map(\.node))
                }
            }
            var pages: [Int: [MALMangaNode]] = [:]
            for try await (page, nodes) in group { pages[page] = nodes }
            return (0..<maxPages).flatMap { pages[$0] ?? [] }
        }
    }

    private func makeURL(path: String, query: [URLQueryItem]) throws -> URL {
        guard var components = URLComponents(
            url: MALConfig.baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        components.queryItems = query
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }

    /// Temporada de anime actual (invierno/primavera/verano/otoño) calculada
    /// localmente — MAL no tiene un endpoint "now" como el `seasons/now` de Jikan.
    static func currentSeasonInfo(now: Date = .now, calendar: Calendar = .current) -> (year: Int, season: String) {
        let components = calendar.dateComponents([.year, .month], from: now)
        let month = components.month ?? 1
        let season: String
        switch month {
        case 1...3: season = "winter"
        case 4...6: season = "spring"
        case 7...9: season = "summer"
        default: season = "fall"
        }
        return (components.year ?? calendar.component(.year, from: now), season)
    }
}
