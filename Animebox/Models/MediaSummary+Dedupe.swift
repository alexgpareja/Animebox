//
//  MediaSummary+Dedupe.swift
//  Animebox
//

import Foundation

extension Array where Element: MediaSummary {
    /// Devuelve la colección sin duplicados por `malId`, preservando el orden.
    /// Jikan puede repetir el mismo elemento en respuestas de temporada o ranking,
    /// y SwiftUI ForEach con IDs duplicados pinta huecos vacíos.
    func dedupedByMalId() -> [Element] {
        var seen = Set<Int>()
        return filter { seen.insert($0.malId).inserted }
    }
}
