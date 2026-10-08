//
//  LibraryStatus.swift
//  Animebox
//

import Foundation

enum LibraryStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case watching
    case onHold
    case completed
    case dropped
    case planned

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .watching: AppLanguage.current.string("Viendo")
        case .onHold: AppLanguage.current.string("En pausa")
        case .completed: AppLanguage.current.string("Completado")
        case .dropped: AppLanguage.current.string("Abandonado")
        case .planned: AppLanguage.current.string("Planeado")
        }
    }

    /// Valor exacto que espera la API REST de MAL (`my_list_status.status` /
    /// `PATCH .../my_list_status`) — distinto del `rawValue` local, que es
    /// solo de almacenamiento interno.
    var malStatusValue: String {
        switch self {
        case .watching: "watching"
        case .onHold: "on_hold"
        case .completed: "completed"
        case .dropped: "dropped"
        case .planned: "plan_to_watch"
        }
    }

    init?(malStatusValue: String) {
        switch malStatusValue {
        case "watching": self = .watching
        case "on_hold": self = .onHold
        case "completed": self = .completed
        case "dropped": self = .dropped
        case "plan_to_watch": self = .planned
        default: return nil
        }
    }
}
