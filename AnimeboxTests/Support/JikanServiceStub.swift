//
//  JikanServiceStub.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

struct JikanServiceStub: JikanServicing {
    let top: [Anime]
    let season: [Anime]
    let searchResults: [Anime]
    let details: Anime?
    let genres: [NamedEntity]
    let error: NetworkError?

    init(
        top: [Anime] = [],
        season: [Anime] = [],
        searchResults: [Anime] = [],
        details: Anime? = nil,
        genres: [NamedEntity] = [],
        error: NetworkError? = nil
    ) {
        self.top = top
        self.season = season
        self.searchResults = searchResults
        self.details = details
        self.genres = genres
        self.error = error
    }

    func topAnime(limit: Int) async throws -> [Anime] {
        if let error { throw error }
        return Array(top.prefix(limit))
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        if let error { throw error }
        return Array(season.prefix(limit))
    }

    func searchAnime(query: String?, status: String?, genres: [Int]?, limit: Int) async throws -> [Anime] {
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
}
