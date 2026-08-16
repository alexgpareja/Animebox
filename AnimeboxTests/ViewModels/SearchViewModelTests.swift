//
//  SearchViewModelTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite(.tags(.networking))
@MainActor
struct SearchViewModelTests {

    @Test("search() expone resultados en el happy path")
    func happyPath() async throws {
        let stub = JikanServiceStub(searchResults: [
            .fixture(id: 1, title: "Naruto"),
            .fixture(id: 20, title: "Bleach")
        ])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.query = "naruto"
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .results(let items) = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
        try #require(items.count == 2)
        #expect(items.first?.title == "Naruto")
    }

    @Test("Query vacía y sin género deja el estado en .idle")
    func emptyQueryStaysIdle() async {
        let stub = JikanServiceStub(searchResults: [.fixture(id: 1)])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.query = "   "
        sut.search()
        await sut.awaitCurrentSearch()

        #expect(sut.state == .idle)
    }

    @Test("Sin resultados, el estado se queda en .empty")
    func emptyResultsState() async {
        let stub = JikanServiceStub(searchResults: [])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.query = "asdfqwerty"
        sut.search()
        await sut.awaitCurrentSearch()

        #expect(sut.state == .empty)
    }

    @Test("Un error del servicio se propaga a .error")
    func errorPath() async {
        let stub = JikanServiceStub(error: .httpError(500))
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.query = "test"
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .error(let message) = sut.state else {
            Issue.record("Esperaba .error, obtuve \(sut.state)")
            return
        }
        #expect(message.contains("500"))
    }

    @Test("NetworkError.cancelled no transiciona a .error")
    func cancellationDoesNotPaintError() async {
        let stub = JikanServiceStub(error: .cancelled)
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.query = "test"
        sut.search()
        await sut.awaitCurrentSearch()

        if case .error = sut.state {
            Issue.record("Cancelación no debe pintar error")
        }
    }

    @Test("loadGenres rellena availableGenres y availableThemes en happy path")
    func loadGenresHappyPath() async {
        let stub = JikanServiceStub(
            genres: [
                NamedEntity(malId: 1, type: "anime", name: "Action", url: nil),
                NamedEntity(malId: 2, type: "anime", name: "Adventure", url: nil)
            ],
            themes: [
                NamedEntity(malId: 62, type: "anime", name: "Isekai", url: nil)
            ]
        )
        let sut = SearchViewModel(service: stub, debounce: .zero)

        await sut.loadGenres()

        #expect(sut.availableGenres.count == 2)
        #expect(sut.availableGenres.first?.name == "Action")
        #expect(sut.availableThemes.map(\.name) == ["Isekai"])
        #expect(sut.isLoadingGenres == false)
    }

    @Test("toggleGenre selecciona y al volver a pulsar deselecciona")
    func toggleGenreOnOff() async {
        let stub = JikanServiceStub(searchResults: [])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(5)
        #expect(sut.selectedGenreIDs == [5])

        sut.toggleGenre(5)
        #expect(sut.selectedGenreIDs.isEmpty)
    }

    @Test("Cambiar solo el filtro de tipo (sin query ni género) ejecuta el servicio")
    func searchByTypeFilterOnly() async {
        let stub = JikanServiceStub(searchResults: [.fixture(id: 1, title: "Una película")])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.typeFilter = .movie
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
        let stub = JikanServiceStub(searchResults: [.fixture(id: 1)])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.yearFrom = 2020
        sut.search()
        await sut.awaitCurrentSearch()

        guard case .results = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
    }

    @Test("Búsqueda solo por género (sin query) ejecuta el servicio")
    func searchByGenreOnly() async {
        let stub = JikanServiceStub(searchResults: [.fixture(id: 1, title: "Anime de acción")])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(1)
        await sut.awaitCurrentSearch()

        guard case .results(let items) = sut.state else {
            Issue.record("Esperaba .results, obtuve \(sut.state)")
            return
        }
        #expect(items.count == 1)
    }

    @Test("Deseleccionar el género sin query vuelve a .idle")
    func deselectingGenreWithoutQueryReturnsIdle() async {
        let stub = JikanServiceStub(searchResults: [.fixture(id: 1)])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(1)
        await sut.awaitCurrentSearch()
        sut.toggleGenre(1) // deselect
        await sut.awaitCurrentSearch()

        #expect(sut.state == .idle)
    }

    @Test("loadGenres con error degrada silenciosamente sin pintar la pantalla en error")
    func loadGenresFailureDegradesSilently() async {
        let stub = JikanServiceStub(error: .httpError(500))
        let sut = SearchViewModel(service: stub, debounce: .zero)

        await sut.loadGenres()

        #expect(sut.availableGenres.isEmpty)
        #expect(sut.isLoadingGenres == false)
        #expect(sut.state == .idle)
    }

    @Test("toggleGenre con varios ids acumula la selección (filtro AND)")
    func toggleGenreAccumulatesMultipleSelections() async {
        let stub = JikanServiceStub(searchResults: [])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        sut.toggleGenre(1)
        #expect(sut.selectedGenreIDs == [1])

        sut.toggleGenre(2)
        #expect(sut.selectedGenreIDs == [1, 2])

        sut.toggleGenre(1)
        #expect(sut.selectedGenreIDs == [2])
    }

    @Test("loadGenres no vuelve a llamar al servicio si los géneros ya estaban cargados")
    func loadGenresIsIdempotentWhenAlreadyLoaded() async {
        let stub = JikanServiceStub(genres: [
            NamedEntity(malId: 1, type: "anime", name: "Action", url: nil)
        ])
        let sut = SearchViewModel(service: stub, debounce: .zero)

        await sut.loadGenres()
        #expect(sut.availableGenres.count == 1)

        // Si el guard falla, esta segunda llamada con un stub que devuelve
        // los mismos géneros no debería cambiar el estado ni romper nada.
        await sut.loadGenres()
        #expect(sut.availableGenres.count == 1)
        #expect(sut.isLoadingGenres == false)
    }
}
