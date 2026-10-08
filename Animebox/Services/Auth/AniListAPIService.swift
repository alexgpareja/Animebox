//
//  AniListAPIService.swift
//  Animebox
//

import Foundation

/// Ejecutor de bajo nivel para el único endpoint POST de AniList — no hay
/// URLs por recurso como en REST, cada llamada manda `{query, variables}`
/// y decodifica su propio envoltorio (`AniListPageResponse`, `AniListMediaResponse`...).
/// Sin reintento tras 401 (a diferencia de `MALAPIService`): AniList no
/// soporta refresh, un 401 significa sesión inválida sin más — se cierra
/// directamente.
@MainActor
struct AniListAPIService {
    let session: URLSession
    let aniListSession: AniListSession?

    init(session: URLSession = .shared, aniListSession: AniListSession? = nil) {
        self.session = session
        self.aniListSession = aniListSession
    }

    func graphQL<T: Decodable & Sendable>(
        query: String,
        variables: [String: Any] = [:],
        authenticated: Bool = false,
        as type: T.Type
    ) async throws -> T {
        var request = URLRequest(url: AniListConfig.graphQLURL)
        request.httpMethod = "POST"
        request.timeoutInterval = APIConfig.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if authenticated {
            guard let aniListSession else { throw AniListAuthError.notSignedIn }
            let token = try aniListSession.accessToken()
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        request.httpBody = try JSONSerialization.data(withJSONObject: ["query": query, "variables": variables])

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
            guard let envelope = try? JSONDecoder().decode(AniListGraphQLEnvelope<T>.self, from: data),
                  let payload = envelope.data else {
                throw NetworkError.decodingFailed
            }
            return payload
        case 401:
            aniListSession?.signOut()
            throw AniListAuthError.notSignedIn
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(http.statusCode)
        }
    }
}
