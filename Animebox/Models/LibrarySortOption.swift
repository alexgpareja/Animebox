//
//  LibrarySortOption.swift
//  Animebox
//

import Foundation

enum LibrarySortOption: String, CaseIterable, Identifiable, Sendable {
    case recentlyAdded
    case alphabetical
    case rating
    case members

    var id: String { rawValue }

    /// Dirección con la que este campo empieza a ordenar la primera vez que
    /// se selecciona — tocarlo de nuevo con el mismo campo ya seleccionado
    /// invierte la dirección en vez de reaplicar esta por defecto.
    var defaultAscending: Bool {
        switch self {
        case .recentlyAdded: false
        case .alphabetical: true
        case .rating: false
        case .members: false
        }
    }

    var systemImage: String {
        switch self {
        case .recentlyAdded: "clock"
        case .alphabetical: "textformat"
        case .rating: "star"
        case .members: "person.2"
        }
    }

    func label(ascending: Bool) -> String {
        switch self {
        case .recentlyAdded:
            ascending ? AppLanguage.current.string("Más antiguos") : AppLanguage.current.string("Más recientes")
        case .alphabetical:
            ascending ? AppLanguage.current.string("Alfabético (A-Z)") : AppLanguage.current.string("Alfabético (Z-A)")
        case .rating:
            ascending ? AppLanguage.current.string("Menor valoración") : AppLanguage.current.string("Mayor valoración")
        case .members:
            ascending ? AppLanguage.current.string("Menos espectadores") : AppLanguage.current.string("Más espectadores")
        }
    }
}

extension [LibraryEntry] {
    func sorted(by option: LibrarySortOption, ascending: Bool) -> [LibraryEntry] {
        switch option {
        case .recentlyAdded:
            sorted {
                let (l, r) = ($0.createdAt ?? $0.updatedAt, $1.createdAt ?? $1.updatedAt)
                return ascending ? l < r : l > r
            }
        case .alphabetical:
            sorted {
                let order = $0.title.localizedStandardCompare($1.title)
                return ascending ? order == .orderedAscending : order == .orderedDescending
            }
        case .rating:
            sorted {
                let (l, r) = ($0.animeScore ?? -1, $1.animeScore ?? -1)
                return ascending ? l < r : l > r
            }
        case .members:
            sorted {
                let (l, r) = ($0.members ?? -1, $1.members ?? -1)
                return ascending ? l < r : l > r
            }
        }
    }
}

extension [MangaLibraryEntry] {
    func sorted(by option: LibrarySortOption, ascending: Bool) -> [MangaLibraryEntry] {
        switch option {
        case .recentlyAdded:
            sorted {
                let (l, r) = ($0.createdAt ?? $0.updatedAt, $1.createdAt ?? $1.updatedAt)
                return ascending ? l < r : l > r
            }
        case .alphabetical:
            sorted {
                let order = $0.title.localizedStandardCompare($1.title)
                return ascending ? order == .orderedAscending : order == .orderedDescending
            }
        case .rating:
            sorted {
                let (l, r) = ($0.mangaScore ?? -1, $1.mangaScore ?? -1)
                return ascending ? l < r : l > r
            }
        case .members:
            sorted {
                let (l, r) = ($0.members ?? -1, $1.members ?? -1)
                return ascending ? l < r : l > r
            }
        }
    }
}
