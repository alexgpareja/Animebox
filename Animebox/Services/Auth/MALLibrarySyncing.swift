//
//  MALLibrarySyncing.swift
//  Animebox
//

import Foundation

nonisolated struct MALPulledAnimeEntry: Sendable {
    let anime: Anime
    let status: LibraryStatus
    let progress: Int
    let score: Int?
    let startDate: Date?
    let finishDate: Date?
}

nonisolated struct MALPulledMangaEntry: Sendable {
    let manga: Manga
    let status: MangaStatus
    let chaptersRead: Int
    let volumesRead: Int
    let score: Int?
    let startDate: Date?
    let finishDate: Date?
}

/// Escrituras/lecturas de la lista real del usuario en MAL — separado de
/// `ContentServicing` porque no tiene equivalente en Jikan (son endpoints de
/// cuenta, no de contenido público).
protocol MALLibrarySyncing: Sendable {
    func pushAnimeStatus(malId: Int, status: LibraryStatus, progress: Int, score: Int?) async throws
    func pushMangaStatus(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) async throws
    func deleteAnimeStatus(malId: Int) async throws
    func deleteMangaStatus(malId: Int) async throws
    func pullAnimeList() async throws -> [MALPulledAnimeEntry]
    func pullMangaList() async throws -> [MALPulledMangaEntry]
}

struct MALLibrarySyncService: MALLibrarySyncing {
    let api: MALAPIService

    init(malSession: MALSession) {
        self.api = MALAPIService(malSession: malSession)
    }

    func pushAnimeStatus(malId: Int, status: LibraryStatus, progress: Int, score: Int?) async throws {
        var body = ["status": status.malStatusValue, "num_watched_episodes": String(progress)]
        if let score { body["score"] = String(score) }
        try await api.send(url: makeURL("anime/\(malId)/my_list_status"), method: "PATCH", formBody: body)
    }

    func pushMangaStatus(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) async throws {
        var body = [
            "status": status.malStatusValue,
            "num_chapters_read": String(chaptersRead),
            "num_volumes_read": String(volumesRead)
        ]
        if let score { body["score"] = String(score) }
        try await api.send(url: makeURL("manga/\(malId)/my_list_status"), method: "PATCH", formBody: body)
    }

    func deleteAnimeStatus(malId: Int) async throws {
        try await api.send(url: makeURL("anime/\(malId)/my_list_status"), method: "DELETE")
    }

    func deleteMangaStatus(malId: Int) async throws {
        try await api.send(url: makeURL("manga/\(malId)/my_list_status"), method: "DELETE")
    }

    func pullAnimeList() async throws -> [MALPulledAnimeEntry] {
        var results: [MALPulledAnimeEntry] = []
        var url: URL? = makeURL(
            "users/@me/animelist",
            query: [
                URLQueryItem(name: "fields", value: "list_status,\(MALContentService.animeFields)"),
                URLQueryItem(name: "limit", value: "100")
            ]
        )
        while let currentURL = url {
            let response: MALListResponse<MALAnimeNode> = try await api.get(currentURL, as: MALListResponse<MALAnimeNode>.self)
            results.append(contentsOf: response.data.compactMap { item in
                guard let listStatus = item.listStatus, let status = LibraryStatus(malStatusValue: listStatus.status ?? "") else {
                    return nil
                }
                return MALPulledAnimeEntry(
                    anime: Anime(malNode: item.node),
                    status: status,
                    progress: listStatus.numEpisodesWatched ?? 0,
                    score: (listStatus.score ?? 0) > 0 ? listStatus.score : nil,
                    startDate: parseDate(listStatus.startDate),
                    finishDate: parseDate(listStatus.finishDate)
                )
            })
            url = response.paging?.next.flatMap(URL.init(string:))
        }
        return results
    }

    func pullMangaList() async throws -> [MALPulledMangaEntry] {
        var results: [MALPulledMangaEntry] = []
        var url: URL? = makeURL(
            "users/@me/mangalist",
            query: [
                URLQueryItem(name: "fields", value: "list_status,\(MALContentService.mangaFields)"),
                URLQueryItem(name: "limit", value: "100")
            ]
        )
        while let currentURL = url {
            let response: MALListResponse<MALMangaNode> = try await api.get(currentURL, as: MALListResponse<MALMangaNode>.self)
            results.append(contentsOf: response.data.compactMap { item in
                guard let listStatus = item.listStatus, let status = MangaStatus(malStatusValue: listStatus.status ?? "") else {
                    return nil
                }
                return MALPulledMangaEntry(
                    manga: Manga(malNode: item.node),
                    status: status,
                    chaptersRead: listStatus.numChaptersRead ?? 0,
                    volumesRead: listStatus.numVolumesRead ?? 0,
                    score: (listStatus.score ?? 0) > 0 ? listStatus.score : nil,
                    startDate: parseDate(listStatus.startDate),
                    finishDate: parseDate(listStatus.finishDate)
                )
            })
            url = response.paging?.next.flatMap(URL.init(string:))
        }
        return results
    }

    private func parseDate(_ raw: String?) -> Date? {
        guard let raw else { return nil }
        return try? Date(raw, strategy: .iso8601.year().month().day())
    }

    private func makeURL(_ path: String, query: [URLQueryItem] = []) -> URL {
        var components = URLComponents(url: MALConfig.baseURL.appendingPathComponent(path), resolvingAgainstBaseURL: false)!
        if !query.isEmpty { components.queryItems = query }
        return components.url!
    }
}
