//
//  MediaKind.swift
//  Animebox
//

import SwiftUI

enum MediaKind: String, CaseIterable, Identifiable, Sendable {
    case anime
    case manga

    var id: String { rawValue }

    var displayName: LocalizedStringKey {
        switch self {
        case .anime: "Anime"
        case .manga: "Manga"
        }
    }
}
