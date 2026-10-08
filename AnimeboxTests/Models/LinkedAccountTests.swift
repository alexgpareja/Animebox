//
//  LinkedAccountTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@MainActor
@Suite("LinkedAccount.libraryProvider")
struct LinkedAccountTests {
    private func makeAccount(malSignedIn: Bool = false, aniListSignedIn: Bool = false) -> LinkedAccount {
        let malStore = InMemoryTokenStore()
        if malSignedIn {
            malStore.stored = MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))
        }
        let aniListStore = InMemoryAniListTokenStore()
        if aniListSignedIn {
            aniListStore.stored = AniListTokenSet(accessToken: "x", expiresAt: .now.addingTimeInterval(3600))
        }
        return LinkedAccount(mal: MALSession(tokenStore: malStore), aniList: AniListSession(tokenStore: aniListStore))
    }

    @Test("Invitado muestra las entradas etiquetadas como MAL")
    func guestUsesMAL() {
        #expect(makeAccount().libraryProvider == .mal)
    }

    @Test("Con MAL activa muestra las de MAL")
    func malUsesMAL() {
        #expect(makeAccount(malSignedIn: true).libraryProvider == .mal)
    }

    @Test("Con AniList activa muestra solo las de AniList")
    func aniListUsesAniList() {
        #expect(makeAccount(aniListSignedIn: true).libraryProvider == .aniList)
    }
}
