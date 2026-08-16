//
//  JikanServiceTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@Suite(.tags(.networking))
struct JikanServiceTests {

    private static let emptyDataJSON = #"{"data": []}"#.data(using: .utf8)!

    @Test("Búsqueda con texto vacío y sin géneros no realiza llamada de red")
    func searchWithEmptyQueryAndNoGenresReturnsEmptyList() async throws {
        let service = JikanService(api: FailingAPI())
        let results = try await service.searchAnime(query: "   ", status: nil, genres: nil, limit: 10)
        #expect(results.isEmpty)
    }

    @Test("animeGenres/animeThemes devuelven listas estáticas de MAL sin llamar a la red")
    func animeGenresAndThemesDoNotHitNetwork() async throws {
        let service = JikanService(api: FailingAPI())

        let genres = try await service.animeGenres()
        let themes = try await service.animeThemes()

        #expect(!genres.isEmpty)
        #expect(!themes.isEmpty)
        #expect(Set(genres.map(\.malId)).isDisjoint(with: Set(themes.map(\.malId))))
    }

    @Test("searchAnime con géneros pone el parámetro genres en la URL")
    func searchAnimeIncludesGenresQueryParam() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchAnime(query: nil, status: nil, genres: [1, 2], limit: 10)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        let genresValue = components?.queryItems?.first(where: { $0.name == "genres" })?.value
        #expect(genresValue == "1,2")
        // Sin query → no debe haber parámetro q
        #expect(components?.queryItems?.contains(where: { $0.name == "q" }) == false)
    }

    @Test("searchAnime combina texto y género en la misma URL")
    func searchAnimeCombinesQueryAndGenres() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchAnime(query: "naruto", status: nil, genres: [1], limit: 25)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        let queryValue = components?.queryItems?.first(where: { $0.name == "q" })?.value
        let genresValue = components?.queryItems?.first(where: { $0.name == "genres" })?.value
        #expect(queryValue == "naruto")
        #expect(genresValue == "1")
    }

    @Test("searchAnime incluye status cuando se especifica")
    func searchAnimeIncludesStatusQueryParam() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchAnime(query: "demon", status: "airing", genres: nil, limit: 5)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        let statusValue = components?.queryItems?.first(where: { $0.name == "status" })?.value
        #expect(statusValue == "airing")
    }

    @Test("Búsqueda de manga con texto vacío y sin géneros no realiza llamada de red")
    func searchMangaWithEmptyQueryAndNoGenresReturnsEmptyList() async throws {
        let service = JikanService(api: FailingAPI())
        let results = try await service.searchManga(query: "   ", status: nil, genres: nil, limit: 10)
        #expect(results.isEmpty)
    }

    @Test("mangaGenres/mangaThemes devuelven listas estáticas de MAL sin llamar a la red")
    func mangaGenresAndThemesDoNotHitNetwork() async throws {
        let service = JikanService(api: FailingAPI())

        let genres = try await service.mangaGenres()
        let themes = try await service.mangaThemes()

        #expect(!genres.isEmpty)
        #expect(!themes.isEmpty)
        #expect(Set(genres.map(\.malId)).isDisjoint(with: Set(themes.map(\.malId))))
    }

    @Test("topManga llama al endpoint /top/manga")
    func topMangaHitsExpectedEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.topManga(limit: 10)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/top/manga"))
    }

    @Test("currentlyPublishingManga llama a top/manga con filter=publishing")
    func currentlyPublishingMangaHitsExpectedEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.currentlyPublishingManga(limit: 10)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/top/manga"))
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "filter" })?.value == "publishing")
    }

    @Test("mangaDetails llama al endpoint /manga/{id}/full")
    func mangaDetailsHitsExpectedEndpoint() async throws {
        let payload = #"{"data": {"mal_id": 1, "images": {"jpg": {}}, "title": "Test"}}"#.data(using: .utf8)!
        let api = RecordingAPI(payload: payload)
        let service = JikanService(api: api)

        _ = try await service.mangaDetails(id: 42)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/manga/42/full"))
    }

    @Test("searchManga combina texto y género en la misma URL")
    func searchMangaCombinesQueryAndGenres() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchManga(query: "berserk", status: nil, genres: [1], limit: 25)

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        let queryValue = components?.queryItems?.first(where: { $0.name == "q" })?.value
        let genresValue = components?.queryItems?.first(where: { $0.name == "genres" })?.value
        #expect(queryValue == "berserk")
        #expect(genresValue == "1")
    }

    @Test("searchAnime incluye type, rating y rango de fechas cuando se especifican")
    func searchAnimeIncludesAdvancedFilterParams() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchAnime(
            query: nil,
            status: nil,
            genres: nil,
            type: "movie",
            rating: "pg13",
            startDate: "2020-01-01",
            endDate: "2020-12-31",
            limit: 10
        )

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "type" })?.value == "movie")
        #expect(components?.queryItems?.first(where: { $0.name == "rating" })?.value == "pg13")
        #expect(components?.queryItems?.first(where: { $0.name == "start_date" })?.value == "2020-01-01")
        #expect(components?.queryItems?.first(where: { $0.name == "end_date" })?.value == "2020-12-31")
    }

    @Test("searchAnime ejecuta la búsqueda si solo hay un filtro avanzado, sin texto ni género")
    func searchAnimeRunsWithOnlyAdvancedFilter() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchAnime(query: nil, status: nil, genres: nil, type: "tv", limit: 10)

        let urls = await api.receivedURLs
        #expect(urls.count == 1, "un filtro de tipo por sí solo debe disparar la llamada de red")
    }

    @Test("searchManga incluye type y rango de fechas cuando se especifican")
    func searchMangaIncludesAdvancedFilterParams() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.searchManga(
            query: nil,
            status: nil,
            genres: nil,
            type: "novel",
            startDate: "1999-01-01",
            endDate: "1999-12-31",
            limit: 10
        )

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        let components = URLComponents(url: urls[0], resolvingAgainstBaseURL: false)
        #expect(components?.queryItems?.first(where: { $0.name == "type" })?.value == "novel")
        #expect(components?.queryItems?.first(where: { $0.name == "start_date" })?.value == "1999-01-01")
        #expect(components?.queryItems?.first(where: { $0.name == "end_date" })?.value == "1999-12-31")
    }
}
