//
//  RecordingAPI.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

/// An APIServicing implementation that records every URL it is asked to fetch
/// and decodes the supplied payload as the requested type. Useful to verify
/// that JikanService builds the correct URLs.
actor RecordingAPI: APIServicing {
    private(set) var receivedURLs: [URL] = []
    let payload: Data

    init(payload: Data = Data()) {
        self.payload = payload
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        receivedURLs.append(url)
        return try JSONDecoder().decode(T.self, from: payload)
    }
}
