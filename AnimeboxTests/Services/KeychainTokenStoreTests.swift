//
//  KeychainTokenStoreTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

/// `.serialized`: los tests comparten el mismo item real del Keychain
/// (mismo `service`/`account`, a propósito — solo hay una sesión de MAL por
/// app), así que ejecutarlos en paralelo los hace competir entre sí.
@Suite("KeychainTokenStore", .serialized)
struct KeychainTokenStoreTests {
    private let store = KeychainTokenStore()

    @Test("Guardar y leer devuelve los mismos tokens")
    func saveAndLoadRoundTrips() throws {
        let tokens = MALTokenSet(accessToken: "access-1", refreshToken: "refresh-1", expiresAt: .now.addingTimeInterval(3600))
        try store.save(tokens)
        defer { try? store.clear() }

        #expect(store.load() == tokens)
    }

    @Test("Guardar dos veces sustituye el valor anterior, no duplica")
    func saveTwiceOverwrites() throws {
        try store.save(MALTokenSet(accessToken: "first", refreshToken: "r1", expiresAt: .now))
        let second = MALTokenSet(accessToken: "second", refreshToken: "r2", expiresAt: .now.addingTimeInterval(60))
        try store.save(second)
        defer { try? store.clear() }

        #expect(store.load() == second)
    }

    @Test("clear() borra los tokens guardados")
    func clearRemovesTokens() throws {
        try store.save(MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now))
        try store.clear()

        #expect(store.load() == nil)
    }

    @Test("isExpired es true cuando quedan menos de 60s")
    func isExpiredRespectsMargin() {
        let almostExpired = MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(30))
        let fresh = MALTokenSet(accessToken: "a", refreshToken: "b", expiresAt: .now.addingTimeInterval(3600))

        #expect(almostExpired.isExpired)
        #expect(!fresh.isExpired)
    }
}
