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
            for: LibraryEntry.self, MangaLibraryEntry.self, PendingDeletion.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private func signedInAccount() -> (LinkedAccount, InMemoryTokenStore) {
        let tokenStore = InMemoryTokenStore(
            stored: MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))
        )
        let account = LinkedAccount(mal: MALSession(tokenStore: tokenStore), aniList: AniListSession(tokenStore: InMemoryAniListTokenStore()))
        return (account, tokenStore)
    }

    private func guestAccount() -> LinkedAccount {
        LinkedAccount(mal: MALSession(tokenStore: InMemoryTokenStore()), aniList: AniListSession(tokenStore: InMemoryAniListTokenStore()))
    }

    @Test("Guarda localmente sin sesión iniciada, sin intentar sincronizar")
    func savesLocallyWithoutSession() throws {
        let container = try makeContainer()
        let account = guestAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)

        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 3,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )

        #expect(coordinator.libraryStore.entry(for: 1, provider: .mal) != nil)
        #expect(syncSpy.pushedAnimeStatuses.isEmpty)
    }

    @Test("Con sesión iniciada empuja el cambio a MAL en segundo plano")
    func pushesToMALWhenSignedIn() async throws {
        let container = try makeContainer()
        let (account, _) = signedInAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)

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
        let (account, _) = signedInAccount()
        let syncSpy = MALLibrarySyncingSpy()
        syncSpy.pushErrorToThrow = NetworkError.transport("boom")
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)

        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 1,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        try await Task.sleep(for: .milliseconds(100))

        #expect(coordinator.libraryStore.entry(for: 1, provider: .mal) != nil, "El guardado local debe persistir pese al fallo remoto")
        #expect(account.lastSyncError != nil)
    }

    @Test("incrementAnimeProgress guarda localmente y empuja el nuevo progreso")
    func incrementProgressPushesUpdatedValue() async throws {
        let container = try makeContainer()
        let (account, _) = signedInAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1, provider: .mal))

        try coordinator.incrementAnimeProgress(entry)
        try await Task.sleep(for: .milliseconds(100))

        #expect(entry.progress == 1)
        #expect(syncSpy.pushedAnimeStatuses.last?.progress == 1)
    }

    @Test("deleteAnime borra localmente y pide el borrado remoto")
    func deleteAnimeRemovesLocallyAndRemotely() async throws {
        let container = try makeContainer()
        let (account, _) = signedInAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1, provider: .mal))

        try coordinator.deleteAnime(entry)
        try await Task.sleep(for: .milliseconds(100))

        #expect(coordinator.libraryStore.entry(for: 1, provider: .mal) == nil)
        #expect(syncSpy.deletedAnimeIDs == [1])
    }

    @Test("deleteAnime sin sesión no toca la red — guarda un recordatorio de borrado pendiente")
    func deleteAnimeWithoutSessionRecordsPendingDeletion() throws {
        let container = try makeContainer()
        let account = guestAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1, provider: .mal))

        try coordinator.deleteAnime(entry)

        #expect(coordinator.libraryStore.entry(for: 1, provider: .mal) == nil)
        #expect(syncSpy.deletedAnimeIDs.isEmpty, "sin sesión no hay a quién avisar en el momento")
        let pending = try container.mainContext.fetch(FetchDescriptor<PendingDeletion>())
        #expect(pending.map(\.malId) == [1])
        #expect(pending.first?.kind == .anime)
    }

    @Test("deleteManga sin sesión guarda un recordatorio de borrado pendiente")
    func deleteMangaWithoutSessionRecordsPendingDeletion() throws {
        let container = try makeContainer()
        let account = guestAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)
        try coordinator.upsertManga(
            manga: .fixture(id: 2), status: .reading, chaptersRead: 0, volumesRead: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.mangaStore.entry(for: 2, provider: .mal))

        try coordinator.deleteManga(entry)

        let pending = try container.mainContext.fetch(FetchDescriptor<PendingDeletion>())
        #expect(pending.map(\.malId) == [2])
        #expect(pending.first?.kind == .manga)
    }

    @Test("deleteAnime con sesión iniciada no deja recordatorio pendiente")
    func deleteAnimeWithSessionDoesNotRecordPendingDeletion() async throws {
        let container = try makeContainer()
        let (account, _) = signedInAccount()
        let syncSpy = MALLibrarySyncingSpy()
        let coordinator = LibrarySyncCoordinator(context: container.mainContext, account: account, syncService: syncSpy)
        try coordinator.upsertAnime(
            anime: .fixture(id: 1), status: .watching, progress: 0,
            personalScore: nil, notes: nil, startDate: nil, finishDate: nil
        )
        let entry = try #require(coordinator.libraryStore.entry(for: 1, provider: .mal))

        try coordinator.deleteAnime(entry)
        try await Task.sleep(for: .milliseconds(100))

        let pending = try container.mainContext.fetch(FetchDescriptor<PendingDeletion>())
        #expect(pending.isEmpty, "con sesión el borrado ya se empuja al instante, no hace falta recordarlo")
    }
}
