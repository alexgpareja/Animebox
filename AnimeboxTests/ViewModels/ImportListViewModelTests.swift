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
    <series_mangadb_id>2</series_mangadb_id>
    <series_title><![CDATA[Berserk]]></series_title>
    <my_read_chapters>350</my_read_chapters>
    <my_read_volumes>40</my_read_volumes>
    <my_status>Reading</my_status>
    </manga>
    </myanimelist>
    """

    @Test("commitImport crea una entrada de anime nueva y actualiza el estado a .done")
    func commitImportCreatesAnimeEntry() async throws {
        let sut = ImportListViewModel()
        sut.parse(data: Data(Self.animeXML.utf8))
        guard case .parsed = sut.state else {
            Issue.record("Esperaba .parsed tras parse(), obtuve \(sut.state)")
            return
        }

        await sut.commitImport(context: container.mainContext)

        guard case .done(let count) = sut.state else {
            Issue.record("Esperaba .done tras commitImport, obtuve \(sut.state)")
            return
        }
        #expect(count == 1)

        let store = LibraryStore(context: container.mainContext)
        let entry = try #require(store.entry(for: 1))
        #expect(entry.title == "Cowboy Bebop")
        #expect(entry.progress == 26)
        #expect(entry.status == .completed)
        #expect(entry.personalScore == 8)
    }

    @Test("commitImport sobrescribe una entrada de anime ya existente con el mismo malId")
    func commitImportUpdatesExistingAnimeEntry() async throws {
        let store = LibraryStore(context: container.mainContext)
        try store.upsert(
            anime: .fixture(id: 1, title: "Título viejo"),
            status: .planned,
            progress: 0,
            personalScore: nil,
            notes: nil
        )

        let sut = ImportListViewModel()
        sut.parse(data: Data(Self.animeXML.utf8))
        await sut.commitImport(context: container.mainContext)

        let all = try container.mainContext.fetch(FetchDescriptor<LibraryEntry>())
        #expect(all.count == 1, "no debe duplicarse la entrada")
        let entry = try #require(store.entry(for: 1))
        #expect(entry.status == .completed)
        #expect(entry.progress == 26)
    }

    @Test("commitImport crea una entrada de manga nueva")
    func commitImportCreatesMangaEntry() async throws {
        let sut = ImportListViewModel()
        sut.parse(data: Data(Self.mangaXML.utf8))
        await sut.commitImport(context: container.mainContext)

        guard case .done(let count) = sut.state else {
            Issue.record("Esperaba .done, obtuve \(sut.state)")
            return
        }
        #expect(count == 1)

        let store = MangaStore(context: container.mainContext)
        let entry = try #require(store.entry(for: 2))
        #expect(entry.title == "Berserk")
        #expect(entry.chaptersRead == 350)
        #expect(entry.volumesRead == 40)
        #expect(entry.status == .reading)
    }

    @Test("Un fichero inválido deja el estado en .error sin tocar la biblioteca")
    func parseInvalidDataSetsErrorState() {
        let sut = ImportListViewModel()
        sut.parse(data: Data("no xml".utf8))

        guard case .error = sut.state else {
            Issue.record("Esperaba .error, obtuve \(sut.state)")
            return
        }
    }
}
