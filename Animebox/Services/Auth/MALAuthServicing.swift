//
//  MALAuthServicing.swift
//  Animebox
//

import AuthenticationServices
import Foundation
import UIKit

protocol MALAuthServicing: Sendable {
    func signIn() async throws -> MALTokenSet
    func refresh(_ refreshToken: String) async throws -> MALTokenSet
}

enum MALAuthError: LocalizedError {
    case cancelled
    case invalidCallback
    case stateMismatch
    case tokenExchangeFailed
    case notSignedIn

    var errorDescription: String? {
        switch self {
        case .cancelled:
            String(localized: "Inicio de sesión cancelado.")
        case .invalidCallback:
            String(localized: "MyAnimeList no devolvió un código de autorización válido.")
        case .stateMismatch:
            String(localized: "La respuesta de MyAnimeList no coincide con la petición original.")
        case .tokenExchangeFailed:
            String(localized: "No se pudo completar el inicio de sesión con MyAnimeList.")
        case .notSignedIn:
            String(localized: "No has iniciado sesión con MyAnimeList.")
        }
    }
}

/// Orquesta el flujo OAuth2 + PKCE contra MyAnimeList: presenta el login en
/// `ASWebAuthenticationSession`, intercambia el código por tokens, y expone
/// `refresh` para renovarlos. No conoce el Keychain — `MALSession` es quien
/// decide cuándo llamar a `refresh` y dónde persistir el resultado.
@MainActor
final class MALAuthService: NSObject, MALAuthServicing, ASWebAuthenticationPresentationContextProviding {
    private let urlSession: URLSession

    init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    func signIn() async throws -> MALTokenSet {
        let verifier = PKCE.makeCodeVerifier()
        let challenge = PKCE.codeChallenge(for: verifier)
        let state = PKCE.makeState()

        let callbackURL = try await presentAuthorizationSession(
            url: authorizationURL(codeChallenge: challenge, state: state)
        )
        let code = try extractCode(from: callbackURL, expectedState: state)
        return try await exchangeCode(code, codeVerifier: verifier)
    }

    func refresh(_ refreshToken: String) async throws -> MALTokenSet {
        try await requestToken(formBody: withClientSecretIfPresent([
            "client_id": MALConfig.clientID,
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]))
    }

    private func authorizationURL(codeChallenge: String, state: String) -> URL {
        var components = URLComponents(url: MALConfig.authorizeURL, resolvingAgainstBaseURL: false)!
        components.queryItems = [
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "client_id", value: MALConfig.clientID),
            URLQueryItem(name: "code_challenge", value: codeChallenge),
            URLQueryItem(name: "code_challenge_method", value: "plain"),
            URLQueryItem(name: "state", value: state),
            URLQueryItem(name: "redirect_uri", value: MALConfig.redirectURI.absoluteString)
        ]
        return components.url!
    }

    private func presentAuthorizationSession(url: URL) async throws -> URL {
        try await withCheckedThrowingContinuation { continuation in
            let session = ASWebAuthenticationSession(
                url: url,
                callbackURLScheme: MALConfig.redirectURIScheme
            ) { callbackURL, error in
                if let callbackURL {
                    continuation.resume(returning: callbackURL)
                } else if let error = error as? ASWebAuthenticationSessionError, error.code == .canceledLogin {
                    continuation.resume(throwing: MALAuthError.cancelled)
                } else {
                    continuation.resume(throwing: error ?? MALAuthError.invalidCallback)
                }
            }
            session.presentationContextProvider = self
            session.prefersEphemeralWebBrowserSession = true
            session.start()
        }
    }

    private func extractCode(from callbackURL: URL, expectedState: String) throws -> String {
        let items = URLComponents(url: callbackURL, resolvingAgainstBaseURL: false)?.queryItems ?? []
        guard let code = items.first(where: { $0.name == "code" })?.value else {
            throw MALAuthError.invalidCallback
        }
        guard items.first(where: { $0.name == "state" })?.value == expectedState else {
            throw MALAuthError.stateMismatch
        }
        return code
    }

    private func exchangeCode(_ code: String, codeVerifier: String) async throws -> MALTokenSet {
        try await requestToken(formBody: withClientSecretIfPresent([
            "client_id": MALConfig.clientID,
            "grant_type": "authorization_code",
            "code": code,
            "code_verifier": codeVerifier,
            "redirect_uri": MALConfig.redirectURI.absoluteString
        ]))
    }

    /// Con tipo de app "iOS"/nativa, MAL solo emite Client ID — no hay
    /// `client_secret` que enviar (cliente público, PKCE por sí solo basta).
    /// Si en el futuro se registrara una app "Web" con secreto, se añadiría
    /// aquí sin tocar el resto del flujo.
    private func withClientSecretIfPresent(_ body: [String: String]) -> [String: String] {
        guard !MALConfig.clientSecret.isEmpty else { return body }
        var body = body
        body["client_secret"] = MALConfig.clientSecret
        return body
    }

    private func requestToken(formBody: [String: String]) async throws -> MALTokenSet {
        var request = URLRequest(url: MALConfig.tokenURL)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = formBody
            .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .urlQueryValueAllowed) ?? "")" }
            .joined(separator: "&")
            .data(using: .utf8)

        let (data, response) = try await urlSession.data(for: request)
        guard let http = response as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw MALAuthError.tokenExchangeFailed
        }
        let payload = try JSONDecoder().decode(MALTokenResponse.self, from: data)
        return MALTokenSet(
            accessToken: payload.accessToken,
            refreshToken: payload.refreshToken,
            expiresAt: Date().addingTimeInterval(TimeInterval(payload.expiresIn))
        )
    }

    nonisolated func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        MainActor.assumeIsolated {
            UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first ?? ASPresentationAnchor()
        }
    }
}

private struct MALTokenResponse: Decodable {
    let tokenType: String
    let expiresIn: Int
    let accessToken: String
    let refreshToken: String

    enum CodingKeys: String, CodingKey {
        case tokenType = "token_type"
        case expiresIn = "expires_in"
        case accessToken = "access_token"
        case refreshToken = "refresh_token"
    }
}

private extension CharacterSet {
    static let urlQueryValueAllowed: CharacterSet = {
        var allowed = CharacterSet.urlQueryAllowed
        allowed.remove(charactersIn: "+&=")
        return allowed
    }()
}
