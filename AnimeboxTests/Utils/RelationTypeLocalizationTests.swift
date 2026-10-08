//
//  RelationTypeLocalizationTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct RelationTypeLocalizationTests {

    init() {
        AppLanguage.current = .spanish
    }

    @Test("Traduce tipos de relación conocidos al español", arguments: [
        ("Sequel", "Secuela"),
        ("Prequel", "Precuela"),
        ("Side Story", "Historia paralela"),
    ])
    func translatesKnownTypes(raw: String, expected: String) {
        #expect(RelationTypeLocalization.localizedName(for: raw) == expected)
    }

    @Test("Un tipo no reconocido cae de vuelta al texto crudo, no crashea")
    func unknownTypeFallsBackToRaw() {
        #expect(RelationTypeLocalization.localizedName(for: "Some Future Relation") == "Some Future Relation")
    }
}
