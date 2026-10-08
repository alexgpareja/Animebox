//
//  MangaPublishingStatusTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct MangaPublishingStatusTests {

    init() {
        // displayName ahora depende de AppLanguage.current (Ajustes >
        // Idioma) — se fija explícitamente para que el test sea
        // determinista sin importar la preferencia persistida del entorno.
        AppLanguage.current = .spanish
    }

    @Test("Reconoce los tres vocabularios (Jikan Title Case, MAL snake_case y AniList SCREAMING_SNAKE_CASE)", arguments: [
        ("Publishing", MangaPublishingStatus.publishing),
        ("currently_publishing", MangaPublishingStatus.publishing),
        ("RELEASING", MangaPublishingStatus.publishing),
        ("Finished", MangaPublishingStatus.finished),
        ("finished", MangaPublishingStatus.finished),
        ("FINISHED", MangaPublishingStatus.finished),
        ("On Hiatus", MangaPublishingStatus.onHiatus),
        ("on_hiatus", MangaPublishingStatus.onHiatus),
        ("HIATUS", MangaPublishingStatus.onHiatus),
        ("Discontinued", MangaPublishingStatus.discontinued),
        ("discontinued", MangaPublishingStatus.discontinued),
        ("CANCELLED", MangaPublishingStatus.discontinued),
        ("Not yet published", MangaPublishingStatus.notYetPublished),
        ("not_yet_published", MangaPublishingStatus.notYetPublished),
        ("NOT_YET_RELEASED", MangaPublishingStatus.notYetPublished),
    ])
    func recognizesBothVocabularies(apiValue: String, expected: MangaPublishingStatus) {
        #expect(MangaPublishingStatus(apiValue: apiValue) == expected)
    }

    @Test("Un valor no reconocido devuelve nil, no crashea")
    func unknownValueReturnsNil() {
        #expect(MangaPublishingStatus(apiValue: "algo_inventado") == nil)
    }

    @Test("displayName está en español", arguments: [
        (MangaPublishingStatus.publishing, "Publicándose"),
        (MangaPublishingStatus.finished, "Finalizado"),
        (MangaPublishingStatus.onHiatus, "En pausa"),
        (MangaPublishingStatus.discontinued, "Descontinuado"),
        (MangaPublishingStatus.notYetPublished, "Aún no publicado"),
    ])
    func displayName(status: MangaPublishingStatus, expected: String) {
        #expect(status.displayName == expected)
    }
}
