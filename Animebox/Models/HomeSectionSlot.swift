//
//  HomeSectionSlot.swift
//  Animebox
//

import Foundation

/// Las 3 secciones de "Inicio" son las mismas para anime y manga en
/// concepto (continuando / mejor valorados / en emisión-publicación),
/// pero cada `MediaKind` guarda su propio orden — reordenar anime no toca
/// el orden de manga.
enum HomeSectionSlot: String, CaseIterable, Identifiable, Sendable {
    case continuing
    case topRanked
    case seasonal

    var id: String { rawValue }

    func title(for kind: MediaKind) -> String {
        switch (self, kind) {
        case (.continuing, .anime): AppLanguage.current.string("Viendo actualmente")
        case (.continuing, .manga): AppLanguage.current.string("Leyendo actualmente")
        case (.topRanked, .anime): AppLanguage.current.string("Top Anime")
        case (.topRanked, .manga): AppLanguage.current.string("Top Manga")
        case (.seasonal, .anime): AppLanguage.current.string("En Emisión")
        case (.seasonal, .manga): AppLanguage.current.string("En Publicación")
        }
    }
}

enum HomeSectionOrderStore {
    private static func key(for kind: MediaKind) -> String {
        "homeSectionOrder.\(kind.rawValue)"
    }

    static func order(for kind: MediaKind) -> [HomeSectionSlot] {
        guard let raw = UserDefaults.standard.array(forKey: key(for: kind)) as? [String] else {
            return HomeSectionSlot.allCases
        }
        let parsed = raw.compactMap(HomeSectionSlot.init(rawValue:))
        // Si faltan slots (dato de una versión anterior, o corrupto), añade
        // los que falten al final en vez de perder secciones de la pantalla.
        let missing = HomeSectionSlot.allCases.filter { !parsed.contains($0) }
        return parsed + missing
    }

    static func setOrder(_ order: [HomeSectionSlot], for kind: MediaKind) {
        UserDefaults.standard.set(order.map(\.rawValue), forKey: key(for: kind))
    }
}
