//
//  MALSyncReconcilerTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
@Suite("MALSyncReconciler")
struct MALSyncReconcilerTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: LibraryEntry.self, MangaLibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test("Empuja las entradas locales existentes y luego adopta la lista remota")
    func pushesLocalEntriesThenAdoptsRemoteList() async throws {
        let container = try makeContainer()
        let libraryStore = LibraryStore(context: container.mainContext)
        try libraryStore.upsert(
            anime: .fixture(id: 1), status: .watching, progress: 2, personalScore: nil, notes: nil
        )

        let syncSpy = MALLibrarySyncingSpy()
        syncSpy.animeToPull = [
            MALPulledAnimeEntry(anime: .fixture(id: 2), status: .completed, progress: 12, score: 9, startDate: nil, finishDate: nil)
        ]
        let session = MALSession(tokenStore: InMemoryTokenStore())
        let reconciler = MALSyncReconciler(context: container.mainContext, session: session, syncService: syncSpy)

        try await reconciler.reconcile()

        #expect(syncSpy.pushedAnimeStatuses.map(\.malId) == [1], "La entrada local debe empujarse antes de tirar de la lista remota")
        let adopted = try #require(libraryStore.entry(for: 2))
        #expect(adopted.status == .completed)
        #expect(adopted.progress == 12)
    }

    @Test("El estado remoto manda para una entrada que también existe localmente, preservando las notas locales")
    func remoteWinsForExistingEntryButKeepsLocalNotes() async throws {
        let container = try makeContainer()
        let libraryStore = LibraryStore(context: container.mainContext)
        try libraryStore.upsert(
            anime: .fixture(id: 1), status: .planned, progress: 0, personalScore: nil, notes: "mi nota"
        )

        let syncSpy = MALLibrarySyncingSpy()
        syncSpy.animeToPull = [
            MALPulledAnimeEntry(anime: .fixture(id: 1), status: .watching, progress: 5, score: 7, startDate: nil, finishDate: nil)
        ]
        let session = MALSession(tokenStore: InMemoryTokenStore())
        let reconciler = MALSyncReconciler(context: container.mainContext, session: session, syncService: syncSpy)

        try await reconciler.reconcile()

        let entry = try #require(libraryStore.entry(for: 1))
        #expect(entry.status == .watching)
        #expect(entry.progress == 5)
        #expect(entry.notes == "mi nota", "MAL no devuelve notas — las locales no deben perderse al adoptar el resto del estado remoto")
    }

    @Test("Reconciliación de manga sigue el mismo patrón push-then-pull")
    func mangaFollowsSamePattern() async throws {
        let container = try makeContainer()
        let mangaStore = MangaStore(context: container.mainContext)
        try mangaStore.upsert(
            manga: .fixture(id: 1), status: .reading, chaptersRead: 3, volumesRead: 0,
            personalScore: nil, notes: nil
        )

        let syncSpy = MALLibrarySyncingSpy()
        syncSpy.mangaToPull = [
            MALPulledMangaEntry(manga: .fixture(id: 2), status: .completed, chaptersRead: 50, volumesRead: 5, score: 8, startDate: nil, finishDate: nil)
        ]
        let session = MALSession(tokenStore: InMemoryTokenStore())
        let reconciler = MALSyncReconciler(context: container.mainContext, session: session, syncService: syncSpy)

        try await reconciler.reconcile()

        #expect(syncSpy.pushedMangaStatuses.map(\.malId) == [1])
        let adopted = try #require(mangaStore.entry(for: 2))
        #expect(adopted.status == .completed)
        #expect(adopted.chaptersRead == 50)
    }
}
