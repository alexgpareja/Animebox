//
//  PreviewJikanService.swift
//  Animebox
//
//  Datos canned para los previews de Xcode. Solo se compila en DEBUG.
//

#if DEBUG
import Foundation

nonisolated struct PreviewJikanService: JikanServicing {
    func topAnime(limit: Int) async throws -> [Anime] {
        Array(PreviewSamples.animes.prefix(limit))
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        Array(PreviewSamples.animes.reversed().prefix(limit))
    }

    func searchAnime(query: String?, status: String?, genres: [Int]?, limit: Int) async throws -> [Anime] {
        Array(PreviewSamples.animes.prefix(limit))
    }

    func animeDetails(id: Int) async throws -> Anime {
        PreviewSamples.animes.first(where: { $0.malId == id }) ?? PreviewSamples.animes[0]
    }

    func animeGenres() async throws -> [NamedEntity] {
        PreviewSamples.genres
    }
}

nonisolated enum PreviewSamples {
    static let genres: [NamedEntity] = [
        NamedEntity(malId: 1, type: "anime", name: "Acción", url: nil),
        NamedEntity(malId: 2, type: "anime", name: "Aventura", url: nil),
        NamedEntity(malId: 4, type: "anime", name: "Comedia", url: nil),
        NamedEntity(malId: 8, type: "anime", name: "Drama", url: nil),
        NamedEntity(malId: 10, type: "anime", name: "Fantasía", url: nil),
        NamedEntity(malId: 14, type: "anime", name: "Horror", url: nil),
        NamedEntity(malId: 22, type: "anime", name: "Romance", url: nil),
        NamedEntity(malId: 24, type: "anime", name: "Sci-Fi", url: nil),
        NamedEntity(malId: 30, type: "anime", name: "Deportes", url: nil)
    ]

    static let animes: [Anime] = [
        sample(id: 5114, title: "Fullmetal Alchemist: Brotherhood", score: 9.10, episodes: 64,
               imageURL: "https://cdn.myanimelist.net/images/anime/1208/94745l.jpg"),
        sample(id: 9253, title: "Steins;Gate", score: 9.07, episodes: 24,
               imageURL: "https://cdn.myanimelist.net/images/anime/1935/127974l.jpg"),
        sample(id: 38000, title: "Demon Slayer", score: 8.45, episodes: 26,
               imageURL: "https://cdn.myanimelist.net/images/anime/1286/99889l.jpg"),
        sample(id: 16498, title: "Attack on Titan", score: 8.54, episodes: 25,
               imageURL: "https://cdn.myanimelist.net/images/anime/10/47347l.jpg"),
        sample(id: 11061, title: "Hunter x Hunter (2011)", score: 9.04, episodes: 148,
               imageURL: "https://cdn.myanimelist.net/images/anime/11/33657l.jpg"),
        sample(id: 1535, title: "Death Note", score: 8.62, episodes: 37,
               imageURL: "https://cdn.myanimelist.net/images/anime/9/9453l.jpg")
    ]

    private static func sample(id: Int, title: String, score: Double, episodes: Int, imageURL: String) -> Anime {
        Anime(
            malId: id,
            url: nil,
            images: AnimeImages(
                jpg: ImageSet(imageUrl: imageURL, smallImageUrl: imageURL, largeImageUrl: imageURL),
                webp: nil
            ),
            title: title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: "TV",
            episodes: episodes,
            status: "Finished Airing",
            airing: false,
            synopsis: "Sinopsis de muestra para el preview de \(title). Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            score: score,
            scoredBy: 1_000_000,
            rank: 1,
            popularity: 1,
            members: 2_000_000,
            favorites: 100_000,
            year: 2020,
            season: nil,
            genres: [
                NamedEntity(malId: 1, type: "anime", name: "Acción", url: nil),
                NamedEntity(malId: 2, type: "anime", name: "Aventura", url: nil)
            ],
            studios: nil
        )
    }
}
#endif
