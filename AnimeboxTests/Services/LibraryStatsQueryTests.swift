//
//  LibraryStatsQueryTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@Suite("LibraryStatsQuery")
struct LibraryStatsQueryTests {
    @Test("Suma episodios, capítulos y calcula tiempo estimado")
    func totalsAndEstimatedTime() {
        let anime = [
            LibraryEntry(malId: 1, title: "A", progress: 10),
            LibraryEntry(malId: 2, title: "B", progress: 5),
        ]
        let manga = [
            MangaLibraryEntry(malId: 1, title: "C", chaptersRead: 20),
        ]

        let stats = LibraryStatsQuery.makeStats(animeEntries: anime, mangaEntries: manga)

        #expect(stats.totalAnimeEntries == 2)
        #expect(stats.totalMangaEntries == 1)
        #expect(stats.totalEpisodesWatched == 15)
        #expect(stats.totalChaptersRead == 20)
        #expect(stats.estimatedWatchTimeMinutes == 15 * LibraryStatsQuery.averageEpisodeMinutes)
    }

    @Test("Promedia solo las entradas con valoración personal puesta")
    func averageScoreIgnoresMissingScores() {
        let anime = [
            LibraryEntry(malId: 1, title: "A", personalScore: 8),
            LibraryEntry(malId: 2, title: "B", personalScore: 6),
            LibraryEntry(malId: 3, title: "C", personalScore: nil),
        ]

        let stats = LibraryStatsQuery.makeStats(animeEntries: anime, mangaEntries: [])

        #expect(stats.averageAnimeScore == 7)
        #expect(stats.averageMangaScore == nil)
    }

    @Test("Cuenta entradas por estado")
    func statusCounts() {
        let anime = [
            LibraryEntry(malId: 1, title: "A", status: .watching),
            LibraryEntry(malId: 2, title: "B", status: .watching),
            LibraryEntry(malId: 3, title: "C", status: .completed),
        ]

        let stats = LibraryStatsQuery.makeStats(animeEntries: anime, mangaEntries: [])

        #expect(stats.animeStatusCounts[.watching] == 2)
        #expect(stats.animeStatusCounts[.completed] == 1)
        #expect(stats.animeStatusCounts[.dropped] == nil)
    }

    @Test("Desglose de géneros ordenado de mayor a menor frecuencia")
    func genreBreakdownSortedByCount() {
        let anime = [
            LibraryEntry(malId: 1, title: "A", genreNames: ["Action", "Comedy"]),
            LibraryEntry(malId: 2, title: "B", genreNames: ["Action"]),
            LibraryEntry(malId: 3, title: "C", genreNames: nil),
        ]

        let stats = LibraryStatsQuery.makeStats(animeEntries: anime, mangaEntries: [])

        #expect(stats.topAnimeGenres.first?.name == "Action")
        #expect(stats.topAnimeGenres.first?.count == 2)
        #expect(stats.topAnimeGenres.count == 2)
    }
}
