//
//  GenreLocalizationTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct GenreLocalizationTests {

    init() {
        // localizedName ahora depende de AppLanguage.current (Ajustes >
        // Idioma) — se fija explícitamente para que el test sea
        // determinista sin importar la preferencia persistida del entorno.
        AppLanguage.current = .spanish
    }

    @Test("Traduce nombres conocidos al español", arguments: [
        ("Action", "Acción"),
        ("Slice of Life", "Recuentos de la Vida"),
        ("Sci-Fi", "Ciencia Ficción"),
    ])
    func translatesKnownNames(raw: String, expected: String) {
        #expect(GenreLocalization.localizedName(for: raw) == expected)
    }

    @Test("Un nombre no reconocido cae de vuelta al texto crudo, no crashea")
    func unknownNameFallsBackToRaw() {
        #expect(GenreLocalization.localizedName(for: "Some Future Genre") == "Some Future Genre")
    }

    @Test("Todos los nombres de MALGenres están en la tabla de localización")
    func allMALGenresAreTranslated() {
        let allNames = Set(
            (MALGenres.animeGenres + MALGenres.animeThemes + MALGenres.mangaGenres + MALGenres.mangaThemes)
                .map(\.name)
        )
        for name in allNames {
            #expect(GenreLocalization.isKnown(name), "Falta entrada en la tabla para \"\(name)\"")
        }
    }
}
