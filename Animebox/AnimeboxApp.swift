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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LibraryEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

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
        }
        .modelContainer(sharedModelContainer)
    }
}
