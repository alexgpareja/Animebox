//
//  ContentServiceSpy.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

/// Espía de `ContentServicing` — cuenta llamadas por método, para verificar
/// a qué implementación (Jikan/MAL) reenvía `ContentRouter` en cada caso.
@MainActor
final class ContentServiceSpy: ContentServicing {
    private(set) var topAnimeCallCount = 0
    private(set) var currentSeasonCallCount = 0
    private(set) var searchAnimeCallCount = 0
    private(set) var animeDetailsCallCount = 0
    private(set) var animeGenresCallCount = 0
    private(set) var animeThemesCallCount = 0
    private(set) var topMangaCallCount = 0
    private(set) var searchMangaCallCount = 0
    private(set) var mangaDetailsCallCount = 0
    private(set) var mangaGenresCallCount = 0
    private(set) var mangaThemesCallCount = 0

    func topAnime(limit: Int) async throws -> [Anime] {
        topAnimeCallCount += 1
        return []
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        currentSeasonCallCount += 1
        return []
    }

    func searchAnime(
        query: String?, status: String?, genres: [Int]?, type: String?,
        rating: String?, startDate: String?, endDate: String?, limit: Int
    ) async throws -> [Anime] {
        searchAnimeCallCount += 1
        return []
    }

    func animeDetails(id: Int) async throws -> Anime {
        animeDetailsCallCount += 1
        return .fixture(id: id)
    }

    func animeGenres() async throws -> [NamedEntity] {
        animeGenresCallCount += 1
        return []
    }

    func animeThemes() async throws -> [NamedEntity] {
        animeThemesCallCount += 1
        return []
    }

    func topManga(limit: Int) async throws -> [Manga] {
        topMangaCallCount += 1
        return []
    }

    private(set) var currentlyPublishingMangaCallCount = 0

    func currentlyPublishingManga(limit: Int) async throws -> [Manga] {
        currentlyPublishingMangaCallCount += 1
        return []
    }

    func searchManga(
        query: String?, status: String?, genres: [Int]?, type: String?,
        startDate: String?, endDate: String?, limit: Int
    ) async throws -> [Manga] {
        searchMangaCallCount += 1
        return []
    }

    func mangaDetails(id: Int) async throws -> Manga {
        mangaDetailsCallCount += 1
        return .fixture(id: id)
    }

    func mangaGenres() async throws -> [NamedEntity] {
        mangaGenresCallCount += 1
        return []
    }

    func mangaThemes() async throws -> [NamedEntity] {
        mangaThemesCallCount += 1
        return []
    }
}
