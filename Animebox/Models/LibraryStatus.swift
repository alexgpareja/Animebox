//
//  LibraryStatus.swift
//  Animebox
//

import Foundation

enum LibraryStatus: String, Codable, CaseIterable, Identifiable, Sendable {
    case watching
    case completed
    case dropped
    case planned

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .watching: "Viendo"
        case .completed: "Completado"
        case .dropped: "Abandonado"
        case .planned: "Planeado"
        }
    }
}
