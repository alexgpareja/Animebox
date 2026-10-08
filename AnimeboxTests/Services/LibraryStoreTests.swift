//
//  LibraryStoreTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
struct LibraryStoreTests {
    let container: ModelContainer
    let store: LibraryStore

    init() throws {
        container = try ModelContainer(
            for: LibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = LibraryStore(context: container.mainContext)
    }

    @Test("upsert crea una nueva entrada cuando no existe")
    func upsertCreatesEntry() throws {
        let anime = Anime.fixture(id: 1, title: "Nuevo")
        try store.upsert(anime: anime, provider: .mal, status: .watching, progress: 5, personalScore: 8, notes: "wip")

        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.title == "Nuevo")
        #expect(entry.status == .watching)
        #expect(entry.progress == 5)
        #expect(entry.personalScore == 8)
        #expect(entry.notes == "wip")
    }

    @Test("upsert actualiza la entrada existente en vez de crear duplicado")
    func upsertUpdatesExistingEntry() throws {
        let anime = Anime.fixture(id: 1, title: "Original")
        try store.upsert(anime: anime, provider: .mal, status: .watching, progress: 5, personalScore: nil, notes: nil)
        try store.upsert(anime: anime, provider: .mal, status: .completed, progress: 12, personalScore: 9, notes: "great")

        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.status == .completed)
        #expect(entry.progress == 12)
        #expect(entry.personalScore == 9)
        #expect(entry.notes == "great")

        let all = try container.mainContext.fetch(FetchDescriptor<LibraryEntry>())
        #expect(all.count == 1, "no debe duplicarse el row")
    }

    @Test("delete elimina la entrada por malId")
    func deleteRemovesEntry() throws {
        let anime = Anime.fixture(id: 1)
        try store.upsert(anime: anime, provider: .mal, status: .watching, progress: 0, personalScore: nil, notes: nil)
        try #require(store.entry(for: 1, provider: .mal) != nil)

        try store.delete(animeId: 1, provider: .mal)
        #expect(store.entry(for: 1, provider: .mal) == nil)
    }

    @Test("entry(for:) devuelve nil si no existe la entrada")
    func entryReturnsNilForMissingId() {
        #expect(store.entry(for: 999, provider: .mal) == nil)
    }

    @Test("delete sobre un id inexistente no lanza error")
    func deleteOnMissingIdIsNoOp() throws {
        try store.delete(animeId: 999, provider: .mal)
    }

    @Test("upsert sin startDate explícito asigna la fecha actual")
    func upsertDefaultsStartDateToNow() throws {
        let before = Date.now
        try store.upsert(
            anime: .fixture(id: 1),
            provider: .mal, status: .watching, progress: 0, personalScore: nil, notes: nil
        )
        let entry = try #require(store.entry(for: 1, provider: .mal))
        let startDate = try #require(entry.startDate)
        #expect(startDate >= before)
        #expect(startDate <= Date.now)
    }

    @Test("upsert persiste startDate y finishDate explícitos")
    func upsertPersistsExplicitDates() throws {
        let start = Date(timeIntervalSince1970: 1_000_000)
        let finish = Date(timeIntervalSince1970: 2_000_000)
        try store.upsert(
            anime: .fixture(id: 1),
            provider: .mal, status: .completed, progress: 24, personalScore: 9, notes: nil,
            startDate: start, finishDate: finish
        )
        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.startDate == start)
        #expect(entry.finishDate == finish)
    }
}
