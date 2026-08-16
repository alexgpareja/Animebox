//
//  MangaStoreTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
struct MangaStoreTests {
    let container: ModelContainer
    let store: MangaStore

    init() throws {
        container = try ModelContainer(
            for: MangaLibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        store = MangaStore(context: container.mainContext)
    }

    @Test("upsert crea una nueva entrada cuando no existe")
    func upsertCreatesEntry() throws {
        let manga = Manga.fixture(id: 1, title: "Nuevo")
        try store.upsert(
            manga: manga, status: .reading, chaptersRead: 5, volumesRead: 1,
            personalScore: 8, notes: "wip"
        )

        let entry = try #require(store.entry(for: 1))
        #expect(entry.title == "Nuevo")
        #expect(entry.status == .reading)
        #expect(entry.chaptersRead == 5)
        #expect(entry.volumesRead == 1)
        #expect(entry.personalScore == 8)
        #expect(entry.notes == "wip")
    }

    @Test("upsert actualiza la entrada existente en vez de crear duplicado")
    func upsertUpdatesExistingEntry() throws {
        let manga = Manga.fixture(id: 1, title: "Original")
        try store.upsert(
            manga: manga, status: .reading, chaptersRead: 5, volumesRead: 1,
            personalScore: nil, notes: nil
        )
        try store.upsert(
            manga: manga, status: .completed, chaptersRead: 12, volumesRead: 2,
            personalScore: 9, notes: "great"
        )

        let entry = try #require(store.entry(for: 1))
        #expect(entry.status == .completed)
        #expect(entry.chaptersRead == 12)
        #expect(entry.volumesRead == 2)
        #expect(entry.personalScore == 9)
        #expect(entry.notes == "great")

        let all = try container.mainContext.fetch(FetchDescriptor<MangaLibraryEntry>())
        #expect(all.count == 1, "no debe duplicarse el row")
    }

    @Test("delete elimina la entrada por malId")
    func deleteRemovesEntry() throws {
        let manga = Manga.fixture(id: 1)
        try store.upsert(
            manga: manga, status: .reading, chaptersRead: 0, volumesRead: 0,
            personalScore: nil, notes: nil
        )
        try #require(store.entry(for: 1) != nil)

        try store.delete(mangaId: 1)
        #expect(store.entry(for: 1) == nil)
    }

    @Test("entry(for:) devuelve nil si no existe la entrada")
    func entryReturnsNilForMissingId() {
        #expect(store.entry(for: 999) == nil)
    }

    @Test("delete sobre un id inexistente no lanza error")
    func deleteOnMissingIdIsNoOp() throws {
        try store.delete(mangaId: 999)
    }
}
