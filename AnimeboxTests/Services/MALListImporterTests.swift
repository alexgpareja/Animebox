//
//  MALListImporterTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@MainActor
struct MALListImporterTests {

    private static let animeXML = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <myanimelist>
    <myinfo>
    <user_id>123</user_id>
    <user_name>testuser</user_name>
    </myinfo>
    <anime>
    <series_animedb_id>1</series_animedb_id>
    <series_title><![CDATA[Cowboy Bebop]]></series_title>
    <series_episodes>26</series_episodes>
    <my_watched_episodes>26</my_watched_episodes>
    <my_start_date>2016-02-15</my_start_date>
    <my_finish_date>2016-04-02</my_finish_date>
    <my_score>8</my_score>
    <my_status>Completed</my_status>
    </anime>
    <anime>
    <series_animedb_id>5114</series_animedb_id>
    <series_title><![CDATA[Fullmetal Alchemist: Brotherhood]]></series_title>
    <series_episodes>64</series_episodes>
    <my_watched_episodes>10</my_watched_episodes>
    <my_start_date>0000-00-00</my_start_date>
    <my_finish_date>0000-00-00</my_finish_date>
    <my_score>0</my_score>
    <my_status>Watching</my_status>
    </anime>
    <anime>
    <series_animedb_id>16498</series_animedb_id>
    <series_title><![CDATA[Attack on Titan]]></series_title>
    <series_episodes>25</series_episodes>
    <my_watched_episodes>3</my_watched_episodes>
    <my_status>On-Hold</my_status>
    </anime>
    <anime>
    <series_animedb_id>11061</series_animedb_id>
    <series_title><![CDATA[Hunter x Hunter]]></series_title>
    <series_episodes>148</series_episodes>
    <my_watched_episodes>0</my_watched_episodes>
    <my_status>Plan to Watch</my_status>
    </anime>
    </myanimelist>
    """

    private static let mangaXML = """
    <?xml version="1.0" encoding="UTF-8" ?>
    <myanimelist>
    <myinfo>
    <user_id>123</user_id>
    </myinfo>
    <manga>
    <series_mangadb_id>2</series_mangadb_id>
    <series_title><![CDATA[Berserk]]></series_title>
    <series_chapters>0</series_chapters>
    <series_volumes>0</series_volumes>
    <my_read_chapters>350</my_read_chapters>
    <my_read_volumes>40</my_read_volumes>
    <my_score>10</my_score>
    <my_status>Reading</my_status>
    </manga>
    <manga>
    <series_mangadb_id>11</series_mangadb_id>
    <series_title><![CDATA[Naruto]]></series_title>
    <series_chapters>700</series_chapters>
    <series_volumes>72</series_volumes>
    <my_read_chapters>700</my_read_chapters>
    <my_read_volumes>72</my_read_volumes>
    <my_score>8</my_score>
    <my_status>Plan to Read</my_status>
    </manga>
    </myanimelist>
    """

    @Test("Parsea correctamente una lista de anime, incluyendo mapeo de estados y fechas")
    func parseAnimeListHappyPath() throws {
        let result = try MALListImporter().parse(Data(Self.animeXML.utf8))

        guard case .anime(let entries) = result else {
            Issue.record("Esperaba .anime, obtuve \(result)")
            return
        }
        try #require(entries.count == 4)

        let bebop = try #require(entries.first(where: { $0.malId == 1 }))
        #expect(bebop.title == "Cowboy Bebop")
        #expect(bebop.totalEpisodes == 26)
        #expect(bebop.watchedEpisodes == 26)
        #expect(bebop.personalScore == 8)
        #expect(bebop.status == .completed)
        #expect(bebop.startDate != nil)
        #expect(bebop.finishDate != nil)

        let fma = try #require(entries.first(where: { $0.malId == 5114 }))
        #expect(fma.status == .watching)
        #expect(fma.personalScore == nil, "my_score=0 significa sin puntuar")
        #expect(fma.startDate == nil, "0000-00-00 debe interpretarse como sin fecha")
        #expect(fma.finishDate == nil)

        let aot = try #require(entries.first(where: { $0.malId == 16498 }))
        #expect(aot.status == .onHold)

        let hxh = try #require(entries.first(where: { $0.malId == 11061 }))
        #expect(hxh.status == .planned)
    }

    @Test("Parsea correctamente una lista de manga")
    func parseMangaListHappyPath() throws {
        let result = try MALListImporter().parse(Data(Self.mangaXML.utf8))

        guard case .manga(let entries) = result else {
            Issue.record("Esperaba .manga, obtuve \(result)")
            return
        }
        try #require(entries.count == 2)

        let berserk = try #require(entries.first(where: { $0.malId == 2 }))
        #expect(berserk.title == "Berserk")
        #expect(berserk.chaptersRead == 350)
        #expect(berserk.volumesRead == 40)
        #expect(berserk.totalChapters == nil, "series_chapters=0 significa desconocido/en curso")
        #expect(berserk.status == .reading)
        #expect(berserk.personalScore == 10)

        let naruto = try #require(entries.first(where: { $0.malId == 11 }))
        #expect(naruto.status == .planned)
        #expect(naruto.totalChapters == 700)
    }

    @Test("Un fichero que no es XML lanza MALImportError.invalidXML")
    func invalidXMLThrows() {
        let garbage = Data("esto no es XML".utf8)
        #expect(throws: MALImportError.invalidXML) {
            try MALListImporter().parse(garbage)
        }
    }

    @Test("Un XML válido sin entradas de anime o manga lanza MALImportError.emptyList")
    func emptyListThrows() {
        let emptyXML = Data("<myanimelist><myinfo><user_id>1</user_id></myinfo></myanimelist>".utf8)
        #expect(throws: MALImportError.emptyList) {
            try MALListImporter().parse(emptyXML)
        }
    }
}
