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
    @State private var linkedAccount: LinkedAccount
    @State private var languageSettings = AppLanguageSettings()

    init() {
        _linkedAccount = State(initialValue: LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LibraryEntry.self,
            MangaLibraryEntry.self,
            PendingDeletion.self,
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
                .environment(linkedAccount)
                .environment(languageSettings)
                .environment(\.locale, languageSettings.language.locale)
        }
        .modelContainer(sharedModelContainer)
    }
}
