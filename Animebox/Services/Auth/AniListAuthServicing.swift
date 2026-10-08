//
//  AniListAuthServicing.swift
//  Animebox
//

import AuthenticationServices
import Foundation
import UIKit

protocol AniListAuthServicing: Sendable {
    func signIn() async throws -> AniListTokenSet
}

enum AniListAuthError: LocalizedError {
    case cancelled
    case invalidCallback
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .cancelled:
            AppLanguage.current.string("Inicio de sesión cancelado.")
        case .invalidCallback:
            AppLanguage.current.string("AniList no devolvió un token de acceso válido.")
        case .notSignedIn:
            AppLanguage.current.string("No has iniciado sesión con AniList.")
        }
    }
}

/// Orquesta el Implicit Grant de AniList: sin PKCE, sin `client_secret`, sin
/// intercambio de código — el token llega directo en el **fragmento** de la
/// URL de retorno (`#access_token=...&expires_in=...`), no en la query, así
/// que no se puede usar `URLComponents.queryItems` como con MAL. Mucho más
/// corto que `MALAuthService`: no hay `refresh()`, AniList no lo soporta.
@MainActor
final class AniListAuthService: NSObject, AniListAuthServicing, ASWebAuthenticationPresentationContextProviding {
    func signIn() async throws -> AniListTokenSet {
        let callbackURL = try await presentAuthorizationSession(url: authorizationURL())
        return try extractTokenSet(from: callbackURL)
    }

    private func authorizationURL() -> URL {
        var components = URLComponents(url: AniListConfig.authorizeURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: AniListConfig.clientID),
            URLQueryItem(name: "response_type", value: "token")
        ]
        return components.url!
    }

    private func presentAuthorizationSession(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: AniListConfig.redirectURIScheme
            ) { callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: AniListAuthError.cancelled)
                } else {
                    continuation.resume(throwing: error ?? AniListAuthError.invalidCallback)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    /// El fragmento no es una query string estándar en `URLComponents`, así
    /// que se parsea a mano el `#clave=valor&clave=valor` que AniList añade
    /// tras la redirección.
    private func extractTokenSet(from callbackURL: URL) throws -> AniListTokenSet {
        guard let fragment = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.fragment else {
            throw AniListAuthError.invalidCallback
        }
        var values: [String: String] = [:]
        for pair in fragment.split(separator: "&") {
            let parts = pair.split(separator: "=", maxSplits: 1)
            guard parts.count == 2 else { continue }
            values[String(parts[0])] = String(parts[1]).removingPercentEncoding
        }
        guard let accessToken = values["access_token"],
              let expiresInString = values["expires_in"],
              let expiresIn = TimeInterval(expiresInString) else {
            throw AniListAuthError.invalidCallback
        }
        return AniListTokenSet(accessToken: accessToken, expiresAt: Date().addingTimeInterval(expiresIn))
    }

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first ?? ASPresentationAnchor()
        }
    }
}
