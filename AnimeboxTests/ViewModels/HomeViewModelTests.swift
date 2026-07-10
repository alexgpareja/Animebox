//
//  HomeViewModelTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite(.tags(.networking))
@MainActor
struct HomeViewModelTests {

    @Test("load() rellena top y current season en happy path")
    func happyPath() async throws {
        let stub = JikanServiceStub(
            top: [.fixture(id: 1, title: "Top Anime")],
            season: [.fixture(id: 2, title: "Season Anime")]
        )
        let sut = HomeViewModel(service: stub)

        await sut.load()

        try #require(sut.topAnime.count == 1)
        try #require(sut.currentSeason.count == 1)
        #expect(sut.topAnime.first?.malId == 1)
        #expect(sut.currentSeason.first?.malId == 2)
        #expect(sut.state == .loaded)
    }

    @Test("load() expone el mensaje cuando el servicio falla")
    func errorPath() async throws {
        let stub = JikanServiceStub(error: .httpError(503))
        let sut = HomeViewModel(service: stub)

        await sut.load()

        #expect(sut.topAnime.isEmpty)
        guard case .error(let message) = sut.state else {
            Issue.record("Esperaba estado .error, obtuve \(sut.state)")
            return
        }
        #expect(message.contains("503"))
    }

    @Test("NetworkError.cancelled no transiciona a .error")
    func cancellationIsIgnored() async {
        let stub = JikanServiceStub(error: .cancelled)
        let sut = HomeViewModel(service: stub)

        await sut.load()

        if case .error = sut.state {
            Issue.record("Una cancelación no debe pintar la ErrorView")
        }
        #expect(sut.topAnime.isEmpty)
    }
}
