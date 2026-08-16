//
//  SearchStatusFilter.swift
//  Animebox
//

import Foundation

enum SearchStatusFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case airing
    case complete
    case upcoming

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: String(localized: "Todos")
        case .airing: String(localized: "Emitiendo")
        case .complete: String(localized: "Finalizado")
        case .upcoming: String(localized: "Próximamente")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        case .airing: "airing"
        case .complete: "complete"
        case .upcoming: "upcoming"
        }
    }
}
