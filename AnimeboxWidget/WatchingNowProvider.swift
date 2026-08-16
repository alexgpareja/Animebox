//
//  WatchingNowProvider.swift
//  AnimeboxWidget
//

import SwiftData
import WidgetKit

struct WatchingNowProvider: TimelineProvider {
    func placeholder(in context: Context) -> WatchingNowEntry {
        WatchingNowEntry(date: .now, items: [
            WatchingNowItem(malId: 0, title: "Nombre del anime", progress: 3, totalEpisodes: 12)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (WatchingNowEntry) -> Void) {
        completion(WatchingNowEntry(date: .now, items: fetchItems()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WatchingNowEntry>) -> Void) {
        let entry = WatchingNowEntry(date: .now, items: fetchItems())
        completion(Timeline(entries: [entry], policy: .never))
    }

    private func fetchItems() -> [WatchingNowItem] {
        guard let container = try? ModelContainer(
            for: LibraryEntry.self,
            configurations: ModelConfiguration(groupContainer: .identifier("group.Alexdev.Animebox"))
        ) else {
            return []
        }
        return watchingNowItems(in: container.mainContext, limit: 3)
    }
}
