//
//  InMemoryAniListTokenStore.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

/// `AniListTokenStoring` en memoria — ver `InMemoryTokenStore`, mismo motivo.
final class InMemoryAniListTokenStore: AniListTokenStoring, @unchecked Sendable {
    var stored: AniListTokenSet?

    init(stored: AniListTokenSet? = nil) {
        self.stored = stored
    }

    func save(_ tokens: AniListTokenSet) throws {
        stored = tokens
    }

    func load() -> AniListTokenSet? {
        stored
    }

    func clear() throws {
        stored = nil
    }
}
