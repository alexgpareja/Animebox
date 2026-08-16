//
//  MangaSearchViewModelTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite(.tags(.networking))
@MainActor
struct MangaSearchViewModelTests {

    @Test("search() expone resultados en el happy path")
    func happyPath() async throws {
        let stub = JikanServiceStub(mangaSearchResults: [
            .fixture(id: 1, title: "Berserk"),
            .fixture(id: 20, title: "Vagabond")
        ])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.query = "berserk"
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .results(let items) = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
        try #require(items.count == 2)
        #expect(items.first?.title == "Berserk")
    }

    @Test("Query vacía y sin género deja el estado en .idle")
    func emptyQueryStaysIdle() async {
        let stub = JikanServiceStub(mangaSearchResults: [.fixture(id: 1)])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.query = "   "
        sut.search()
        await sut.awaitCurrentSearch()

        #expect(sut.state == .idle)
    }

    @Test("Sin resultados, el estado se queda en .empty")
    func emptyResultsState() async {
        let stub = JikanServiceStub(mangaSearchResults: [])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.query = "asdfqwerty"
        sut.search()
        await sut.awaitCurrentSearch()

        #expect(sut.state == .empty)
    }

    @Test("Un error del servicio se propaga a .error")
    func errorPath() async {
        let stub = JikanServiceStub(error: .httpError(500))
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.query = "test"
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .error(let message) = sut.state else {
            Issue.record("Esperaba .error, obtuve \(sut.state)")
            return
        }
        #expect(message.contains("500"))
    }

    @Test("loadGenres rellena availableGenres y availableThemes en happy path")
    func loadGenresHappyPath() async {
        let stub = JikanServiceStub(
            mangaGenreResults: [
                NamedEntity(malId: 1, type: "manga", name: "Action", url: nil)
            ],
            mangaThemeResults: [
                NamedEntity(malId: 68, type: "manga", name: "Memoir", url: nil)
            ]
        )
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        await sut.loadGenres()

        #expect(sut.availableGenres.count == 1)
        #expect(sut.availableThemes.map(\.name) == ["Memoir"])
        #expect(sut.isLoadingGenres == false)
    }

    @Test("toggleGenre selecciona y al volver a pulsar deselecciona")
    func toggleGenreOnOff() async {
        let stub = JikanServiceStub(mangaSearchResults: [])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(5)
        #expect(sut.selectedGenreIDs == [5])

        sut.toggleGenre(5)
        #expect(sut.selectedGenreIDs.isEmpty)
    }

    @Test("toggleGenre con varios ids acumula la selección (filtro AND)")
    func toggleGenreAccumulatesMultipleSelections() async {
        let stub = JikanServiceStub(mangaSearchResults: [])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(1)
        sut.toggleGenre(2)
        #expect(sut.selectedGenreIDs == [1, 2])
    }

    @Test("Cambiar solo el filtro de tipo (sin query ni género) ejecuta el servicio")
    func searchByTypeFilterOnly() async {
        let stub = JikanServiceStub(mangaSearchResults: [.fixture(id: 1, title: "Una novela")])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.typeFilter = .novel
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .results(let items) = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
        #expect(items.count == 1)
    }

    @Test("Cambiar solo el filtro de año (sin query ni género) ejecuta el servicio")
    func searchByYearFilterOnly() async {
        let stub = JikanServiceStub(mangaSearchResults: [.fixture(id: 1)])
        let sut = MangaSearchViewModel(service: stub, debounce: .zero)

        sut.yearFrom = 1999
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .results = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
    }
}
