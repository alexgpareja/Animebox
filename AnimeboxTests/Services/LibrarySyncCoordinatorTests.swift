//
//  LibrarySyncCoordinatorTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
@Suite("LibrarySyncCoordinator")
struct LibrarySyncCoordinatorTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: LibraryEntry.self, MangaLibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func signedInSession() -> (MALSession, InMemoryTokenStore) {
        let tokenStore = InMemoryTokenStore(
            stored: MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))
        )
        return (MALSession(tokenStore: tokenStore), tokenStore)
    }

    @Test("Guarda localmente sin sesión iniciada, sin intentar sincronizar")
    func savesLocallyWithoutSession() throws {
        let container = try makeContainer()
        let session = MALSession(tokenStore: InMemoryTokenStore())
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, session: session, syncService: syncSpy)

        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 3,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )

        #expect(coordinator.libraryStore.entry(for: 1) != nil)
        #expect(syncSpy.pushedAnimeStatuses.isEmpty)
    }

    @Test("Con sesión iniciada empuja el cambio a MAL en segundo plano")
    func pushesToMALWhenSignedIn() async throws {
        let container = try makeContainer()
        let (session, _) = signedInSession()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, session: session, syncService: syncSpy)

        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 3,
            personalScore: 8, notes: nil, startDate: nil, finishDate: nil
        )
        try await Task.sleep(for: .milliseconds(100))

        #expect(syncSpy.pushedAnimeStatuses.count == 1)
        #expect(syncSpy.pushedAnimeStatuses.first?.malId == 1)
        #expect(syncSpy.pushedAnimeStatuses.first?.progress == 3)
    }

    @Test("Un push remoto fallido no revierte ni hace fallar el guardado local")
    func failedPushDoesNotUndoLocalSave() async throws {
        let container = try makeContainer()
        let (session, _) = signedInSession()
        let syncSpy = MALLibrarySyncingSpy()
        syncSpy.pushErrorToThrow = NetworkError.transport("boom")
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, session: session, syncService: syncSpy)

        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 1,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        try await Task.sleep(for: .milliseconds(100))

        #expect(coordinator.libraryStore.entry(for: 1) != nil, "El guardado local debe persistir pese al fallo remoto")
        #expect(session.lastSyncError != nil)
    }

    @Test("incrementAnimeProgress guarda localmente y empuja el nuevo progreso")
    func incrementProgressPushesUpdatedValue() async throws {
        let container = try makeContainer()
        let (session, _) = signedInSession()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, session: session, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1))

        try coordinator.incrementAnimeProgress(entry)
        try await Task.sleep(for: .milliseconds(100))

        #expect(entry.progress == 1)
        #expect(syncSpy.pushedAnimeStatuses.last?.progress == 1)
    }

    @Test("deleteAnime borra localmente y pide el borrado remoto")
    func deleteAnimeRemovesLocallyAndRemotely() async throws {
        let container = try makeContainer()
        let (session, _) = signedInSession()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, session: session, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1))

        try coordinator.deleteAnime(entry)
        try await Task.sleep(for: .milliseconds(100))

        #expect(coordinator.libraryStore.entry(for: 1) == nil)
        #expect(syncSpy.deletedAnimeIDs == [1])
    }
}
