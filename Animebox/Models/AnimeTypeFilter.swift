//
//  AnimeTypeFilter.swift
//  Animebox
//

import Foundation

enum AnimeTypeFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case tv
    case movie
    case ova
    case special
    case ona
    case music

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: AppLanguage.current.string("Todos")
        case .tv: AppLanguage.current.string("TV")
        case .movie: AppLanguage.current.string("Película")
        case .ova: AppLanguage.current.string("OVA")
        case .special: AppLanguage.current.string("Especial")
        case .ona: AppLanguage.current.string("ONA")
        case .music: AppLanguage.current.string("Música")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
