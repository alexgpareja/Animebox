//
//  ContentRouter.swift
//  Animebox
//

import Foundation

/// Reenvía cada método de `ContentServicing` a Jikan (invitado) o a MAL
/// (sesión iniciada), comprobando `session.isSignedIn` **en cada llamada**,
/// no al construirse — así un login hecho en otra pestaña cambia de
/// inmediato lo que devuelve Buscar/Inicio, sin recablear nada reactivo. Los
/// ViewModels no necesitan saber que este router existe: siguen recibiendo
/// un `ContentServicing` cualquiera, exactamente como con `JikanService` solo.
struct ContentRouter: ContentServicing {
    let jikan: ContentServicing
    let mal: ContentServicing
    let session: MALSession

    init(session: MALSession, jikan: ContentServicing = JikanService(), mal: ContentServicing? = nil) {
        self.session = session
        self.jikan = jikan
        self.mal = mal ?? MALContentService(malSession: session)
    }

    func topAnime(limit: Int) async throws -> [Anime] {
        try await session.isSignedIn ? mal.topAnime(limit: limit) : jikan.topAnime(limit: limit)
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        try await session.isSignedIn ? mal.currentSeason(limit: limit) : jikan.currentSeason(limit: limit)
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
        let route = session.isSignedIn ? mal : jikan
        return try await route.searchAnime(
            query: query, status: status, genres: genres, type: type,
            rating: rating, startDate: startDate, endDate: endDate, limit: limit
        )
    }

    func animeDetails(id: Int) async throws -> Anime {
        try await session.isSignedIn ? mal.animeDetails(id: id) : jikan.animeDetails(id: id)
    }

    func animeGenres() async throws -> [NamedEntity] {
        try await session.isSignedIn ? mal.animeGenres() : jikan.animeGenres()
    }

    func animeThemes() async throws -> [NamedEntity] {
        try await session.isSignedIn ? mal.animeThemes() : jikan.animeThemes()
    }

    func topManga(limit: Int) async throws -> [Manga] {
        try await session.isSignedIn ? mal.topManga(limit: limit) : jikan.topManga(limit: limit)
    }

    func currentlyPublishingManga(limit: Int) async throws -> [Manga] {
        try await session.isSignedIn
            ? mal.currentlyPublishingManga(limit: limit)
            : jikan.currentlyPublishingManga(limit: limit)
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
        let route = session.isSignedIn ? mal : jikan
        return try await route.searchManga(
            query: query, status: status, genres: genres, type: type,
            startDate: startDate, endDate: endDate, limit: limit
        )
    }

    func mangaDetails(id: Int) async throws -> Manga {
        try await session.isSignedIn ? mal.mangaDetails(id: id) : jikan.mangaDetails(id: id)
    }

    func mangaGenres() async throws -> [NamedEntity] {
        try await session.isSignedIn ? mal.mangaGenres() : jikan.mangaGenres()
    }

    func mangaThemes() async throws -> [NamedEntity] {
        try await session.isSignedIn ? mal.mangaThemes() : jikan.mangaThemes()
    }
}
