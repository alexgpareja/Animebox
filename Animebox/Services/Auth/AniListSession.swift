//
//  AniListSession.swift
//  Animebox
//

import Foundation

/// Mismo rol que `MALSession` pero sin lógica de refresh — AniList no
/// soporta refresh tokens (el access token dura 1 año). Si caducó, la
/// sesión se cierra directamente en vez de intentar renovarla.
@Observable
@MainActor
final class AniListSession {
    private(set) var isSignedIn: Bool
    private(set) var username: String?
    var lastSyncError: String?

    private let tokenStore: AniListTokenStoring
    private let authService: AniListAuthServicing

    init(tokenStore: AniListTokenStoring = KeychainAniListTokenStore(), authService: AniListAuthServicing? = nil) {
        self.tokenStore = tokenStore
        self.authService = authService ?? AniListAuthService()
        self.isSignedIn = tokenStore.load() != nil
    }

    func signIn() async throws {
        let tokens = try await authService.signIn()
        try tokenStore.save(tokens)
        isSignedIn = true
        lastSyncError = nil
    }

    func signOut() {
        try? tokenStore.clear()
        isSignedIn = false
        username = nil
    }

    func setUsername(_ name: String) {
        username = name
    }

    /// A diferencia de `MALSession.accessToken()`, no hay refresh que
    /// intentar — un token caducado simplemente cierra la sesión.
    func accessToken() throws -> String {
        guard let tokens = tokenStore.load(), !tokens.isExpired else {
            isSignedIn = false
            throw AniListAuthError.notSignedIn
        }
        return tokens.accessToken
    }
}
