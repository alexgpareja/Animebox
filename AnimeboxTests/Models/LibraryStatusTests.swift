//
//  LibraryStatusTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct LibraryStatusTests {

    init() {
        // displayName ahora depende de AppLanguage.current (Ajustes >
        // Idioma) — se fija explícitamente para que el test sea
        // determinista sin importar la preferencia persistida del entorno.
        AppLanguage.current = .spanish
    }

    @Test("LibraryStatus expone nombres legibles", arguments: [
        (LibraryStatus.watching, "Viendo"),
        (LibraryStatus.completed, "Completado"),
        (LibraryStatus.dropped, "Abandonado"),
        (LibraryStatus.planned, "Planeado"),
    ])
    func displayName(status: LibraryStatus, expected: String) {
        #expect(status.displayName == expected)
    }
}
