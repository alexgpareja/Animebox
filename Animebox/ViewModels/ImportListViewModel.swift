//
//  ImportListViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class ImportListViewModel {
    enum State: Equatable {
        case idle
        case importing(current: Int, total: Int, kind: MediaKind)
        case done(count: Int)
        case error(String)
    }

    private(set) var state: State = .idle

    func fail(_ error: Error) {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        state = .error(message)
    }

    /// El endpoint de detalle no admite lote — se enriquece una entrada por
    /// petición. Este espaciado respeta el límite público sostenido de
    /// Tenrai (60/min): con listas de cientos de entradas el import tarda
    /// varios minutos, por eso la barra de progreso no es cosmética.
    private static let requestSpacing: Duration = .milliseconds(1050)

    func importFile(
        data: Data,
        service: ContentServicing,
        coordinator: LibrarySyncCoordinator
    ) async {
        do {
            let result = try MALListImporter().parse(data)
            let count = try await importEntries(result, service: service, coordinator: coordinator)
            state = .done(count: count)
        } catch {
            fail(error)
        }
    }

    private func importEntries(
        _ result: MALImportResult,
        service: ContentServicing,
        coordinator: LibrarySyncCoordinator
    ) async throws -> Int {
        switch result {
        case .anime(let entries):
            for (index, entry) in entries.enumerated() {
                state = .importing(current: index, total: entries.count, kind: .anime)
                let anime = (try? await service.animeDetails(id: entry.malId)) ?? Self.makeAnime(from: entry)
                try coordinator.upsertAnime(
                    anime: anime,
                    status: entry.status,
                    progress: entry.watchedEpisodes,
                    personalScore: entry.personalScore,
                    notes: nil,
                    startDate: entry.startDate,
                    finishDate: entry.finishDate
                )
                if index < entries.count - 1 {
                    try? await Task.sleep(for: Self.requestSpacing)
                }
            }
            return entries.count
        case .manga(let entries):
            for (index, entry) in entries.enumerated() {
                state = .importing(current: index, total: entries.count, kind: .manga)
                let manga = (try? await service.mangaDetails(id: entry.malId)) ?? Self.makeManga(from: entry)
                try coordinator.upsertManga(
                    manga: manga,
                    status: entry.status,
                    chaptersRead: entry.chaptersRead,
                    volumesRead: entry.volumesRead,
                    personalScore: entry.personalScore,
                    notes: nil,
                    startDate: entry.startDate,
                    finishDate: entry.finishDate
                )
                if index < entries.count - 1 {
                    try? await Task.sleep(for: Self.requestSpacing)
                }
            }
            return entries.count
        }
    }

    /// Fallback sin imagen/géneros si la petición de red falla (ID retirado,
    /// límite de tasa puntual...) — una sola entrada problemática nunca
    /// aborta el resto del import.
    private static func makeAnime(from entry: MALAnimeImportEntry) -> Anime {
        Anime(
            malId: entry.malId,
            url: nil,
            images: MediaImages(jpg: ImageSet(imageUrl: nil, smallImageUrl: nil, largeImageUrl: nil), webp: nil),
            title: entry.title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            episodes: entry.totalEpisodes,
            status: nil,
            airing: nil,
            synopsis: nil,
            score: nil,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            year: nil,
            season: nil,
            genres: nil,
            studios: nil,
            aired: nil,
            relations: nil
        )
    }

    private static func makeManga(from entry: MALMangaImportEntry) -> Manga {
        Manga(
            malId: entry.malId,
            url: nil,
            images: MediaImages(jpg: ImageSet(imageUrl: nil, smallImageUrl: nil, largeImageUrl: nil), webp: nil),
            title: entry.title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: nil,
            chapters: entry.totalChapters,
            volumes: entry.totalVolumes,
            status: nil,
            publishing: nil,
            synopsis: nil,
            score: nil,
            scoredBy: nil,
            rank: nil,
            popularity: nil,
            members: nil,
            favorites: nil,
            genres: nil,
            published: nil,
            relations: nil
        )
    }
}
