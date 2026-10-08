//
//  MangaStatus.swift
//  Animebox
//

import Foundation

enum MangaStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case reading
    case onHold
    case completed
    case dropped
    case planned

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .reading: AppLanguage.current.string("Leyendo")
        case .onHold: AppLanguage.current.string("En pausa")
        case .completed: AppLanguage.current.string("Completado")
        case .dropped: AppLanguage.current.string("Abandonado")
        case .planned: AppLanguage.current.string("Planeado")
        }
    }

    /// Valor exacto que espera la API REST de MAL, ver `LibraryStatus.malStatusValue`.
    var malStatusValue: String {
        switch self {
        case .reading: "reading"
        case .onHold: "on_hold"
        case .completed: "completed"
        case .dropped: "dropped"
        case .planned: "plan_to_read"
        }
    }

    init?(malStatusValue: String) {
        switch malStatusValue {
        case "reading": self = .reading
        case "on_hold": self = .onHold
        case "completed": self = .completed
        case "dropped": self = .dropped
        case "plan_to_read": self = .planned
        default: return nil
        }
    }
}
