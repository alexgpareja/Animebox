//
//  FailingAPI.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

/// An APIServicing implementation that always throws. Useful to prove a code path
/// short-circuits before any network call is attempted.
struct FailingAPI: APIServicing {
    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        throw NetworkError.invalidResponse
    }
}
