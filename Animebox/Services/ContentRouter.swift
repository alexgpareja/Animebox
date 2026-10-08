//
//  ContentRouter.swift
//  Animebox
//

import Foundation

/// Reenvía cada método de `ContentServicing` a Tenrai (invitado), MAL o
/// AniList (según cuál esté activa), comprobando `account.activeProvider`
/// **en cada llamada**, no al construirse — así un login hecho en otra
/// pestaña cambia de inmediato lo que devuelve Buscar/Inicio, sin recablear
/// nada reactivo. Los ViewModels no necesitan saber que este router existe:
/// siguen recibiendo un `ContentServicing` cualquiera, exactamente como con
/// `JikanService` solo.
struct ContentRouter: ContentServicing {
    let jikan: ContentServicing
    let mal: ContentServicing
    let aniList: ContentServicing
    let account: LinkedAccount

    init(
        account: LinkedAccount,
        jikan: ContentServicing = JikanService(),
        mal: ContentServicing? = nil,
        aniList: ContentServicing? = nil
    ) {
        self.account = account
        self.jikan = jikan
        self.mal = mal ?? MALContentService(malSession: account.mal)
        self.aniList = aniList ?? AniListContentService(aniListSession: account.aniList)
    }

    private var active: ContentServicing {
        switch account.activeProvider {
        case .mal: mal
        case .aniList: aniList
        case nil: jikan
        }
    }

    func topAnime(limit: Int) async throws -> [Anime] {
        try await active.topAnime(limit: limit)
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        try await active.currentSeason(limit: limit)
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
        try await active.searchAnime(
            query: query, status: status, genres: genres, type: type,
            rating: rating, startDate: startDate, endDate: endDate, limit: limit
        )
    }

    func animeDetails(id: Int) async throws -> Anime {
        try await active.animeDetails(id: id)
    }

    func animeGenres() async throws -> [NamedEntity] {
        try await active.animeGenres()
    }

    func animeThemes() async throws -> [NamedEntity] {
        try await active.animeThemes()
    }

    func topManga(limit: Int) async throws -> [Manga] {
        try await active.topManga(limit: limit)
    }

    func currentlyPublishingManga(limit: Int) async throws -> [Manga] {
        try await active.currentlyPublishingManga(limit: limit)
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
        try await active.searchManga(
            query: query, status: status, genres: genres, type: type,
            startDate: startDate, endDate: endDate, limit: limit
        )
    }

    func mangaDetails(id: Int) async throws -> Manga {
        try await active.mangaDetails(id: id)
    }

    func mangaGenres() async throws -> [NamedEntity] {
        try await active.mangaGenres()
    }

    func mangaThemes() async throws -> [NamedEntity] {
        try await active.mangaThemes()
    }
}
