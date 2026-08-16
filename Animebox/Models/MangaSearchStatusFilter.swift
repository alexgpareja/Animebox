//
//  MangaSearchStatusFilter.swift
//  Animebox
//

import Foundation

enum MangaSearchStatusFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case publishing
    case complete
    case upcoming

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: String(localized: "Todos")
        case .publishing: String(localized: "Publicándose")
        case .complete: String(localized: "Finalizado")
        case .upcoming: String(localized: "Próximamente")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        case .publishing: "publishing"
        case .complete: "complete"
        case .upcoming: "upcoming"
        }
    }
}
