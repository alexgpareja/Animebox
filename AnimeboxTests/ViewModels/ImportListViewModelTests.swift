//
//  ImportListViewModelTests.swift
//  AnimeboxTests
//

import Foundation
import SwiftData
import Testing
@testable import Animebox

@MainActor
struct ImportListViewModelTests {
    let container: ModelContainer

    init() throws {
        container = try ModelContainer(
            for: LibraryEntry.self, MangaLibraryEntry.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    private static let animeXML = """
    <myanimelist>
    <anime>
    <series_animedb_id>1</series_animedb_id>
    <series_title><![CDATA[Cowboy Bebop]]></series_title>
    <series_episodes>26</series_episodes>
    <my_watched_episodes>26</my_watched_episodes>
    <my_score>8</my_score>
    <my_status>Completed</my_status>
    </anime>
    </myanimelist>
    """

    private static let mangaXML = """
    <myanimelist>
    <manga>
    <manga_mangadb_id>2</manga_mangadb_id>
    <manga_title><![CDATA[Berserk]]></manga_title>
    <my_read_chapters>350</my_read_chapters>
    <my_read_volumes>40</my_read_volumes>
    <my_status>Reading</my_status>
    </manga>
    </myanimelist>
    """

    private var coordinator: LibrarySyncCoordinator {
        LibrarySyncCoordinator(context: container.mainContext, account: LinkedAccount(mal: MALSession(), aniList: AniListSession()))
    }

    private static let enrichedAnime = Anime(
        malId: 1,
        url: nil,
        images: MediaImages(
            jpg: ImageSet(imageUrl: "https://cdn.example/cowboy.jpg", smallImageUrl: nil, largeImageUrl: nil),
            webp: nil
        ),
        title: "Cowboy Bebop",
        titleEnglish: nil,
        titleJapanese: nil,
        type: "TV",
        episodes: 26,
        status: "Finished Airing",
        airing: false,
        synopsis: nil,
        score: 8.75,
        scoredBy: nil,
        rank: nil,
        popularity: nil,
        members: nil,
        favorites: nil,
        year: nil,
        season: nil,
        genres: nil,
        studios: nil,
        aired: nil,
        relations: nil
    )

    private static let enrichedManga = Manga(
        malId: 2,
        url: nil,
        images: MediaImages(
            jpg: ImageSet(imageUrl: "https://cdn.example/berserk.jpg", smallImageUrl: nil, largeImageUrl: nil),
            webp: nil
        ),
        title: "Berserk",
        titleEnglish: nil,
        titleJapanese: nil,
        type: "Manga",
        chapters: nil,
        volumes: nil,
        status: "Publishing",
        publishing: true,
        synopsis: nil,
        score: 9.4,
        scoredBy: nil,
        rank: nil,
        popularity: nil,
        members: nil,
        favorites: nil,
        genres: nil,
        published: nil,
        relations: nil
    )

    @Test("importFile crea una entrada de anime enriquecida con la imagen de red y actualiza el estado a .done")
    func importFileCreatesEnrichedAnimeEntry() async throws {
        let sut = ImportListViewModel()
        let service = JikanServiceStub(details: Self.enrichedAnime)

        await sut.importFile(data: Data(Self.animeXML.utf8), service: service, coordinator: coordinator)

        guard case .done(let count) = sut.state else {
            Issue.record("Esperaba .done tras importFile, obtuve \(sut.state)")
            return
        }
        #expect(count == 1)

        let store = LibraryStore(context: container.mainContext)
        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.title == "Cowboy Bebop")
        #expect(entry.imageURL == "https://cdn.example/cowboy.jpg", "debe usar la imagen de la petición de red, no el XML (que no trae imágenes)")
        #expect(entry.progress == 26, "el progreso viene del XML (dato personal), no de la red")
        #expect(entry.status == .completed)
        #expect(entry.personalScore == 8)
    }

    @Test("Si la petición de enriquecimiento falla, cae al stub del XML sin abortar el import")
    func importFileFallsBackWhenEnrichmentFails() async throws {
        let sut = ImportListViewModel()
        let service = JikanServiceStub(details: nil) // sin `details` -> animeDetails(id:) lanza

        await sut.importFile(data: Data(Self.animeXML.utf8), service: service, coordinator: coordinator)

        guard case .done(let count) = sut.state else {
            Issue.record("Esperaba .done incluso con el fetch fallido, obtuve \(sut.state)")
            return
        }
        #expect(count == 1)

        let store = LibraryStore(context: container.mainContext)
        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.title == "Cowboy Bebop")
        #expect(entry.imageURL == nil)
        #expect(entry.progress == 26)
    }

    @Test("importFile sobrescribe una entrada de anime ya existente con el mismo malId")
    func importFileUpdatesExistingAnimeEntry() async throws {
        let store = LibraryStore(context: container.mainContext)
        try store.upsert(
            anime: .fixture(id: 1, title: "Título viejo"),
            provider: .mal,
            status: .planned,
            progress: 0,
            personalScore: nil,
            notes: nil
        )

        let sut = ImportListViewModel()
        let service = JikanServiceStub(details: Self.enrichedAnime)
        await sut.importFile(data: Data(Self.animeXML.utf8), service: service, coordinator: coordinator)

        let all = try container.mainContext.fetch(FetchDescriptor<LibraryEntry>())
        #expect(all.count == 1, "no debe duplicarse la entrada")
        let entry = try #require(store.entry(for: 1, provider: .mal))
        #expect(entry.status == .completed)
        #expect(entry.progress == 26)
    }

    @Test("importFile crea una entrada de manga enriquecida con la imagen de red")
    func importFileCreatesEnrichedMangaEntry() async throws {
        let sut = ImportListViewModel()
        let service = JikanServiceStub(mangaDetailsResult: Self.enrichedManga)

        await sut.importFile(data: Data(Self.mangaXML.utf8), service: service, coordinator: coordinator)

        guard case .done(let count) = sut.state else {
            Issue.record("Esperaba .done, obtuve \(sut.state)")
            return
        }
        #expect(count == 1)

        let store = MangaStore(context: container.mainContext)
        let entry = try #require(store.entry(for: 2, provider: .mal))
        #expect(entry.title == "Berserk")
        #expect(entry.imageURL == "https://cdn.example/berserk.jpg")
        #expect(entry.chaptersRead == 350)
        #expect(entry.volumesRead == 40)
        #expect(entry.status == .reading)
    }

    @Test("Un fichero inválido deja el estado en .error sin tocar la biblioteca")
    func importInvalidDataSetsErrorState() async {
        let sut = ImportListViewModel()
        let service = JikanServiceStub()

        await sut.importFile(data: Data("no xml".utf8), service: service, coordinator: coordinator)

        guard case .error = sut.state else {
            Issue.record("Esperaba .error, obtuve \(sut.state)")
            return
        }
    }
}
