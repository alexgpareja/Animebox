//
//  APIService.swift
//  Animebox
//

import Foundation

protocol APIServicing: Sendable {
    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T
}

nonisolated struct APIService: APIServicing {
    let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        var request = URLRequest(url: url)
        request.timeoutInterval = APIConfig.requestTimeout
        request.cachePolicy = .returnCacheDataElseLoad
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(for: request)
        } catch is CancellationError {
            throw NetworkError.cancelled
        } catch let urlError as URLError where urlError.code == .cancelled {
            throw NetworkError.cancelled
        } catch {
            throw NetworkError.transport(error.localizedDescription)
        }

        guard let http = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        switch http.statusCode {
        case 200..<300:
            do {
                let decoder = JSONDecoder()
                return try decoder.decode(T.self, from: data)
            } catch {
                throw NetworkError.decodingFailed
            }
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(http.statusCode)
        }
    }
}
