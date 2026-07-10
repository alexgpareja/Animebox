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

    @Test("animeGenres llama al endpoint /genres/anime")
    func animeGenresHitsExpectedEndpoint() async throws {
        let api = RecordingAPI(payload: Self.emptyDataJSON)
        let service = JikanService(api: api)

        _ = try await service.animeGenres()

        let urls = await api.receivedURLs
        try #require(urls.count == 1)
        #expect(urls[0].path.hasSuffix("/genres/anime"))
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
}
