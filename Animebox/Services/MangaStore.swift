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

    func entry(for mangaId: Int) -> MangaLibraryEntry? {
        var descriptor = FetchDescriptor<MangaLibraryEntry>(
            predicate: #Predicate { $0.malId == mangaId }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func upsert(
        manga: Manga,
        status: MangaStatus,
        chaptersRead: Int,
        volumesRead: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date? = .now,
        finishDate: Date? = nil
    ) throws {
        if let existing = entry(for: manga.malId) {
            existing.title = manga.displayTitle
            existing.imageURL = manga.images.bestURL?.absoluteString
            existing.status = status
            existing.chaptersRead = chaptersRead
            existing.volumesRead = volumesRead
            existing.totalChapters = manga.chapters
            existing.totalVolumes = manga.volumes
            existing.personalScore = personalScore
            existing.mangaScore = manga.score
            existing.notes = notes
            existing.startDate = startDate
            existing.finishDate = finishDate
            existing.updatedAt = .now
        } else {
            let entry = MangaLibraryEntry(
                malId: manga.malId,
                title: manga.displayTitle,
                imageURL: manga.images.bestURL?.absoluteString,
                status: status,
                chaptersRead: chaptersRead,
                volumesRead: volumesRead,
                totalChapters: manga.chapters,
                totalVolumes: manga.volumes,
                personalScore: personalScore,
                mangaScore: manga.score,
                notes: notes,
                startDate: startDate,
                finishDate: finishDate,
                updatedAt: .now
            )
            context.insert(entry)
        }
        try save()
    }

    func delete(mangaId: Int) throws {
        guard let existing = entry(for: mangaId) else { return }
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
