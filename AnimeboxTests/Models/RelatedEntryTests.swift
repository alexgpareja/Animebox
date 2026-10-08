//
//  RelatedEntryTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct RelatedEntryTests {

    @Test("Filtra relations por tipo, ignorando entradas de tipo distinto (p. ej. la manga de una adaptación)")
    func filtersByType() {
        let relations: [RelationGroup] = [
            RelationGroup(relation: "Adaptation", entry: [
                RelationGroupEntry(malId: 13, type: "manga", name: "One Piece", images: nil)
            ]),
            RelationGroup(relation: "Sequel", entry: [
                RelationGroupEntry(malId: 99, type: "anime", name: "One Piece: Next Arc", images: nil)
            ])
        ]

        let related = relations.relatedEntries(ofType: "anime")

        #expect(related.count == 1)
        #expect(related.first?.malId == 99)
        #expect(related.first?.relation == "Sequel")
    }

    @Test("Un grupo con varias entradas del mismo tipo se aplana en varias RelatedEntry")
    func flattensMultipleEntriesInSameGroup() {
        let relations: [RelationGroup] = [
            RelationGroup(relation: "Side Story", entry: [
                RelationGroupEntry(malId: 1, type: "anime", name: "A", images: nil),
                RelationGroupEntry(malId: 2, type: "anime", name: "B", images: nil)
            ])
        ]

        #expect(relations.relatedEntries(ofType: "anime").count == 2)
    }

    @Test("nil relations produce lista vacía, no crashea")
    func nilRelationsProducesEmptyList() {
        let anime = Anime.fixture()
        #expect(anime.relatedAnime.isEmpty)
    }
}
