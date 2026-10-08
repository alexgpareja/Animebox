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
/// siempre) y, solo si hay sesión iniciada (MAL o AniList, ver
/// `LinkedAccount`), se intenta el push en segundo plano — un fallo de red
/// en el push no deshace ni hace fallar el guardado local, se deja
/// constancia en `account.lastSyncError`.
@MainActor
struct LibrarySyncCoordinator {
    let libraryStore: LibraryStore
    let mangaStore: MangaStore
    let account: LinkedAccount
    let syncService: MALLibrarySyncing?
    private let context: ModelContext

    init(context: ModelContext, account: LinkedAccount, syncService: MALLibrarySyncing? = nil) {
        self.context = context
        self.libraryStore = LibraryStore(context: context)
        self.mangaStore = MangaStore(context: context)
        self.account = account
        if let syncService {
            self.syncService = syncService
        } else {
            switch account.activeProvider {
            case .mal: self.syncService = MALLibrarySyncService(malSession: account.mal)
            case .aniList: self.syncService = AniListLibrarySyncService(aniListSession: account.aniList)
            case nil: self.syncService = nil
            }
        }
    }

    /// Proveedor con el que se guarda localmente cada entrada nueva — el
    /// activo si hay sesión, o `.mal` en modo invitado (Tenrai comparte el
    /// espacio de IDs de MAL, así que las entradas de invitado son
    /// compatibles si el usuario conecta MAL más adelante). No privado:
    /// las vistas que comprueban "¿ya está esto en mi biblioteca?" antes de
    /// guardar (`AddToLibrarySheet`/`AddToMangaLibrarySheet`) lo reutilizan
    /// para no duplicar la misma lógica.
    var currentProvider: LibraryProvider {
        account.activeProvider ?? .mal
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
            anime: anime, provider: currentProvider, status: status, progress: progress, personalScore: personalScore,
            notes: notes, startDate: startDate, finishDate: finishDate
        )
        pushAnime(malId: anime.malId, status: status, progress: progress, score: personalScore)
    }

    func deleteAnime(_ entry: LibraryEntry) throws {
        let malId = entry.malId
        let provider = entry.provider
        try libraryStore.delete(animeId: malId, provider: provider)
        if account.isSignedIn {
            deleteRemoteAnime(malId: malId)
        } else {
            recordPendingDeletion(malId: malId, provider: provider, kind: .anime)
        }
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
            manga: manga, provider: currentProvider, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead,
            personalScore: personalScore, notes: notes, startDate: startDate, finishDate: finishDate
        )
        pushManga(malId: manga.malId, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead, score: personalScore)
    }

    func deleteManga(_ entry: MangaLibraryEntry) throws {
        let malId = entry.malId
        let provider = entry.provider
        try mangaStore.delete(mangaId: malId, provider: provider)
        if account.isSignedIn {
            deleteRemoteManga(malId: malId)
        } else {
            recordPendingDeletion(malId: malId, provider: provider, kind: .manga)
        }
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

    /// Encadena los pushes por `malId` en vez de dispararlos en paralelo sin
    /// orden garantizado — tocar "+1 episodio" varias veces seguidas dispara
    /// un `Task` por tap, y sin esto una respuesta de red desordenada podía
    /// dejar el progreso remoto atascado en un valor más bajo que el local.
    private static var pendingAnimePushes: [Int: Task<Void, Never>] = [:]
    private static var pendingMangaPushes: [Int: Task<Void, Never>] = [:]

    private func pushAnime(malId: Int, status: LibraryStatus, progress: Int, score: Int?) {
        guard let syncService else { return }
        let previous = Self.pendingAnimePushes[malId]
        Self.pendingAnimePushes[malId] = Task {
            _ = await previous?.value
            do {
                try await syncService.pushAnimeStatus(malId: malId, status: status, progress: progress, score: score)
                account.lastSyncError = nil
            } catch {
                account.lastSyncError = error.localizedDescription
            }
        }
    }

    private func deleteRemoteAnime(malId: Int) {
        guard let syncService else { return }
        Task {
            do {
                try await syncService.deleteAnimeStatus(malId: malId)
                account.lastSyncError = nil
            } catch {
                account.lastSyncError = error.localizedDescription
            }
        }
    }

    private func pushManga(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) {
        guard let syncService else { return }
        let previous = Self.pendingMangaPushes[malId]
        Self.pendingMangaPushes[malId] = Task {
            _ = await previous?.value
            do {
                try await syncService.pushMangaStatus(
                    malId: malId, status: status, chaptersRead: chaptersRead, volumesRead: volumesRead, score: score
                )
                account.lastSyncError = nil
            } catch {
                account.lastSyncError = error.localizedDescription
            }
        }
    }

    private func deleteRemoteManga(malId: Int) {
        guard let syncService else { return }
        Task {
            do {
                try await syncService.deleteMangaStatus(malId: malId)
                account.lastSyncError = nil
            } catch {
                account.lastSyncError = error.localizedDescription
            }
        }
    }

    /// Solo se llama en modo invitado — con sesión iniciada el borrado ya se
    /// empuja al instante (arriba) y no hace falta recordarlo. El
    /// reconciler del proveedor correspondiente lo consume (empuja y lo
    /// limpia) justo después de iniciar sesión.
    private func recordPendingDeletion(malId: Int, provider: LibraryProvider, kind: MediaKind) {
        context.insert(PendingDeletion(malId: malId, provider: provider, kind: kind))
        try? context.save()
    }
}
