//
//  AnimeAiringStatusTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct AnimeAiringStatusTests {

    init() {
        // displayName ahora depende de AppLanguage.current (Ajustes >
        // Idioma) — se fija explícitamente para que el test sea
        // determinista sin importar la preferencia persistida del entorno.
        AppLanguage.current = .spanish
    }

    @Test("Reconoce los tres vocabularios (Jikan Title Case, MAL snake_case y AniList SCREAMING_SNAKE_CASE)", arguments: [
        ("Currently Airing", AnimeAiringStatus.airing),
        ("currently_airing", AnimeAiringStatus.airing),
        ("RELEASING", AnimeAiringStatus.airing),
        ("Finished Airing", AnimeAiringStatus.finished),
        ("finished_airing", AnimeAiringStatus.finished),
        ("FINISHED", AnimeAiringStatus.finished),
        ("Not yet aired", AnimeAiringStatus.notYetAired),
        ("not_yet_aired", AnimeAiringStatus.notYetAired),
        ("NOT_YET_RELEASED", AnimeAiringStatus.notYetAired),
        ("CANCELLED", AnimeAiringStatus.cancelled),
        ("HIATUS", AnimeAiringStatus.onHiatus),
    ])
    func recognizesBothVocabularies(apiValue: String, expected: AnimeAiringStatus) {
        #expect(AnimeAiringStatus(apiValue: apiValue) == expected)
    }

    @Test("Un valor no reconocido devuelve nil, no crashea")
    func unknownValueReturnsNil() {
        #expect(AnimeAiringStatus(apiValue: "algo_inventado") == nil)
    }

    @Test("displayName está en español", arguments: [
        (AnimeAiringStatus.airing, "Emitiéndose"),
        (AnimeAiringStatus.finished, "Finalizado"),
        (AnimeAiringStatus.notYetAired, "Aún no emitido"),
        (AnimeAiringStatus.cancelled, "Cancelado"),
        (AnimeAiringStatus.onHiatus, "En pausa"),
    ])
    func displayName(status: AnimeAiringStatus, expected: String) {
        #expect(status.displayName == expected)
    }
}
