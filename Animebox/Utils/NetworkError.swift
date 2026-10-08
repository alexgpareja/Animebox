//
//  NetworkError.swift
//  Animebox
//

import Foundation

enum NetworkError: LocalizedError, Equatable {
    case invalidURL
    case invalidResponse
    case httpError(Int)
    case decodingFailed
    case transport(String)
    case rateLimited
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            AppLanguage.current.string("La URL solicitada no es válida.")
        case .invalidResponse:
            AppLanguage.current.string("Respuesta inesperada del servidor.")
        case .httpError(let code):
            String(format: AppLanguage.current.string("Error del servidor (%lld)."), code)
        case .decodingFailed:
            AppLanguage.current.string("No pudimos procesar la respuesta del servidor.")
        case .transport(let message):
            message
        case .rateLimited:
            AppLanguage.current.string("Has alcanzado el límite de peticiones. Inténtalo de nuevo en unos segundos.")
        case .cancelled:
            AppLanguage.current.string("Petición cancelada.")
        }
    }
}
