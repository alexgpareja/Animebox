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
        case .all: AppLanguage.current.string("Todos")
        case .publishing: AppLanguage.current.string("Publicándose")
        case .complete: AppLanguage.current.string("Finalizado")
        case .upcoming: AppLanguage.current.string("Próximamente")
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
