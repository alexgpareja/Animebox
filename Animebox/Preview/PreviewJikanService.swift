//
//  PreviewJikanService.swift
//  Animebox
//
//  Datos canned para los previews de Xcode. Solo se compila en DEBUG.
//

#if DEBUG
import Foundation

nonisolated struct PreviewJikanService: ContentServicing {
    func topAnime(limit: Int) async throws -> [Anime] {
        Array(PreviewSamples.animes.prefix(limit))
    }

    func currentSeason(limit: Int) async throws -> [Anime] {
        Array(PreviewSamples.animes.reversed().prefix(limit))
    }

    func searchAnime(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        rating: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Anime] {
        Array(PreviewSamples.animes.prefix(limit))
    }

    func animeDetails(id: Int) async throws -> Anime {
        PreviewSamples.animes.first(where: { $0.malId == id }) ?? PreviewSamples.animes[0]
    }

    func animeGenres() async throws -> [NamedEntity] {
        MALGenres.animeGenres
    }

    func animeThemes() async throws -> [NamedEntity] {
        MALGenres.animeThemes
    }

    func topManga(limit: Int) async throws -> [Manga] {
        Array(PreviewSamples.mangas.prefix(limit))
    }

    func currentlyPublishingManga(limit: Int) async throws -> [Manga] {
        Array(PreviewSamples.mangas.reversed().prefix(limit))
    }

    func searchManga(
        query: String?,
        status: String?,
        genres: [Int]?,
        type: String?,
        startDate: String?,
        endDate: String?,
        limit: Int
    ) async throws -> [Manga] {
        Array(PreviewSamples.mangas.prefix(limit))
    }

    func mangaDetails(id: Int) async throws -> Manga {
        PreviewSamples.mangas.first(where: { $0.malId == id }) ?? PreviewSamples.mangas[0]
    }

    func mangaGenres() async throws -> [NamedEntity] {
        MALGenres.mangaGenres
    }

    func mangaThemes() async throws -> [NamedEntity] {
        MALGenres.mangaThemes
    }
}

nonisolated enum PreviewSamples {
    /// Géneros + temas reales de MAL, para que el preview de la fila de chips
    /// refleje el volumen real.
    static let genres: [NamedEntity] = MALGenres.animeGenres + MALGenres.animeThemes

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
            images: MediaImages(
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
            studios: nil,
            aired: DateRange(from: "2020-04-05T00:00:00+00:00", to: "2020-09-27T00:00:00+00:00"),
            relations: nil
        )
    }

    static let mangas: [Manga] = [
        mangaSample(id: 2, title: "Berserk", score: 9.46, chapters: nil, volumes: nil,
                    imageURL: "https://cdn.myanimelist.net/images/manga/1/157897l.jpg"),
        mangaSample(id: 656, title: "Vagabond", score: 9.24, chapters: 327, volumes: 37,
                    imageURL: "https://cdn.myanimelist.net/images/manga/1/259070l.jpg"),
        mangaSample(id: 11, title: "Naruto", score: 7.99, chapters: 700, volumes: 72,
                    imageURL: "https://cdn.myanimelist.net/images/manga/3/117681l.jpg"),
        mangaSample(id: 44347, title: "Chainsaw Man", score: 8.68, chapters: nil, volumes: nil,
                    imageURL: "https://cdn.myanimelist.net/images/manga/3/216464l.jpg")
    ]

    private static func mangaSample(
        id: Int, title: String, score: Double, chapters: Int?, volumes: Int?, imageURL: String
    ) -> Manga {
        Manga(
            malId: id,
            url: nil,
            images: MediaImages(
                jpg: ImageSet(imageUrl: imageURL, smallImageUrl: imageURL, largeImageUrl: imageURL),
                webp: nil
            ),
            title: title,
            titleEnglish: nil,
            titleJapanese: nil,
            type: "Manga",
            chapters: chapters,
            volumes: volumes,
            status: "Publishing",
            publishing: true,
            synopsis: "Sinopsis de muestra para el preview de \(title). Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.",
            score: score,
            scoredBy: 1_000_000,
            rank: 1,
            popularity: 1,
            members: 2_000_000,
            favorites: 100_000,
            genres: [
                NamedEntity(malId: 1, type: "manga", name: "Acción", url: nil),
                NamedEntity(malId: 2, type: "manga", name: "Aventura", url: nil)
            ],
            published: DateRange(from: "2018-12-03T00:00:00+00:00", to: nil),
            relations: nil
        )
    }
}
#endif
