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
        case .all: AppLanguage.current.string("Todos")
        case .manga: AppLanguage.current.string("Manga")
        case .novel: AppLanguage.current.string("Novela")
        case .lightnovel: AppLanguage.current.string("Novela ligera")
        case .oneshot: AppLanguage.current.string("One-shot")
        case .doujin: AppLanguage.current.string("Doujinshi")
        case .manhwa: AppLanguage.current.string("Manhwa")
        case .manhua: AppLanguage.current.string("Manhua")
        }
    }

    var queryValue: String? {
        switch self {
        case .all: nil
        default: rawValue
        }
    }
}
