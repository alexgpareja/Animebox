//
//  MALImportError.swift
//  Animebox
//

import Foundation

nonisolated enum MALImportError: LocalizedError, Sendable, Equatable {
    case invalidXML
    case emptyList

    var errorDescription: String? {
        switch self {
        case .invalidXML:
            String(localized: "El fichero no parece ser una exportación válida de MyAnimeList.")
        case .emptyList:
            String(localized: "El fichero no contiene ninguna entrada de anime o manga.")
        }
    }
}
