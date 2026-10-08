//
//  PreviewLibrary.swift
//  Animebox
//
//  Contenedor SwiftData en memoria con entradas de muestra para previews.
//  Solo se compila en DEBUG.
//

#if DEBUG
import Foundation
import SwiftData

@MainActor
enum PreviewLibrary {
    static func makeContainer() -> ModelContainer {
        let container: ModelContainer
        do {
            container = try ModelContainer(
                for: LibraryEntry.self, MangaLibraryEntry.self, PendingDeletion.self,
                configurations: ModelConfiguration(isStoredInMemoryOnly: true)
            )
        } catch {
            fatalError("PreviewLibrary container failed: \(error)")
        }
        let context = container.mainContext
        for entry in sampleEntries {
            context.insert(entry)
        }
        for entry in sampleMangaEntries {
            context.insert(entry)
        }
        return container
    }

    static var sampleEntries: [LibraryEntry] {
        [
            LibraryEntry(
                malId: 5114,
                title: "Fullmetal Alchemist: Brotherhood",
                imageURL: "https://cdn.myanimelist.net/images/anime/1208/94745l.jpg",
                status: .watching,
                progress: 30,
                totalEpisodes: 64,
                personalScore: 9,
                animeScore: 9.10
            ),
            LibraryEntry(
                malId: 38000,
                title: "Demon Slayer",
                imageURL: "https://cdn.myanimelist.net/images/anime/1286/99889l.jpg",
                status: .watching,
                progress: 12,
                totalEpisodes: 26,
                animeScore: 8.45
            ),
            LibraryEntry(
                malId: 9253,
                title: "Steins;Gate",
                imageURL: "https://cdn.myanimelist.net/images/anime/1935/127974l.jpg",
                status: .completed,
                progress: 24,
                totalEpisodes: 24,
                personalScore: 10,
                animeScore: 9.07
            ),
            LibraryEntry(
                malId: 1535,
                title: "Death Note",
                imageURL: "https://cdn.myanimelist.net/images/anime/9/9453l.jpg",
                status: .completed,
                progress: 37,
                totalEpisodes: 37,
                personalScore: 8,
                animeScore: 8.62
            ),
            LibraryEntry(
                malId: 16498,
                title: "Attack on Titan",
                imageURL: "https://cdn.myanimelist.net/images/anime/10/47347l.jpg",
                status: .planned,
                progress: 0,
                totalEpisodes: 25,
                animeScore: 8.54
            )
        ]
    }

    static var sampleMangaEntries: [MangaLibraryEntry] {
        [
            MangaLibraryEntry(
                malId: 656,
                title: "Vagabond",
                imageURL: "https://cdn.myanimelist.net/images/manga/1/259070l.jpg",
                status: .reading,
                chaptersRead: 200,
                totalChapters: 327,
                totalVolumes: 37,
                personalScore: 10,
                mangaScore: 9.24
            ),
            MangaLibraryEntry(
                malId: 11,
                title: "Naruto",
                imageURL: "https://cdn.myanimelist.net/images/manga/3/117681l.jpg",
                status: .completed,
                chaptersRead: 700,
                totalChapters: 700,
                totalVolumes: 72,
                personalScore: 8,
                mangaScore: 7.99
            ),
            MangaLibraryEntry(
                malId: 2,
                title: "Berserk",
                imageURL: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg",
                status: .planned,
                chaptersRead: 0,
                mangaScore: 9.46
            )
        ]
    }
}
#endif
