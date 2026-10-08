//
//  ContentRouterTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@MainActor
@Suite("ContentRouter")
struct ContentRouterTests {
    private func makeAccount(malSignedIn: Bool = false, aniListSignedIn: Bool = false) -> LinkedAccount {
        let malTokenStore = InMemoryTokenStore()
        if malSignedIn {
            malTokenStore.stored = MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))
        }
        let aniListTokenStore = InMemoryAniListTokenStore()
        if aniListSignedIn {
            aniListTokenStore.stored = AniListTokenSet(accessToken: "x", expiresAt: .now.addingTimeInterval(3600))
        }
        return LinkedAccount(
            mal: MALSession(tokenStore: malTokenStore),
            aniList: AniListSession(tokenStore: aniListTokenStore)
        )
    }

    @Test("Invitado (sin sesión) reenvía a Tenrai")
    func guestRoutesToJikan() async throws {
        let jikanSpy = ContentServiceSpy()
        let malSpy = ContentServiceSpy()
        let aniListSpy = ContentServiceSpy()
        let account = makeAccount()
        let router = ContentRouter(account: account, jikan: jikanSpy, mal: malSpy, aniList: aniListSpy)

        _ = try await router.topAnime(limit: 5)

        #expect(jikanSpy.topAnimeCallCount == 1)
        #expect(malSpy.topAnimeCallCount == 0)
        #expect(aniListSpy.topAnimeCallCount == 0)
    }

    @Test("Con sesión de MAL iniciada reenvía a MAL")
    func signedInRoutesToMAL() async throws {
        let jikanSpy = ContentServiceSpy()
        let malSpy = ContentServiceSpy()
        let aniListSpy = ContentServiceSpy()
        let account = makeAccount(malSignedIn: true)
        #expect(account.activeProvider == .mal)
        let router = ContentRouter(account: account, jikan: jikanSpy, mal: malSpy, aniList: aniListSpy)

        _ = try await router.searchAnime(
            query: "x", status: nil, genres: nil, type: nil, rating: nil, startDate: nil, endDate: nil, limit: 5
        )

        #expect(malSpy.searchAnimeCallCount == 1)
        #expect(jikanSpy.searchAnimeCallCount == 0)
        #expect(aniListSpy.searchAnimeCallCount == 0)
    }

    @Test("Con sesión de AniList iniciada reenvía a AniList")
    func signedInRoutesToAniList() async throws {
        let jikanSpy = ContentServiceSpy()
        let malSpy = ContentServiceSpy()
        let aniListSpy = ContentServiceSpy()
        let account = makeAccount(aniListSignedIn: true)
        #expect(account.activeProvider == .aniList)
        let router = ContentRouter(account: account, jikan: jikanSpy, mal: malSpy, aniList: aniListSpy)

        _ = try await router.topAnime(limit: 5)

        #expect(aniListSpy.topAnimeCallCount == 1)
        #expect(malSpy.topAnimeCallCount == 0)
        #expect(jikanSpy.topAnimeCallCount == 0)
    }
}
