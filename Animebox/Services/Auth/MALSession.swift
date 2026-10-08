//
//  MALSession.swift
//  Animebox
//

import Foundation

/// Estado de sesión compartido, inyectado vía `.environment` desde
/// `AnimeboxApp` — una única instancia observada por las vistas (para mostrar
/// UI de cuenta) y consultada por `ContentRouter`/`LibrarySyncCoordinator` en
/// cada llamada (no cacheada), así un login en una pestaña afecta al resto
/// de inmediato.
@Observable
@MainActor
final class MALSession {
    private(set) var isSignedIn: Bool
    private(set) var username: String?
    var lastSyncError: String?

    private let tokenStore: TokenStoring
    private let authService: MALAuthServicing
    private var refreshTask: Task<String, Error>?

    init(tokenStore: TokenStoring = KeychainTokenStore(), authService: MALAuthServicing? = nil) {
        let authService = authService ?? MALAuthService()
        self.tokenStore = tokenStore
        self.authService = authService
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

    /// Token de acceso válido para la siguiente petición autenticada,
    /// refrescando primero si está a punto de caducar (margen de 60s, ver
    /// `MALTokenSet.isExpired`). Si el refresh también falla (refresh token
    /// caducado tras un mes), cierra la sesión localmente — no es un error
    /// de red, es que hace falta volver a iniciar sesión.
    func accessToken() async throws -> String {
        guard let tokens = tokenStore.load() else {
            isSignedIn = false
            throw MALAuthError.notSignedIn
        }
        guard tokens.isExpired else { return tokens.accessToken }
        return try await refreshedAccessToken(currentRefreshToken: tokens.refreshToken)
    }

    /// Fuerza un refresh incondicional, ignorando si el token guardado
    /// todavía parecía válido — lo usa `MALAPIService` cuando un 401 llega
    /// pese a que el chequeo local de expiración no lo anticipaba.
    func forceRefreshAccessToken() async throws -> String {
        guard let tokens = tokenStore.load() else {
            isSignedIn = false
            throw MALAuthError.notSignedIn
        }
        return try await refreshedAccessToken(currentRefreshToken: tokens.refreshToken)
    }

    /// "Single-flight": si ya hay un refresh en curso, todas las llamadas
    /// concurrentes esperan al mismo en vez de disparar cada una el suyo con
    /// el mismo refresh token — MAL rota el refresh token en cada uso, así
    /// que refrescos paralelos duplicados harían fallar a todos menos al
    /// primero y cerrarían la sesión de golpe.
    private func refreshedAccessToken(currentRefreshToken: String) async throws -> String {
        if let refreshTask { return try await refreshTask.value }
        let task = Task<String, Error> {
            do {
                let refreshed = try await authService.refresh(currentRefreshToken)
                try tokenStore.save(refreshed)
                return refreshed.accessToken
            } catch {
                signOut()
                throw error
            }
        }
        refreshTask = task
        defer { refreshTask = nil }
        return try await task.value
    }
}
