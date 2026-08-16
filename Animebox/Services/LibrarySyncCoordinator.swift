//
//  LibrarySyncCoordinator.swift
//  Animebox
//

import Foundation
import SwiftData

/// Único punto de mutación de la biblioteca local — antes había tres
/// (`LibraryStore`/`MangaStore` y el `commit()` propio de `LibraryView`),
/// lo que ya causó una asimetría real (`MangaStore` sin aviso al widget).
/// Aquí se guarda localmente primero (mismo comportamiento/errores de
/// siempre) y, solo si hay sesión iniciada, se intenta el push a MAL en
/// segundo plano — un fallo de red en el push no deshace ni hace fallar el
/// guardado local, se deja constancia en `session.lastSyncError`.
@MainActor
struct LibrarySyncCoordinator {
    let libraryStore: LibraryStore
    let mangaStore: MangaStore
    let session: MALSession
    let syncService: MALLibrarySyncing

    init(context: ModelContext, session: MALSession, syncService: MALLibrarySyncing? = nil) {
        self.libraryStore = LibraryStore(context: context)
        self.mangaStore = MangaStore(context: context)
        self.session = session
        self.syncService = syncService ?? MALLibrarySyncService(malSession: session)
    }

    // MARK: - Anime

    func upsertAnime(
        anime: Anime,
        status: LibraryStatus,
        progress: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date?,
        finishDate: Date?
    ) throws {
        try libraryStore.upsert(
            anime: anime, status: status, progress: progress, personalScore: personalScore,
            notes: notes, startDate: startDate, finishDate: finishDate
        )
        pushAnime(malId: anime.malId, status: status, progress: progress, score: personalScore)
    }

    func deleteAnime(_ entry: LibraryEntry) throws {
        let malId = entry.malId
        try libraryStore.delete(animeId: malId)
        deleteRemoteAnime(malId: malId)
    }

    func incrementAnimeProgress(_ entry: LibraryEntry) throws {
        entry.incrementProgress()
        try libraryStore.save()
        pushAnime(malId: entry.malId, status: entry.status, progress: entry.progress, score: entry.personalScore)
    }

    // MARK: - Manga

    func upsertManga(
        manga: Manga,
        status: MangaStatus,
        chaptersRead: Int,
        volumesRead: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date?,
        finishDate: Date?
    ) throws {
        try mangaStore.upsert(
            manga: manga, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead,
            personalScore: personalScore, notes: notes, startDate: startDate, finishDate: finishDate
        )
        pushManga(malId: manga.malId, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead, score: personalScore)
    }

    func deleteManga(_ entry: MangaLibraryEntry) throws {
        let malId = entry.malId
        try mangaStore.delete(mangaId: malId)
        deleteRemoteManga(malId: malId)
    }

    func incrementMangaProgress(_ entry: MangaLibraryEntry) throws {
        entry.incrementProgress()
        try mangaStore.save()
        pushManga(
            malId: entry.malId, status: entry.status, chaptersRead: entry.chaptersRead,
            volumesRead: entry.volumesRead, score: entry.personalScore
        )
    }

    // MARK: - Push en segundo plano (best-effort)

    private func pushAnime(malId: Int, status: LibraryStatus, progress: Int, score: Int?) {
        guard session.isSignedIn else { return }
        Task {
            do {
                try await syncService.pushAnimeStatus(malId: malId, status: status, progress: progress, score: score)
                session.lastSyncError = nil
            } catch {
                session.lastSyncError = error.localizedDescription
            }
        }
    }

    private func deleteRemoteAnime(malId: Int) {
        guard session.isSignedIn else { return }
        Task {
            do {
                try await syncService.deleteAnimeStatus(malId: malId)
                session.lastSyncError = nil
            } catch {
                session.lastSyncError = error.localizedDescription
            }
        }
    }

    private func pushManga(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) {
        guard session.isSignedIn else { return }
        Task {
            do {
                try await syncService.pushMangaStatus(
                    malId: malId, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead, score: score
                )
                session.lastSyncError = nil
            } catch {
                session.lastSyncError = error.localizedDescription
            }
        }
    }

    private func deleteRemoteManga(malId: Int) {
        guard session.isSignedIn else { return }
        Task {
            do {
                try await syncService.deleteMangaStatus(malId: malId)
                session.lastSyncError = nil
            } catch {
                session.lastSyncError = error.localizedDescription
            }
        }
    }
}
