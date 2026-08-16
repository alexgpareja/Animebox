//
//  WatchingNowQuery.swift
//  Animebox
//

import Foundation
import SwiftData

/// Copia plana de los campos de `LibraryEntry` que necesita el widget —
/// cruza el límite hacia la extensión como dato, no como referencia `@Model`.
struct WatchingNowItem: Sendable, Identifiable, Equatable {
    let malId: Int
    let title: String
    let progress: Int
    let totalEpisodes: Int?

    var id: Int { malId }
}

/// Devuelve las entradas en estado "viendo", más recientes primero. La usan
/// tanto la app (para testearla con `@testable import Animebox`) como el
/// widget (compilando este mismo fichero en su target).
func watchingNowItems(in context: ModelContext, limit: Int = 3) -> [WatchingNowItem] {
    let watchingRaw = LibraryStatus.watching.rawValue
    var descriptor = FetchDescriptor<LibraryEntry>(
        predicate: #Predicate { $0.statusRaw == watchingRaw },
        sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
    )
    descriptor.fetchLimit = limit
    let entries = (try? context.fetch(descriptor)) ?? []
    return entries.map {
        WatchingNowItem(malId: $0.malId, title: $0.title, progress: $0.progress, totalEpisodes: $0.totalEpisodes)
    }
}
