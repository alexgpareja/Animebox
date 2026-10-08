//
//  LibraryStatsQuery.swift
//  Animebox
//

import Foundation

struct GenreCount: Identifiable, Sendable, Equatable {
    let name: String
    let count: Int
    var id: String { name }
}

struct LibraryStats: Sendable, Equatable {
    var totalAnimeEntries = 0
    var totalMangaEntries = 0
    var totalEpisodesWatched = 0
    var totalChaptersRead = 0
    var estimatedWatchTimeMinutes = 0
    var averageAnimeScore: Double?
    var averageMangaScore: Double?
    var animeStatusCounts: [LibraryStatus: Int] = [:]
    var mangaStatusCounts: [MangaStatus: Int] = [:]
    var topAnimeGenres: [GenreCount] = []
    var topMangaGenres: [GenreCount] = []
}

enum LibraryStatsQuery {
    /// No hay duración real por anime en `LibraryEntry` — se usa la duración
    /// media de un episodio de TV como estimación, no un dato exacto.
    static let averageEpisodeMinutes = 24

    static func makeStats(animeEntries: [LibraryEntry], mangaEntries: [MangaLibraryEntry]) -> LibraryStats {
        var stats = LibraryStats()
        stats.totalAnimeEntries = animeEntries.count
        stats.totalMangaEntries = mangaEntries.count
        stats.totalEpisodesWatched = animeEntries.reduce(0) { $0 + $1.progress }
        stats.totalChaptersRead = mangaEntries.reduce(0) { $0 + $1.chaptersRead }
        stats.estimatedWatchTimeMinutes = stats.totalEpisodesWatched * averageEpisodeMinutes
        stats.averageAnimeScore = average(animeEntries.compactMap(\.personalScore))
        stats.averageMangaScore = average(mangaEntries.compactMap(\.personalScore))
        for entry in animeEntries { stats.animeStatusCounts[entry.status, default: 0] += 1 }
        for entry in mangaEntries { stats.mangaStatusCounts[entry.status, default: 0] += 1 }
        stats.topAnimeGenres = genreCounts(from: animeEntries.flatMap { $0.genreNames ?? [] })
        stats.topMangaGenres = genreCounts(from: mangaEntries.flatMap { $0.genreNames ?? [] })
        return stats
    }

    private static func average(_ scores: [Int]) -> Double? {
        guard !scores.isEmpty else { return nil }
        return Double(scores.reduce(0, +)) / Double(scores.count)
    }

    private static func genreCounts(from names: [String]) -> [GenreCount] {
        var counts: [String: Int] = [:]
        for name in names { counts[name, default: 0] += 1 }
        return counts
            .map { GenreCount(name: $0.key, count: $0.value) }
            .sorted { $0.count == $1.count ? $0.name < $1.name : $0.count > $1.count }
    }
}
