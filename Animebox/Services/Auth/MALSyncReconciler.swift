//
//  MALSyncReconciler.swift
//  Animebox
//

import Foundation
import SwiftData

/// Se dispara justo tras un login con éxito. Empuja primero los borrados
/// pendientes de modo invitado (`PendingDeletion` — si no, el `pull` de más
/// abajo traería de vuelta algo que el usuario borró en local sin sesión,
/// porque MAL nunca se enteró de ese borrado), luego empuja todo lo local
/// restante (para no perder datos de modo invitado que aún no existan en
/// MAL) y por último tira de la lista real completa, que a partir de ahí
/// manda — sin resolución de conflictos bidireccional más allá de esto, es
/// una simplificación deliberada de v1, no un descuido.
@MainActor
struct MALSyncReconciler {
    let context: ModelContext
    let syncService: MALLibrarySyncing

    init(context: ModelContext, session: MALSession, syncService: MALLibrarySyncing? = nil) {
        self.context = context
        self.syncService = syncService ?? MALLibrarySyncService(malSession: session)
    }

    func reconcile() async throws {
        let libraryStore = LibraryStore(context: context)
        let mangaStore = MangaStore(context: context)

        await pushPendingDeletions()
        await pushLocalOnlyEntries(libraryStore: libraryStore, mangaStore: mangaStore)

        let remoteAnime = try await syncService.pullAnimeList()
        for pulled in remoteAnime {
            // Las notas son solo locales (MAL no las devuelve) — se preservan
            // en vez de sobreescribirlas a nil al adoptar el estado remoto.
            let existingNotes = libraryStore.entry(for: pulled.anime.malId, provider: .mal)?.notes
            try libraryStore.upsert(
                anime: pulled.anime, provider: .mal, status: pulled.status, progress: pulled.progress,
                personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }

        let remoteManga = try await syncService.pullMangaList()
        for pulled in remoteManga {
            let existingNotes = mangaStore.entry(for: pulled.manga.malId, provider: .mal)?.notes
            try mangaStore.upsert(
                manga: pulled.manga, provider: .mal, status: pulled.status, chaptersRead: pulled.chaptersRead,
                volumesRead: pulled.volumesRead, personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }
    }

    /// Best-effort como el resto de esta reconciliación: si el borrado
    /// remoto falla (red, el ID ya no existe en MAL...) se limpia igualmente
    /// el recordatorio en vez de reintentar indefinidamente. Solo consume
    /// las tombstones de `.mal` — una de `.aniList` es de otro espacio de
    /// IDs y la consumirá `AniListSyncReconciler` si toca reconectar allí.
    private func pushPendingDeletions() async {
        let pending = ((try? context.fetch(FetchDescriptor<PendingDeletion>())) ?? [])
            .filter { $0.provider == .mal }
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
            .filter { $0.provider == .mal }
        for entry in localAnime {
            try? await syncService.pushAnimeStatus(
                malId: entry.malId, status: entry.status, progress: entry.progress, score: entry.personalScore
            )
        }
        let localManga = ((try? context.fetch(FetchDescriptor<MangaLibraryEntry>())) ?? [])
            .filter { $0.provider == .mal }
        for entry in localManga {
            try? await syncService.pushMangaStatus(
                malId: entry.malId, status: entry.status, chaptersRead: entry.chaptersRead,
                volumesRead: entry.volumesRead, score: entry.personalScore
            )
        }
    }
}
