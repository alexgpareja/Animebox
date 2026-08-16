//
//  WatchingNowQueryTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
struct WatchingNowQueryTests {
    let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: LibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test("Solo devuelve entradas en estado 'viendo', más recientes primero")
    func filtersAndOrdersByUpdatedAt() throws {
        let context = container.mainContext
        let older = LibraryEntry(malId: 1, title: "Antigua", status: .watching, progress: 2, totalEpisodes: 24, updatedAt: .now.addingTimeInterval(-1000))
        let newer = LibraryEntry(malId: 2, title: "Reciente", status: .watching, progress: 5, totalEpisodes: 12, updatedAt: .now)
        let completed = LibraryEntry(malId: 3, title: "Completada", status: .completed, progress: 12, totalEpisodes: 12, updatedAt: .now)
        [older, newer, completed].forEach { context.insert($0) }
        try context.save()

        let items = watchingNowItems(in: context)

        #expect(items.map(\.malId) == [2, 1])
        #expect(items.map(\.title) == ["Reciente", "Antigua"])
    }

    @Test("Respeta el límite indicado")
    func respectsLimit() throws {
        let context = container.mainContext
        for i in 1...5 {
            context.insert(LibraryEntry(malId: i, title: "Anime \(i)", status: .watching, progress: 1, totalEpisodes: 12))
        }
        try context.save()

        let items = watchingNowItems(in: context, limit: 2)

        #expect(items.count == 2)
    }

    @Test("Sin entradas en 'viendo' devuelve una lista vacía")
    func emptyWhenNothingWatching() throws {
        let context = container.mainContext
        context.insert(LibraryEntry(malId: 1, title: "Planeada", status: .planned, progress: 0, totalEpisodes: 12))
        try context.save()

        #expect(watchingNowItems(in: context).isEmpty)
    }
}
