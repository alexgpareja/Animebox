//
//  JikanServiceStub.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

struct JikanServiceStub: ContentServicing {
    let top: [Anime]
    let season: [Anime]
    let searchResults: [Anime]
    let details: Anime?
    let genres: [NamedEntity]
    let themes: [NamedEntity]
    let error: NetworkError?

    let topMangaResults: [Manga]
    let currentlyPublishingResults: [Manga]
    let mangaSearchResults: [Manga]
    let mangaDetailsResult: Manga?
    let mangaGenreResults: [NamedEntity]
    let mangaThemeResults: [NamedEntity]

    init(
        top: [Anime] = [],
        season: [Anime] = [],
        searchResults: [Anime] = [],
        details: Anime? = nil,
        genres: [NamedEntity] = [],
        themes: [NamedEntity] = [],
        error: NetworkError? = nil,
        topMangaResults: [Manga] = [],
        currentlyPublishingResults: [Manga] = [],
        mangaSearchResults: [Manga] = [],
        mangaDetailsResult: Manga? = nil,
        mangaGenreResults: [NamedEntity] = [],
        mangaThemeResults: [NamedEntity] = []
    ) {
        self.top = top
        self.season = season
        self.searchResults = searchResults
        self.details = details
        self.genres = genres
        self.themes = themes
        self.error = error
        self.topMangaResults = topMangaResults
        self.currentlyPublishingResults = currentlyPublishingResults
        self.mangaSearchResults = mangaSearchResults
        self.mangaDetailsResult = mangaDetailsResult
        self.mangaGenreResults = mangaGenreResults
        self.mangaThemeResults = mangaThemeResults
    }

    func topAnime(limit: Int) async throws -> [Anime] {
        if let error { throw error }
        return Array(top.prefix(limit))
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        if let error { throw error }
        return Array(season.prefix(limit))
    }

    func searchAnime(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        rating: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Anime] {
        if let error { throw error }
        return Array(searchResults.prefix(limit))
    }

    func animeDetails(id: Int) async throws -> Anime {
        if let error { throw error }
        guard let details else { throw NetworkError.invalidResponse }
        return details
    }

    func animeGenres() async throws -> [NamedEntity] {
        if let error { throw error }
        return genres
    }

    func animeThemes() async throws -> [NamedEntity] {
        if let error { throw error }
        return themes
    }

    func topManga(limit: Int) async throws -> [Manga] {
        if let error { throw error }
        return Array(topMangaResults.prefix(limit))
    }

    func currentlyPublishingManga(limit: Int) async throws -> [Manga] {
        if let error { throw error }
        return Array(currentlyPublishingResults.prefix(limit))
    }

    func searchManga(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Manga] {
        if let error { throw error }
        return Array(mangaSearchResults.prefix(limit))
    }

    func mangaDetails(id: Int) async throws -> Manga {
        if let error { throw error }
        guard let mangaDetailsResult else { throw NetworkError.invalidResponse }
        return mangaDetailsResult
    }

    func mangaGenres() async throws -> [NamedEntity] {
        if let error { throw error }
        return mangaGenreResults
    }

    func mangaThemes() async throws -> [NamedEntity] {
        if let error { throw error }
        return mangaThemeResults
    }
}
