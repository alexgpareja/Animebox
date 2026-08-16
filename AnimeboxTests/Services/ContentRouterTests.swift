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
    @Test("Invitado (sin sesión) reenvía a Jikan")
    func guestRoutesToJikan() async throws {
        let jikanSpy = ContentServiceSpy()
        let malSpy = ContentServiceSpy()
        let session = MALSession(tokenStore: InMemoryTokenStore())
        let router = ContentRouter(session: session, jikan: jikanSpy, mal: malSpy)

        _ = try await router.topAnime(limit: 5)

        #expect(jikanSpy.topAnimeCallCount == 1)
        #expect(malSpy.topAnimeCallCount == 0)
    }

    @Test("Con sesión iniciada reenvía a MAL")
    func signedInRoutesToMAL() async throws {
        let jikanSpy = ContentServiceSpy()
        let malSpy = ContentServiceSpy()
        let tokenStore = InMemoryTokenStore()
        tokenStore.stored = MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))
        let session = MALSession(tokenStore: tokenStore)
        #expect(session.isSignedIn)
        let router = ContentRouter(session: session, jikan: jikanSpy, mal: malSpy)

        _ = try await router.searchAnime(
            query: "x", status: nil, genres: nil, type: nil, rating: nil, startDate: nil, endDate: nil, limit: 5
        )

        #expect(malSpy.searchAnimeCallCount == 1)
        #expect(jikanSpy.searchAnimeCallCount == 0)
    }
}
