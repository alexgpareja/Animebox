//
//  JikanService.swift
//  Animebox
//

import Foundation

protocol JikanServicing: Sendable {
    func topAnime(limit: Int) async throws -> [Anime]
    func currentSeason(limit: Int) async throws -> [Anime]
    func searchAnime(query: String?, status: String?, genres: [Int]?, limit: Int) async throws -> [Anime]
    func animeDetails(id: Int) async throws -> Anime
    func animeGenres() async throws -> [NamedEntity]
}

nonisolated struct JikanService: JikanServicing {
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
        limit: Int = 25
    ) async throws -> [Anime] {
        let trimmedQuery = query?.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !(trimmedQuery?.isEmpty ?? true)
        let hasGenres = !(genres?.isEmpty ?? true)
        guard hasQuery || hasGenres else { return [] }

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
        let url = try makeURL(path: "genres/anime")
        let response: JikanListResponse<NamedEntity> = try await api.get(url, as: JikanListResponse<NamedEntity>.self)
        return response.data
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
