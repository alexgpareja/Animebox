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

    /// `malId` ya no es único en solitario — MAL/Tenrai y AniList tienen
    /// espacios de ID distintos, así que la identidad real de una entrada es
    /// el par `(malId, provider)`.
    func entry(for animeId: Int, provider: LibraryProvider) -> LibraryEntry? {
        let providerRaw = provider.rawValue
        var descriptor = FetchDescriptor<LibraryEntry>(
            predicate: #Predicate { $0.malId == animeId && $0.providerRaw == providerRaw }
        )
        descriptor.fetchLimit = 1
        return try? context.fetch(descriptor).first
    }

    func upsert(
        anime: Anime,
        provider: LibraryProvider,
        status: LibraryStatus,
        progress: Int,
        personalScore: Int?,
        notes: String?,
        startDate: Date? = .now,
        finishDate: Date? = nil
    ) throws {
        if let existing = entry(for: anime.malId, provider: provider) {
            existing.title = anime.displayTitle
            existing.imageURL = anime.images.bestURL?.absoluteString
            existing.status = status
            existing.progress = progress
            existing.totalEpisodes = anime.episodes
            existing.personalScore = personalScore
            existing.animeScore = anime.score
            existing.members = anime.members
            existing.genreNames = anime.genres?.map(\.name)
            existing.notes = notes
            existing.startDate = startDate
            existing.finishDate = finishDate
            existing.updatedAt = .now
        } else {
            let entry = LibraryEntry(
                malId: anime.malId,
                provider: provider,
                title: anime.displayTitle,
                imageURL: anime.images.bestURL?.absoluteString,
                status: status,
                progress: progress,
                totalEpisodes: anime.episodes,
                personalScore: personalScore,
                animeScore: anime.score,
                members: anime.members,
                genreNames: anime.genres?.map(\.name),
                notes: notes,
                startDate: startDate,
                finishDate: finishDate,
                updatedAt: .now
            )
            context.insert(entry)
        }
        try save()
    }

    func delete(animeId: Int, provider: LibraryProvider) throws {
        guard let existing = entry(for: animeId, provider: provider) else { return }
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
