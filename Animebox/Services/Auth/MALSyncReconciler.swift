//
//  MALSyncReconciler.swift
//  Animebox
//

import Foundation
import SwiftData

/// Se dispara justo tras un login con éxito. Empuja primero todo lo local
/// (para no perder datos de modo invitado que aún no existan en MAL) y luego
/// tira de la lista real completa, que a partir de ahí manda — sin
/// resolución de conflictos bidireccional más allá de esto, es una
/// simplificación deliberada de v1, no un descuido.
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

        await pushLocalOnlyEntries(libraryStore: libraryStore, mangaStore: mangaStore)

        let remoteAnime = try await syncService.pullAnimeList()
        for pulled in remoteAnime {
            // Las notas son solo locales (MAL no las devuelve) — se preservan
            // en vez de sobreescribirlas a nil al adoptar el estado remoto.
            let existingNotes = libraryStore.entry(for: pulled.anime.malId)?.notes
            try libraryStore.upsert(
                anime: pulled.anime, status: pulled.status, progress: pulled.progress,
                personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }

        let remoteManga = try await syncService.pullMangaList()
        for pulled in remoteManga {
            let existingNotes = mangaStore.entry(for: pulled.manga.malId)?.notes
            try mangaStore.upsert(
                manga: pulled.manga, status: pulled.status, chaptersRead: pulled.chaptersRead,
                volumesRead: pulled.volumesRead, personalScore: pulled.score, notes: existingNotes,
                startDate: pulled.startDate, finishDate: pulled.finishDate
            )
        }
    }

    private func pushLocalOnlyEntries(libraryStore: LibraryStore, mangaStore: MangaStore) async {
        let localAnime = (try? context.fetch(FetchDescriptor<LibraryEntry>())) ?? []
        for entry in localAnime {
            try? await syncService.pushAnimeStatus(
                malId: entry.malId, status: entry.status, progress: entry.progress, score: entry.personalScore
            )
        }
        let localManga = (try? context.fetch(FetchDescriptor<MangaLibraryEntry>())) ?? []
        for entry in localManga {
            try? await syncService.pushMangaStatus(
                malId: entry.malId, status: entry.status, chaptersRead: entry.chaptersRead,
                volumesRead: entry.volumesRead, score: entry.personalScore
            )
        }
    }
}
