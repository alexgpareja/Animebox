//
//  InMemoryTokenStore.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

/// `TokenStoring` en memoria — evita tocar el Keychain real en tests que no
/// necesitan probarlo específicamente (ver `KeychainTokenStoreTests` para eso).
final class InMemoryTokenStore: TokenStoring, @unchecked Sendable {
    var stored: MALTokenSet?

    init(stored: MALTokenSet? = nil) {
        self.stored = stored
    }

    func save(_ tokens: MALTokenSet) throws {
        stored = tokens
    }

    func load() -> MALTokenSet? {
        stored
    }

    func clear() throws {
        stored = nil
    }
}
