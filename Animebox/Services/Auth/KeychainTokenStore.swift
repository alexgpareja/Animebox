//
//  KeychainTokenStore.swift
//  Animebox
//

import Foundation
import Security

nonisolated struct MALTokenSet: Codable, Sendable, Equatable {
    let accessToken: String
    let refreshToken: String
    let expiresAt: Date

    var isExpired: Bool {
        expiresAt.timeIntervalSinceNow < 60
    }
}

protocol TokenStoring: Sendable {
    func save(_ tokens: MALTokenSet) throws
    func load() -> MALTokenSet?
    func clear() throws
}

/// Guarda los tokens de MAL en el Keychain (framework Security, sin
/// dependencias de terceros). `.afterFirstUnlock` para que un refresh
/// pueda intentarse justo tras el arranque sin esperar a un desbloqueo nuevo.
nonisolated struct KeychainTokenStore: TokenStoring {
    private let service = "com.alexdev.animebox.mal"
    private let account = "oauthTokens"

    func save(_ tokens: MALTokenSet) throws {
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

    func load() -> MALTokenSet? {
        var query = baseQuery
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return try? JSONDecoder().decode(MALTokenSet.self, from: data)
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

enum KeychainError: Error {
    case unhandled(OSStatus)
}
