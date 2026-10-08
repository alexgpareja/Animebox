//
//  AiredDateFormatter.swift
//  Animebox
//

import Foundation

/// Formatea `DateRange` (fechas crudas de Jikan o MAL, dos formatos
/// distintos) a un texto legible en el idioma elegido en Ajustes.
enum AiredDateFormatter {
    static func rangeString(from range: DateRange?) -> String? {
        guard let range else { return nil }
        let from = parse(range.from)
        let to = parse(range.to)

        switch (from, to) {
        case let (from?, to?):
            return "\(display(from)) - \(display(to))"
        case let (from?, nil):
            return display(from)
        default:
            return nil
        }
    }

    private static func parse(_ raw: String?) -> Date? {
        guard let raw, !raw.isEmpty else { return nil }
        if let date = ISO8601DateFormatter().date(from: raw) { return date }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .gmt
        return formatter.date(from: raw)
    }

    private static func display(_ date: Date) -> String {
        date.formatted(
            Date.FormatStyle(date: .abbreviated, time: .omitted, locale: AppLanguage.current.locale)
        )
    }
}
