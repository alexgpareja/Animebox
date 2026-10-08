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
        case .all: AppLanguage.current.string("Todos")
        case .airing: AppLanguage.current.string("Emitiendo")
        case .complete: AppLanguage.current.string("Finalizado")
        case .upcoming: AppLanguage.current.string("Próximamente")
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
