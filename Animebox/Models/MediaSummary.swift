//
//  MediaSummary.swift
//  Animebox
//

import Foundation

/// Campos comunes que `Anime` y `Manga` exponen para los componentes de
/// catálogo compartidos (card, grid de resultados, hero de detalle).
protocol MediaSummary: Identifiable, Hashable {
    var malId: Int { get }
    var displayTitle: String { get }
    var titleJapanese: String? { get }
    var posterURL: URL? { get }
    var score: Double? { get }
}
