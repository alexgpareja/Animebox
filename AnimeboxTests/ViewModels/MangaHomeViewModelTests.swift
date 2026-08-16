//
//  MangaHomeViewModelTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite(.tags(.networking))
@MainActor
struct MangaHomeViewModelTests {

    @Test("load() rellena topManga y currentlyPublishing en happy path")
    func happyPath() async throws {
        let stub = JikanServiceStub(
            topMangaResults: [.fixture(id: 1, title: "Top Manga")],
            currentlyPublishingResults: [.fixture(id: 2, title: "En Publicación")]
        )
        let sut = MangaHomeViewModel(service: stub)

        await sut.load()

        try #require(sut.topManga.count == 1)
        try #require(sut.currentlyPublishing.count == 1)
        #expect(sut.topManga.first?.malId == 1)
        #expect(sut.currentlyPublishing.first?.malId == 2)
        #expect(sut.state == .loaded)
    }

    @Test("load() expone el mensaje cuando el servicio falla")
    func errorPath() async throws {
        let stub = JikanServiceStub(error: .httpError(503))
        let sut = MangaHomeViewModel(service: stub)

        await sut.load()

        #expect(sut.topManga.isEmpty)
        guard case .error(let message) = sut.state else {
            Issue.record("Esperaba estado .error, obtuve \(sut.state)")
            return
        }
        #expect(message.contains("503"))
    }

    @Test("NetworkError.cancelled no transiciona a .error")
    func cancellationIsIgnored() async {
        let stub = JikanServiceStub(error: .cancelled)
        let sut = MangaHomeViewModel(service: stub)

        await sut.load()

        if case .error = sut.state {
            Issue.record("Una cancelación no debe pintar la ErrorView")
        }
        #expect(sut.topManga.isEmpty)
    }
}
