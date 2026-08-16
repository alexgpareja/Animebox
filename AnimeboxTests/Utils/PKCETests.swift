//
//  PKCETests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

@Suite("PKCE")
struct PKCETests {
    @Test("El verifier generado tiene una longitud válida según RFC 7636 (43-128)")
    func verifierHasValidLength() {
        let verifier = PKCE.makeCodeVerifier()
        #expect(verifier.count >= 43 && verifier.count <= 128)
    }

    @Test("El verifier solo usa el alfabeto unreserved permitido")
    func verifierUsesAllowedCharacters() {
        let allowed = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~")
        let verifier = PKCE.makeCodeVerifier()
        #expect(verifier.allSatisfy { allowed.contains($0) })
    }

    @Test("El challenge es igual al verifier — MAL solo soporta code_challenge_method=plain")
    func challengeEqualsVerifier() {
        let verifier = PKCE.makeCodeVerifier()
        #expect(PKCE.codeChallenge(for: verifier) == verifier)
    }

    @Test("Dos verifiers generados no coinciden")
    func verifiersAreRandom() {
        #expect(PKCE.makeCodeVerifier() != PKCE.makeCodeVerifier())
    }
}
