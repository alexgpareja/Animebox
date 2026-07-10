//
//  AnimeDedupeTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct AnimeDedupeTests {

    @Test("Elimina entradas con malId repetido conservando la primera")
    func keepsFirstOccurrence() {
        let one = Anime.fixture(id: 1, title: "Original")
        let two = Anime.fixture(id: 2, title: "Otro")
        let oneAgain = Anime.fixture(id: 1, title: "Duplicado")

        let result = [one, two, oneAgain].dedupedByMalId()

        #expect(result.count == 2)
        #expect(result[0].malId == 1)
        #expect(result[0].title == "Original")
        #expect(result[1].malId == 2)
    }

    @Test("Una colección sin duplicados no cambia de orden ni de tamaño")
    func passesThroughWhenNoDuplicates() {
        let items: [Anime] = [
            .fixture(id: 10),
            .fixture(id: 20),
            .fixture(id: 30)
        ]

        let result = items.dedupedByMalId()

        #expect(result.count == 3)
        #expect(result.map(\.malId) == [10, 20, 30])
    }

    @Test("Una colección vacía sigue vacía")
    func emptyStaysEmpty() {
        let empty: [Anime] = []
        #expect(empty.dedupedByMalId().isEmpty)
    }
}
