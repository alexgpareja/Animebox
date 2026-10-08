//
//  AppLanguageTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct AppLanguageTests {

    @Test("current persiste y se lee de vuelta correctamente")
    func currentRoundTrips() {
        AppLanguage.current = .english
        #expect(AppLanguage.current == .english)
        AppLanguage.current = .spanish
        #expect(AppLanguage.current == .spanish)
    }

    /// Regresión: `String(localized:locale:)` con un `locale:` explícito no
    /// forzaba de forma fiable una tabla distinta a la que el bundle ya
    /// consideraba "preferida" — el override se ignoraba en silencio y
    /// siempre devolvía el string base/español. `AppLanguage.string(_:)`
    /// carga el `.lproj` correspondiente directamente para evitar eso.
    @Test("string(_:) resuelve la traducción real del catálogo compilado, no el string base")
    func stringResolvesRealTranslation() {
        #expect(AppLanguage.english.string("Viendo") == "Watching")
        #expect(AppLanguage.english.string("Completado") == "Completed")
    }

    @Test("string(_:) en español cae de vuelta a la clave (no hay es.lproj, es el idioma base)")
    func stringInSpanishReturnsKeyUnchanged() {
        #expect(AppLanguage.spanish.string("Viendo") == "Viendo")
    }

    @Test("Una clave sin traducción cae de vuelta a sí misma, no crashea")
    func unknownKeyFallsBackToItself() {
        #expect(AppLanguage.english.string("Clave que no existe en el catálogo") == "Clave que no existe en el catálogo")
    }
}
