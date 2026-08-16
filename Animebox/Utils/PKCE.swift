//
//  PKCE.swift
//  Animebox
//

import Foundation

/// Genera el par verifier/challenge para el flujo OAuth2 con PKCE. MAL solo
/// soporta `code_challenge_method=plain` (no S256), así que el challenge es
/// literalmente el mismo verifier — ver https://myanimelist.net/apiconfig/references/authorization.
nonisolated enum PKCE {
    static func makeCodeVerifier(length: Int = 128) -> String {
        let allowed = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        return String((0..<length).map { _ in allowed.randomElement()! })
    }

    static func codeChallenge(for verifier: String) -> String {
        verifier
    }

    static func makeState() -> String {
        UUID().uuidString
    }
}
