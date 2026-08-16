//
//  JikanService.swift
//  Animebox
//

import Foundation

protocol ContentServicing: Sendable {
    func topAnime(limit: Int) async throws -> [Anime]
    func currentSeason(limit: Int) async throws -> [Anime]
    func searchAnime(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        rating: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Anime]
    func animeDetails(id: Int) async throws -> Anime
    func animeGenres() async throws -> [NamedEntity]
    func animeThemes() async throws -> [NamedEntity]

    func topManga(limit: Int) async throws -> [Manga]
    func currentlyPublishingManga(limit: Int) async throws -> [Manga]
    func searchManga(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Manga]
    func mangaDetails(id: Int) async throws -> Manga
    func mangaGenres() async throws -> [NamedEntity]
    func mangaThemes() async throws -> [NamedEntity]
}

nonisolated struct JikanService: ContentServicing {
    let api: APIServicing
    let baseURL: URL

    init(api: APIServicing = APIService(), baseURL: URL = APIConfig.jikanBaseURL) {
        self.api = api
        self.baseURL = baseURL
    }

    func topAnime(limit: Int = 25) async throws -> [Anime] {
        let url = try makeURL(path: "top/anime", query: [
            URLQueryItem(name: "limit", value: String(limit))
        ])
        let response: JikanListResponse<Anime> = try await api.get(url, as: JikanListResponse<Anime>.self)
        return response.data
    }

    func currentSeason(limit: Int = 25) async throws -> [Anime] {
        let url = try makeURL(path: "seasons/now", query: [
            URLQueryItem(name: "limit", value: String(limit))
        ])
        let response: JikanListResponse<Anime> = try await api.get(url, as: JikanListResponse<Anime>.self)
        return response.data
    }

    func searchAnime(
        query: String?,
        status: String? = nil,
        genres: [Int]? = nil,
        type: String? = nil,
        rating: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        limit: Int = 25
    ) async throws -> [Anime] {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !(trimmedQuery?.isEmpty ?? true)
        let hasGenres = !(genres?.isEmpty ?? true)
        let hasOtherFilters = type != nil || rating != nil || startDate != nil
        guard hasQuery || hasGenres || hasOtherFilters else { return [] }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sfw", value: "true")
        ]
        if let trimmedQuery, !trimmedQuery.isEmpty {
            items.append(URLQueryItem(name: "q", value: trimmedQuery))
        }
        if let status {
            items.append(URLQueryItem(name: "status", value: status))
        }
        if let genres, !genres.isEmpty {
            items.append(URLQueryItem(name: "genres", value: genres.map(String.init).joined(separator: ",")))
        }
        if let type {
            items.append(URLQueryItem(name: "type", value: type))
        }
        if let rating {
            items.append(URLQueryItem(name: "rating", value: rating))
        }
        if let startDate {
            items.append(URLQueryItem(name: "start_date", value: startDate))
        }
        if let endDate {
            items.append(URLQueryItem(name: "end_date", value: endDate))
        }
        let url = try makeURL(path: "anime", query: items)
        let response: JikanListResponse<Anime> = try await api.get(url, as: JikanListResponse<Anime>.self)
        return response.data
    }

    func animeDetails(id: Int) async throws -> Anime {
        let url = try makeURL(path: "anime/\(id)/full")
        let response: JikanSingleResponse<Anime> = try await api.get(url, as: JikanSingleResponse<Anime>.self)
        return response.data
    }

    func animeGenres() async throws -> [NamedEntity] {
        MALGenres.animeGenres
    }

    func animeThemes() async throws -> [NamedEntity] {
        MALGenres.animeThemes
    }

    func topManga(limit: Int = 25) async throws -> [Manga] {
        let url = try makeURL(path: "top/manga", query: [
            URLQueryItem(name: "limit", value: String(limit))
        ])
        let response: JikanListResponse<Manga> = try await api.get(url, as: JikanListResponse<Manga>.self)
        return response.data
    }

    /// Equivalente manga de `currentSeason(limit:)` — no hay "temporadas" en
    /// manga, así que el filtro `publishing` del propio `top/manga` es lo más
    /// parecido a "en emisión" que ofrece Jikan.
    func currentlyPublishingManga(limit: Int = 25) async throws -> [Manga] {
        let url = try makeURL(path: "top/manga", query: [
            URLQueryItem(name: "filter", value: "publishing"),
            URLQueryItem(name: "limit", value: String(limit))
        ])
        let response: JikanListResponse<Manga> = try await api.get(url, as: JikanListResponse<Manga>.self)
        return response.data
    }

    func searchManga(
        query: String?,
        status: String? = nil,
        genres: [Int]? = nil,
        type: String? = nil,
        startDate: String? = nil,
        endDate: String? = nil,
        limit: Int = 25
    ) async throws -> [Manga] {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !(trimmedQuery?.isEmpty ?? true)
        let hasGenres = !(genres?.isEmpty ?? true)
        let hasOtherFilters = type != nil || startDate != nil
        guard hasQuery || hasGenres || hasOtherFilters else { return [] }

        var items: [URLQueryItem] = [
            URLQueryItem(name: "limit", value: String(limit)),
            URLQueryItem(name: "sfw", value: "true")
        ]
        if let trimmedQuery, !trimmedQuery.isEmpty {
            items.append(URLQueryItem(name: "q", value: trimmedQuery))
        }
        if let status {
            items.append(URLQueryItem(name: "status", value: status))
        }
        if let genres, !genres.isEmpty {
            items.append(URLQueryItem(name: "genres", value: genres.map(String.init).joined(separator: ",")))
        }
        if let type {
            items.append(URLQueryItem(name: "type", value: type))
        }
        if let startDate {
            items.append(URLQueryItem(name: "start_date", value: startDate))
        }
        if let endDate {
            items.append(URLQueryItem(name: "end_date", value: endDate))
        }
        let url = try makeURL(path: "manga", query: items)
        let response: JikanListResponse<Manga> = try await api.get(url, as: JikanListResponse<Manga>.self)
        return response.data
    }

    func mangaDetails(id: Int) async throws -> Manga {
        let url = try makeURL(path: "manga/\(id)/full")
        let response: JikanSingleResponse<Manga> = try await api.get(url, as: JikanSingleResponse<Manga>.self)
        return response.data
    }

    func mangaGenres() async throws -> [NamedEntity] {
        MALGenres.mangaGenres
    }

    func mangaThemes() async throws -> [NamedEntity] {
        MALGenres.mangaThemes
    }

    private func makeURL(path: String, query: [URLQueryItem] = []) throws -> URL {
        guard var components = URLComponents(
            url: baseURL.appendingPathComponent(path),
            resolvingAgainstBaseURL: false
        ) else {
            throw NetworkError.invalidURL
        }
        if !query.isEmpty {
            components.queryItems = query
        }
        guard let url = components.url else { throw NetworkError.invalidURL }
        return url
    }
}
