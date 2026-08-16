//
//  MangaDetailViewModelTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite(.tags(.networking))
@MainActor
struct MangaDetailViewModelTests {

    @Test("refreshDetails enriquece el manga y transiciona a .refreshed")
    func happyPath() async {
        let full = Manga.fixture(id: 1, title: "Full details")
        let stub = JikanServiceStub(mangaDetailsResult: full)
        let sut = MangaDetailViewModel(
            initialManga: .fixture(id: 1, title: "Initial"),
            service: stub
        )

        await sut.refreshDetails()

        #expect(sut.manga.title == "Full details")
        #expect(sut.state == .refreshed)
    }

    @Test("refreshDetails propaga el error del servicio a .error")
    func errorPath() async {
        let stub = JikanServiceStub(error: .httpError(500))
        let sut = MangaDetailViewModel(initialManga: .fixture(id: 1), service: stub)

        await sut.refreshDetails()

        guard case .error(let message) = sut.state else {
            Issue.record("Esperaba .error, obtuve \(sut.state)")
            return
        }
        #expect(message.contains("500"))
    }

    @Test("NetworkError.cancelled deja el estado en .idle, no pinta error")
    func cancellationStaysIdle() async {
        let stub = JikanServiceStub(error: .cancelled)
        let sut = MangaDetailViewModel(initialManga: .fixture(id: 1), service: stub)

        await sut.refreshDetails()

        #expect(sut.state == .idle)
    }
}
