//
//  MALImportEntry.swift
//  Animebox
//

import Foundation

nonisolated struct MALAnimeImportEntry: Sendable, Equatable {
    let malId: Int
    let title: String
    let totalEpisodes: Int?
    let watchedEpisodes: Int
    let personalScore: Int?
    let status: LibraryStatus
    let startDate: Date?
    let finishDate: Date?
}

nonisolated struct MALMangaImportEntry: Sendable, Equatable {
    let malId: Int
    let title: String
    let totalChapters: Int?
    let totalVolumes: Int?
    let chaptersRead: Int
    let volumesRead: Int
    let personalScore: Int?
    let status: MangaStatus
    let startDate: Date?
    let finishDate: Date?
}

nonisolated enum MALImportResult: Sendable, Equatable {
    case anime([MALAnimeImportEntry])
    case manga([MALMangaImportEntry])

    var count: Int {
        switch self {
        case .anime(let entries): entries.count
        case .manga(let entries): entries.count
        }
    }
}
