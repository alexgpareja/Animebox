//
//  LibraryStore.swift
//  Animebox
//

import Foundation
import SwiftData
import WidgetKit

@MainActor
struct LibraryStore {
    let context: ModelContext

    func entry(for animeId: Int) -> LibraryEntry? {
        var descriptor = FetchDescriptor<LibraryEntry>(
            predicate: #Predicate { $0.malId == animeId }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func upsert(
        anime: Anime,
        status: LibraryStatus,
        progress: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date? = .now,
        finishDate: Date? = nil
    ) throws {
        if let existing = entry(for: anime.malId) {
            existing.title = anime.displayTitle
            existing.imageURL = anime.images.bestURL?.absoluteString
            existing.status = status
            existing.progress = progress
            existing.totalEpisodes = anime.episodes
            existing.personalScore = personalScore
            existing.animeScore = anime.score
            existing.notes = notes
            existing.startDate = startDate
            existing.finishDate = finishDate
            existing.updatedAt = .now
        } else {
            let entry = LibraryEntry(
                malId: anime.malId,
                title: anime.displayTitle,
                imageURL: anime.images.bestURL?.absoluteString,
                status: status,
                progress: progress,
                totalEpisodes: anime.episodes,
                personalScore: personalScore,
                animeScore: anime.score,
                notes: notes,
                startDate: startDate,
                finishDate: finishDate,
                updatedAt: .now
            )
            context.insert(entry)
        }
        try save()
    }

    func delete(animeId: Int) throws {
        guard let existing = entry(for: animeId) else { return }
        context.delete(existing)
        try save()
    }

    /// Guarda el contexto y avisa al widget — expuesto para que
    /// `LibrarySyncCoordinator` lo use también tras mutar un `LibraryEntry`
    /// ya obtenido (p. ej. `incrementProgress()`), sin duplicar esta lógica.
    func save() throws {
        try context.save()
        WidgetCenter.shared.reloadTimelines(ofKind: "WatchingNowWidget")
    }
}
