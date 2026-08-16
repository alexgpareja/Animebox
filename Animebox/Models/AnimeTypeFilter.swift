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
        case .all: String(localized: "Todos")
        case .tv: String(localized: "TV")
        case .movie: String(localized: "Película")
        case .ova: String(localized: "OVA")
        case .special: String(localized: "Especial")
        case .ona: String(localized: "ONA")
        case .music: String(localized: "Música")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
