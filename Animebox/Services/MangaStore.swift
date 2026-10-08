//
//  MangaStore.swift
//  Animebox
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
struct MangaStore {
    let context: ModelContext

    /// Ver `LibraryStore.entry(for:provider:)` — misma razón para el par
    /// `(malId, provider)` en vez de solo `malId`.
    func entry(for mangaId: Int, provider: LibraryProvider) -> MangaLibraryEntry? {
        let providerRaw = provider.rawValue
        var descriptor = FetchDescriptor<MangaLibraryEntry>(
            predicate: #Predicate { $0.malId == mangaId && $0.providerRaw == providerRaw }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func upsert(
        manga: Manga,
        provider: LibraryProvider,
        status: MangaStatus,
        chaptersRead: Int,
        volumesRead: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date? = .now,
        finishDate: Date? = nil
    ) throws {
        if let existing = entry(for: manga.malId, provider: provider) {
            existing.title = manga.displayTitle
            existing.imageURL = manga.images.bestURL?.absoluteString
            existing.status = status
            existing.chaptersRead = chaptersRead
            existing.volumesRead = volumesRead
            existing.totalChapters = manga.chapters
            existing.totalVolumes = manga.volumes
            existing.personalScore = personalScore
            existing.mangaScore = manga.score
            existing.members = manga.members
            existing.genreNames = manga.genres?.map(\.name)
            existing.notes = notes
            existing.startDate = startDate
            existing.finishDate = finishDate
            existing.updatedAt = .now
        } else {
            let entry = MangaLibraryEntry(
                malId: manga.malId,
                provider: provider,
                title: manga.displayTitle,
                imageURL: manga.images.bestURL?.absoluteString,
                status: status,
                chaptersRead: chaptersRead,
                volumesRead: volumesRead,
                totalChapters: manga.chapters,
                totalVolumes: manga.volumes,
                personalScore: personalScore,
                mangaScore: manga.score,
                members: manga.members,
                genreNames: manga.genres?.map(\.name),
                notes: notes,
                startDate: startDate,
                finishDate: finishDate,
                updatedAt: .now
            )
            context.insert(entry)
        }
        try save()
    }

    func delete(mangaId: Int, provider: LibraryProvider) throws {
        guard let existing = entry(for: mangaId, provider: provider) else { return }
        context.delete(existing)
        try save()
    }

    /// Igual que `LibraryStore.save()` — antes esta store no avisaba al
    /// widget en absoluto (solo `LibraryStore` lo hacía), una asimetría real
    /// causada por no tener un único punto de guardado. Centralizado aquí.
    func save() throws {
        try context.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "WatchingNowWidget")
    }
}
