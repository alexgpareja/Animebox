//
//  AnimeboxApp.swift
//  Animebox
//
//  Created by Alex on 08/06/2026.
//

import SwiftUI
import SwiftData

@main
struct AnimeboxApp: App {
    @State private var malSession = MALSession()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LibraryEntry.self,
            MangaLibraryEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.Alexdev.Animebox")
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.dark)
                .environment(malSession)
        }
        .modelContainer(sharedModelContainer)
    }
}
