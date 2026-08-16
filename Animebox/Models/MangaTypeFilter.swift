//
//  MangaTypeFilter.swift
//  Animebox
//

import Foundation

enum MangaTypeFilter: String, CaseIterable, Identifiable, Hashable, Sendable {
    case all
    case manga
    case novel
    case lightnovel
    case oneshot
    case doujin
    case manhwa
    case manhua

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .all: String(localized: "Todos")
        case .manga: String(localized: "Manga")
        case .novel: String(localized: "Novela")
        case .lightnovel: String(localized: "Novela ligera")
        case .oneshot: String(localized: "One-shot")
        case .doujin: String(localized: "Doujinshi")
        case .manhwa: String(localized: "Manhwa")
        case .manhua: String(localized: "Manhua")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
