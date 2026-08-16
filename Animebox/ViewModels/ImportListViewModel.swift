//
//  ImportListViewModel.swift
//  Animebox
//

import Foundation
import Observation
import SwiftData

@Observable
final class ImportListViewModel {
    enum State: Equatable {
        case idle
        case parsed(MALImportResult)
        case importing
        case done(count: Int)
        case error(String)
    }

    private(set) var state: State = .idle

    func parse(data: Data) {
        do {
            let result = try MALListImporter().parse(data)
            state = .parsed(result)
        } catch {
            fail(error)
        }
    }

    func fail(_ error: Error) {
        let message = (error as? LocalizedError)?.errorDescription ?? error.localizedDescription
        state = .error(message)
    }

    func commitImport(context: ModelContext) async {
        guard case .parsed(let result) = state else { return }
        state = .importing
        await Task.yield()
        do {
            let count = try importEntries(result, context: context)
            state = .done(count: count)
        } catch {
            fail(error)
        }
    }

    private func importEntries(_ result: MALImportResult, context: ModelContext) throws -> Int {
        switch result {
        case .anime(let entries):
            let store = LibraryStore(context: context)
            for entry in entries {
                try store.upsert(
                    anime: Self.makeAnime(from: entry),
                    status: entry.status,
                    progress: entry.watchedEpisodes,
                    personalScore: entry.personalScore,
                    notes: nil,
                    startDate: entry.startDate,
                    finishDate: entry.finishDate
                )
            }
            return entries.count
        case .manga(let entries):
            let store = MangaStore(context: context)
            for entry in entries {
                try store.upsert(
                    manga: Self.makeManga(from: entry),
                    status: entry.status,
                    chaptersRead: entry.chaptersRead,
                    volumesRead: entry.volumesRead,
                    personalScore: entry.personalScore,
                    notes: nil,
                    startDate: entry.startDate,
                    finishDate: entry.finishDate
                )
            }
            return entries.count
        }
    }

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
            studios: nil
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
            genres: nil
        )
    }
}
