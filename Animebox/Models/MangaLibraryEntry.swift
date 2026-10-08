//
//  MangaLibraryEntry.swift
//  Animebox
//

import Foundation
import SwiftData

@Model
final class MangaLibraryEntry {
    /// Ya no es único en solitario — solo lo es junto con `provider` (ver
    /// `LibraryProvider`). MAL y AniList tienen espacios de IDs distintos.
    var malId: Int
    var providerRaw: String = LibraryProvider.mal.rawValue
    var title: String
    var imageURL: String?
    var statusRaw: String
    var chaptersRead: Int
    var volumesRead: Int
    var totalChapters: Int?
    var totalVolumes: Int?
    var personalScore: Int?
    var mangaScore: Double?
    /// Miembros de MAL que tienen este manga en su lista ("espectadores") —
    /// se refresca en cada `upsert`, igual que `mangaScore`.
    var members: Int?
    /// A diferencia de `updatedAt` (se toca en cada edición), esto se fija
    /// una sola vez al crear la entrada — es lo que ordena "Añadidos
    /// recientemente" sin que progresar un capítulo reordene la lista.
    var createdAt: Date?
    /// Nombres de género (no IDs) — se refresca en cada `upsert`, igual que
    /// `mangaScore`/`members`. Alimenta el desglose por género de la
    /// pantalla de estadísticas.
    var genreNames: [String]?
    var notes: String?
    var startDate: Date?
    var finishDate: Date?
    var updatedAt: Date

    var status: MangaStatus {
        get { MangaStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    var provider: LibraryProvider {
        get { LibraryProvider(rawValue: providerRaw) ?? .mal }
        set { providerRaw = newValue.rawValue }
    }

    /// Suma 1 capítulo. Si alcanza `totalChapters`, marca como completado
    /// y registra la fecha de fin si aún no estaba puesta.
    func incrementProgress() {
        let cap = totalChapters ?? Int.max
        guard chaptersRead < cap else { return }
        chaptersRead += 1
        if let total = totalChapters, chaptersRead == total {
            status = .completed
            finishDate = finishDate ?? .now
        }
        updatedAt = .now
    }

    init(
        malId: Int,
        provider: LibraryProvider = .mal,
        title: String,
        imageURL: String? = nil,
        status: MangaStatus = .planned,
        chaptersRead: Int = 0,
        volumesRead: Int = 0,
        totalChapters: Int? = nil,
        totalVolumes: Int? = nil,
        personalScore: Int? = nil,
        mangaScore: Double? = nil,
        members: Int? = nil,
        createdAt: Date? = .now,
        genreNames: [String]? = nil,
        notes: String? = nil,
        startDate: Date? = .now,
        finishDate: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.malId = malId
        self.providerRaw = provider.rawValue
        self.title = title
        self.imageURL = imageURL
        self.statusRaw = status.rawValue
        self.chaptersRead = chaptersRead
        self.volumesRead = volumesRead
        self.totalChapters = totalChapters
        self.totalVolumes = totalVolumes
        self.personalScore = personalScore
        self.mangaScore = mangaScore
        self.members = members
        self.createdAt = createdAt
        self.genreNames = genreNames
        self.notes = notes
        self.startDate = startDate
        self.finishDate = finishDate
        self.updatedAt = updatedAt
    }
}
