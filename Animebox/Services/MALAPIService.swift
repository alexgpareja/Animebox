//
//  MALAPIService.swift
//  Animebox
//

import Foundation

/// `APIServicing` autenticado contra la API oficial de MAL: inyecta
/// `Authorization: Bearer` internamente (cero cambios en el protocolo
/// compartido, cero riesgo para el camino de Jikan) y reintenta una vez tras
/// un 401 refrescando el token vía `MALSession`. También expone `send(...)`,
/// fuera del protocolo `APIServicing` (que es solo GET), para las escrituras
/// de sync de biblioteca (`PATCH`/`DELETE`).
@MainActor
struct MALAPIService: APIServicing {
    let session: URLSession
    let malSession: MALSession

    init(session: URLSession = .shared, malSession: MALSession) {
        self.session = session
        self.malSession = malSession
    }

    func get<T: Decodable & Sendable>(_ url: URL, as type: T.Type) async throws -> T {
        try await perform(request: authorizedRequest(url: url, method: "GET"), as: type)
    }

    @discardableResult
    func send(url: URL, method: String, formBody: [String: String] = [:]) async throws -> Data {
        var request = try await authorizedRequest(url: url, method: method)
        if !formBody.isEmpty {
            request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpBody = formBody
                .map { "\($0.key)=\($0.value.addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "")" }
                .joined(separator: "&")
                .data(using: .utf8)
        }
        return try await performRaw(request: request, allowRetry: true)
    }

    private func authorizedRequest(url: URL, method: String) async throws -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = APIConfig.requestTimeout
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let token = try await malSession.accessToken()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }

    private func perform<T: Decodable & Sendable>(request: URLRequest, as type: T.Type) async throws -> T {
        let data = try await performRaw(request: request, allowRetry: true)
        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingFailed
        }
    }

    private func performRaw(request: URLRequest, allowRetry: Bool) async throws -> Data {
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
            return data
        case 401 where allowRetry:
            // El token pudo caducar entre el chequeo de accessToken() y la
            // petición real, o ser inválido del lado del servidor — un
            // refresh forzado y un único reintento cubre ambos casos.
            var retried = request
            let token = try await malSession.forceRefreshAccessToken()
            retried.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            return try await performRaw(request: retried, allowRetry: false)
        case 429:
            throw NetworkError.rateLimited
        default:
            throw NetworkError.httpError(http.statusCode)
        }
    }
}
