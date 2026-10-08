//
//  RelationTypeLocalization.swift
//  Animebox
//

import Foundation

/// Traduce el `relation` crudo de Jikan/MAL ("Sequel", "Prequel"...) al
/// texto que se muestra bajo cada card de `RelatedMediaSection`. Un valor
/// no reconocido cae de vuelta al texto crudo, igual que `GenreLocalization`.
enum RelationTypeLocalization {
    static func localizedName(for relation: String) -> String {
        guard let spanish = table[relation] else { return relation }
        return AppLanguage.current.string(spanish)
    }

    private static let table: [String: String] = [
        "Sequel": "Secuela",
        "Prequel": "Precuela",
        "Side Story": "Historia paralela",
        "Alternative Version": "Versión alternativa",
        "Alternative Setting": "Ambientación alternativa",
        "Parent Story": "Historia principal",
        "Full Story": "Historia completa",
        "Summary": "Resumen",
        "Spin-Off": "Spin-off",
        "Other": "Otro",
        "Character": "Personaje"
    ]
}
