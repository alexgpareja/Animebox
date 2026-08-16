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
            String(localized: "La URL solicitada no es válida.")
        case .invalidResponse:
            String(localized: "Respuesta inesperada del servidor.")
        case .httpError(let code):
            String(localized: "Error del servidor (\(code)).")
        case .decodingFailed:
            String(localized: "No pudimos procesar la respuesta del servidor.")
        case .transport(let message):
            message
        case .rateLimited:
            String(localized: "Has alcanzado el límite de peticiones. Inténtalo de nuevo en unos segundos.")
        case .cancelled:
            String(localized: "Petición cancelada.")
        }
    }
}
