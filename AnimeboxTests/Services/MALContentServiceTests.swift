//
//  MALContentServiceTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

/// Devuelve un payload distinto según el `offset` de la URL pedida — para
/// probar que la paginación realmente agrega resultados de varias páginas,
/// no solo repite la primera. Páginas sin entrada explícita devuelven `[]`.
private actor OffsetAwareAPI: APIServicing {
    private(set) var receivedURLs: [URL] = []
    let pages: [Int: String]

    init(pages: [Int: String]) {
        self.pages = pages
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        receivedURLs.append(url)
        let offset = URLComponents(url: url, resolvingAgainstBaseURL: false)?
            .queryItems?.first(where: { $0.name == "offset" })?.value
            .flatMap(Int.init) ?? 0
        let json = pages[offset] ?? #"{"data": []}"#
        return try JSONDecoder().decode(T.self, from: json.data(using: .utf8)!)
    }
}

@Suite(.tags(.networking))
struct MALContentServiceTests {
    private static let emptyListJSON = #"{"data": []}"#.data(using: .utf8)!

    @Test("topAnime llama a anime/ranking con ranking_type=all")
    func topAnimeHitsRankingEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        _ = try await service.topAnime(limit: 10)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/anime/ranking"))
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "ranking_type" })?.value == "all")
        #expect(components?.queryItems?.first(where: { $0.name == "limit" })?.value == "10")
        #expect(components?.queryItems?.contains(where: { $0.name == "fields" }) == true)
    }

    @Test("currentSeason llama a anime/season/{año}/{temporada} calculado localmente")
    func currentSeasonHitsSeasonEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        _ = try await service.currentSeason(limit: 10)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let (year, season) = MALContentService.currentSeasonInfo()
        #expect(urls[0].path.hasSuffix("/anime/season/\(year)/\(season)"))
    }

    @Test("animeDetails llama a anime/{id}")
    func animeDetailsHitsExpectedEndpoint() async throws {
        let payload = #"{"id": 1, "title": "Test"}"#.data(using: .utf8)!
        let api = RecordingAPI(payload: payload)
        let service = MALContentService(api: api)

        let anime = try await service.animeDetails(id: 1)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/anime/1"))
        #expect(anime.malId == 1)
    }

    @Test("searchAnime con texto llama a anime con q=")
    func searchAnimeWithQueryHitsSearchEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        _ = try await service.searchAnime(
            query: "naruto", status: nil, genres: nil, type: nil, rating: nil, startDate: nil, endDate: nil, limit: 10
        )

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/anime"))
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "q" })?.value == "naruto")
    }

    @Test("searchAnime sin texto pero con géneros pagina el ranking en paralelo (q es obligatorio en /v2/anime)")
    func searchAnimeWithoutQueryFallsBackToRanking() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        _ = try await service.searchAnime(
            query: nil, status: nil, genres: [1], type: nil, rating: nil, startDate: nil, endDate: nil, limit: 10
        )

        let urls = await api.receivedURLs
        try #require(urls.count == 5)
        #expect(urls.allSatisfy { $0.path.hasSuffix("/anime/ranking") })
        let offsets = Set(urls.compactMap {
            URLComponents(url: $0, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "offset" })?.value
        })
        #expect(offsets == ["0", "100", "200", "300", "400"])
    }

    @Test("searchAnime sin texto ni filtros no llama a la red")
    func searchAnimeWithNothingReturnsEmptyWithoutNetworkCall() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        let results = try await service.searchAnime(
            query: nil, status: nil, genres: nil, type: nil, rating: nil, startDate: nil, endDate: nil, limit: 10
        )

        #expect(results.isEmpty)
        let urls = await api.receivedURLs
        #expect(urls.isEmpty)
    }

    @Test("searchAnime filtra en cliente por género, quedándose solo con coincidencias")
    func searchAnimeFiltersByGenreClientSide() async throws {
        let json = """
        {"data": [
            {"node": {"id": 1, "title": "Con género 1", "genres": [{"id": 1, "name": "Action"}]}},
            {"node": {"id": 2, "title": "Sin género 1", "genres": [{"id": 2, "name": "Adventure"}]}}
        ]}
        """.data(using: .utf8)!
        let api = RecordingAPI(payload: json)
        let service = MALContentService(api: api)

        let results = try await service.searchAnime(
            query: "algo", status: nil, genres: [1], type: nil, rating: nil, startDate: nil, endDate: nil, limit: 10
        )

        #expect(results.map(\.malId) == [1])
    }

    @Test("currentlyPublishingManga pagina manga/ranking en paralelo y filtra en cliente por status")
    func currentlyPublishingMangaFiltersByStatusClientSide() async throws {
        let json = """
        {"data": [
            {"node": {"id": 1, "title": "En publicación", "status": "currently_publishing"}},
            {"node": {"id": 2, "title": "Terminado", "status": "finished"}}
        ]}
        """.data(using: .utf8)!
        let api = RecordingAPI(payload: json)
        let service = MALContentService(api: api)

        let results = try await service.currentlyPublishingManga(limit: 3)

        let urls = await api.receivedURLs
        try #require(urls.count == 5)
        #expect(urls.allSatisfy { $0.path.hasSuffix("/manga/ranking") })
        // Cada una de las 5 páginas (idénticas, mismo payload canned) aporta
        // un match — con limit: 3 solo deben sobrevivir 3 tras el prefix.
        #expect(results.count == 3)
        #expect(results.allSatisfy { $0.malId == 1 })
    }

    @Test("searchAnime sin texto encuentra coincidencias que solo existen en páginas posteriores del ranking")
    func searchAnimeWithoutQueryFindsMatchesBeyondFirstPage() async throws {
        // La primera página del ranking (offset 0) no tiene ningún resultado
        // con el género 14 (Horror) — solo aparece en la página con offset 400.
        // Antes de paginar, esto habría devuelto 0 resultados silenciosamente.
        let api = OffsetAwareAPI(pages: [
            0: #"{"data": [{"node": {"id": 1, "title": "Top 1", "genres": [{"id": 1, "name": "Action"}]}}]}"#,
            400: #"{"data": [{"node": {"id": 99, "title": "Horror de nicho", "genres": [{"id": 14, "name": "Horror"}]}}]}"#
        ])
        let service = MALContentService(api: api)

        let results = try await service.searchAnime(
            query: nil, status: nil, genres: [14], type: nil, rating: nil, startDate: nil, endDate: nil, limit: 10
        )

        #expect(results.map(\.malId) == [99])
    }

    @Test("animeGenres/animeThemes/mangaGenres/mangaThemes no hacen ninguna llamada de red — listas estáticas")
    func genresAndThemesDoNotHitNetwork() async throws {
        let api = RecordingAPI(payload: Self.emptyListJSON)
        let service = MALContentService(api: api)

        let animeGenres = try await service.animeGenres()
        let animeThemes = try await service.animeThemes()
        let mangaGenres = try await service.mangaGenres()
        let mangaThemes = try await service.mangaThemes()

        #expect(!animeGenres.isEmpty)
        #expect(!animeThemes.isEmpty)
        #expect(!mangaGenres.isEmpty)
        #expect(!mangaThemes.isEmpty)
        let urls = await api.receivedURLs
        #expect(urls.isEmpty)
    }
}
