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
            "La URL solicitada no es válida."
        case .invalidResponse:
            "Respuesta inesperada del servidor."
        case .httpError(let code):
            "Error del servidor (\(code))."
        case .decodingFailed:
            "No pudimos procesar la respuesta del servidor."
        case .transport(let message):
            message
        case .rateLimited:
            "Has alcanzado el límite de peticiones. Inténtalo de nuevo en unos segundos."
        case .cancelled:
            "Petición cancelada."
        }
    }
}
