//
//  AniListSyncReconciler.swift
//  Animebox
//

import Foundation
import SwiftData

/// Mismo mecanismo que `MALSyncReconciler` (pending deletions → entradas
/// locales → pull gana), etiquetando cada entrada con `provider: .aniList`
/// y filtrando solo lo que ya era `.aniList` al leer local — ver el
/// comentario de `MALSyncReconciler.pushPendingDeletions()` para el porqué.
@MainActor
struct AniListSyncReconciler {
    let context: ModelContext
    let syncService: MALLibrarySyncing

    init(context: ModelContext, session: AniListSession, syncService: MALLibrarySyncing? = nil) {
        self.context = context
        self.syncService = syncService ?? AniListLibrarySyncService(aniListSession: session)
    }

    func reconcile() async throws {
        let libraryStore = LibraryStore(context: context)
        let mangaStore = MangaStore(context: context)

        await pushPendingDeletions()
        await pushLocalOnlyEntries(libraryStore: libraryStore, mangaStore: mangaStore)

        let remoteAnime = try await syncService.pullAnimeList()
        for pulled in remoteAnime {
            let existingNotes = libraryStore.entry(for: pulled.anime.malId, provider: .aniList)?.notes
            try libraryStore.upsert(
                anime: pulled.anime, provider: .aniList, status: pulled.status, progress: pulled.progress,
                personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }

        let remoteManga = try await syncService.pullMangaList()
        for pulled in remoteManga {
            let existingNotes = mangaStore.entry(for: pulled.manga.malId, provider: .aniList)?.notes
            try mangaStore.upsert(
                manga: pulled.manga, provider: .aniList, status: pulled.status, chaptersRead: pulled.chaptersRead,
                volumesRead: pulled.volumesRead, personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }
    }

    private func pushPendingDeletions() async {
        let pending = ((try? context.fetch(FetchDescriptor<PendingDeletion>())) ?? [])
            .filter { $0.provider == .aniList }
        guard !pending.isEmpty else { return }
        for tombstone in pending {
            switch tombstone.kind {
            case .anime:
                try? await syncService.deleteAnimeStatus(malId: tombstone.malId)
            case .manga:
                try? await syncService.deleteMangaStatus(malId: tombstone.malId)
            }
            context.delete(tombstone)
        }
        try? context.save()
    }

    private func pushLocalOnlyEntries(libraryStore: LibraryStore, mangaStore: MangaStore) async {
        let localAnime = ((try? context.fetch(FetchDescriptor<LibraryEntry>())) ?? [])
            .filter { $0.provider == .aniList }
        for entry in localAnime {
            try? await syncService.pushAnimeStatus(
                malId: entry.malId, status: entry.status, progress: entry.progress, score: entry.personalScore
            )
        }
        let localManga = ((try? context.fetch(FetchDescriptor<MangaLibraryEntry>())) ?? [])
            .filter { $0.provider == .aniList }
        for entry in localManga {
            try? await syncService.pushMangaStatus(
                malId: entry.malId, status: entry.status, chaptersRead: entry.chaptersRead,
                volumesRead: entry.volumesRead, score: entry.personalScore
            )
        }
    }
}
