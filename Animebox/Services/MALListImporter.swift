//
//  MALListImporter.swift
//  Animebox
//
//  Parsea el XML de exportación de listas de MyAnimeList (Ajustes > Import/Export
//  en la web de MAL). Cada lista se exporta en un fichero separado (animelist.xml
//  con entradas <anime>, mangalist.xml con entradas <manga>) — este parser
//  autodetecta cuál de los dos es.
//

import Foundation

@MainActor
struct MALListImporter {
    func parse(_ data: Data) throws -> MALImportResult {
        let delegate = Delegate()
        let parser = XMLParser(data: data)
        parser.delegate = delegate
        guard parser.parse() else {
            throw MALImportError.invalidXML
        }
        if !delegate.animeEntries.isEmpty {
            return .anime(delegate.animeEntries)
        }
        if !delegate.mangaEntries.isEmpty {
            return .manga(delegate.mangaEntries)
        }
        throw MALImportError.emptyList
    }
}

@MainActor
private final class Delegate: NSObject, XMLParserDelegate {
    private(set) var animeEntries: [MALAnimeImportEntry] = []
    private(set) var mangaEntries: [MALMangaImportEntry] = []

    private var currentFields: [String: String] = [:]
    private var currentText = ""
    private var isInsideAnime = false
    private var isInsideManga = false

    private static let animeFields: Set<String> = [
        "series_animedb_id", "series_title", "series_episodes",
        "my_watched_episodes", "my_score", "my_status",
        "my_start_date", "my_finish_date"
    ]
    private static let mangaFields: Set<String> = [
        "series_mangadb_id", "series_title", "series_chapters", "series_volumes",
        "my_read_chapters", "my_read_volumes", "my_score", "my_status",
        "my_start_date", "my_finish_date"
    ]

    func parser(
        _ parser: XMLParser,
        didStartElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?,
        attributes attributeDict: [String: String] = [:]
    ) {
        currentText = ""
        if elementName == "anime" {
            isInsideAnime = true
            currentFields = [:]
        } else if elementName == "manga" {
            isInsideManga = true
            currentFields = [:]
        }
    }

    func parser(_ parser: XMLParser, foundCharacters string: String) {
        currentText += string
    }

    /// El título (`series_title`) en un export real de MAL viene envuelto en
    /// CDATA. XMLParser no lo reporta vía `foundCharacters` salvo que se
    /// implemente este delegate explícitamente.
    func parser(_ parser: XMLParser, foundCDATA CDATABlock: Data) {
        if let string = String(data: CDATABlock, encoding: .utf8) {
            currentText += string
        }
    }

    func parser(
        _ parser: XMLParser,
        didEndElement elementName: String,
        namespaceURI: String?,
        qualifiedName qName: String?
    ) {
        let trimmed = currentText.trimmingCharacters(in: .whitespacesAndNewlines)
        if isInsideAnime, Self.animeFields.contains(elementName) {
            currentFields[elementName] = trimmed
        } else if isInsideManga, Self.mangaFields.contains(elementName) {
            currentFields[elementName] = trimmed
        }
        currentText = ""

        if elementName == "anime" {
            if let entry = Self.makeAnimeEntry(from: currentFields) {
                animeEntries.append(entry)
            }
            isInsideAnime = false
            currentFields = [:]
        } else if elementName == "manga" {
            if let entry = Self.makeMangaEntry(from: currentFields) {
                mangaEntries.append(entry)
            }
            isInsideManga = false
            currentFields = [:]
        }
    }

    private static func makeAnimeEntry(from fields: [String: String]) -> MALAnimeImportEntry? {
        guard let malId = fields["series_animedb_id"].flatMap(Int.init), malId > 0 else { return nil }
        return MALAnimeImportEntry(
            malId: malId,
            title: fields["series_title"] ?? "",
            totalEpisodes: positiveInt(fields["series_episodes"]),
            watchedEpisodes: fields["my_watched_episodes"].flatMap(Int.init) ?? 0,
            personalScore: positiveInt(fields["my_score"]),
            status: mapAnimeStatus(fields["my_status"]),
            startDate: parseDate(fields["my_start_date"]),
            finishDate: parseDate(fields["my_finish_date"])
        )
    }

    private static func makeMangaEntry(from fields: [String: String]) -> MALMangaImportEntry? {
        guard let malId = fields["series_mangadb_id"].flatMap(Int.init), malId > 0 else { return nil }
        return MALMangaImportEntry(
            malId: malId,
            title: fields["series_title"] ?? "",
            totalChapters: positiveInt(fields["series_chapters"]),
            totalVolumes: positiveInt(fields["series_volumes"]),
            chaptersRead: fields["my_read_chapters"].flatMap(Int.init) ?? 0,
            volumesRead: fields["my_read_volumes"].flatMap(Int.init) ?? 0,
            personalScore: positiveInt(fields["my_score"]),
            status: mapMangaStatus(fields["my_status"]),
            startDate: parseDate(fields["my_start_date"]),
            finishDate: parseDate(fields["my_finish_date"])
        )
    }

    private static func positiveInt(_ raw: String?) -> Int? {
        raw.flatMap(Int.init).flatMap { $0 > 0 ? $0 : nil }
    }

    private static func mapAnimeStatus(_ raw: String?) -> LibraryStatus {
        switch raw {
        case "Watching": .watching
        case "On-Hold": .onHold
        case "Completed": .completed
        case "Dropped": .dropped
        case "Plan to Watch": .planned
        default: .planned
        }
    }

    private static func mapMangaStatus(_ raw: String?) -> MangaStatus {
        switch raw {
        case "Reading": .reading
        case "On-Hold": .onHold
        case "Completed": .completed
        case "Dropped": .dropped
        case "Plan to Read": .planned
        default: .planned
        }
    }

    private static func parseDate(_ raw: String?) -> Date? {
        guard let raw, raw != "0000-00-00", !raw.isEmpty else { return nil }
        let strategy = Date.ParseStrategy(
            format: "\(year: .defaultDigits)-\(month: .twoDigits)-\(day: .twoDigits)",
            timeZone: .gmt
        )
        return try? Date(raw, strategy: strategy)
    }
}
