//
//  AniListTokenStore.swift
//  Animebox
//

import Foundation
import Security

/// A diferencia de `MALTokenSet`, no hay `refreshToken` — AniList no lo
/// soporta (ver `AniListSession`). Tipo separado en vez de forzar un campo
/// que no existe en un `MALTokenSet` compartido.
nonisolated struct AniListTokenSet: Codable, Sendable, Equatable {
    let accessToken: String
    let expiresAt: Date

    var isExpired: Bool {
        expiresAt.timeIntervalSinceNow < 60
    }
}

protocol AniListTokenStoring: Sendable {
    func save(_ tokens: AniListTokenSet) throws
    func load() -> AniListTokenSet?
    func clear() throws
}

/// Mismo mecanismo que `KeychainTokenStore` (Security framework, sin
/// dependencias de terceros) con un `service` distinto para no chocar con
/// los tokens de MAL en el mismo Keychain.
nonisolated struct KeychainAniListTokenStore: AniListTokenStoring {
    private let service = "com.alexdev.animebox.anilist"
    private let account = "oauthTokens"

    func save(_ tokens: AniListTokenSet) throws {
        let data = try JSONEncoder().encode(tokens)
        var query = baseQuery
        query[kSecValueData as String] = data
        query[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock

        let deleteStatus = SecItemDelete(baseQuery as CFDictionary)
        guard deleteStatus == errSecSuccess || deleteStatus == errSecItemNotFound else {
            throw KeychainError.unhandled(deleteStatus)
        }

        let addStatus = SecItemAdd(query as CFDictionary, nil)
        guard addStatus == errSecSuccess else {
            throw KeychainError.unhandled(addStatus)
        }
    }

    func load() -> AniListTokenSet? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(AniListTokenSet.self, from: data)
    }

    func clear() throws {
        let status = SecItemDelete(baseQuery as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unhandled(status)
        }
    }

    private var baseQuery: [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }
}
