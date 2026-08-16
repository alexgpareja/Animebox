//
//  WatchingNowWidget.swift
//  AnimeboxWidget
//

import SwiftUI
import WidgetKit

struct WatchingNowWidget: Widget {
    let kind: String = "WatchingNowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WatchingNowProvider()) { entry in
            WatchingNowEntryView(entry: entry)
        }
        .configurationDisplayName("Viendo ahora")
        .description("El anime que estás viendo y en qué episodio vas.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}
