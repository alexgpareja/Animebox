//
//  LibraryEntry.swift
//  Animebox
//

import Foundation
import SwiftData

@Model
final class LibraryEntry {
    /// Ya no es único en solitario — solo lo es junto con `provider` (ver
    /// `LibraryProvider`). MAL y AniList tienen espacios de IDs distintos.
    var malId: Int
    var providerRaw: String = LibraryProvider.mal.rawValue
    var title: String
    var imageURL: String?
    var statusRaw: String
    var progress: Int
    var totalEpisodes: Int?
    var personalScore: Int?
    var animeScore: Double?
    /// Miembros de MAL que tienen este anime en su lista ("espectadores") —
    /// se refresca en cada `upsert`, igual que `animeScore`.
    var members: Int?
    /// A diferencia de `updatedAt` (se toca en cada edición), esto se fija
    /// una sola vez al crear la entrada — es lo que ordena "Añadidos
    /// recientemente" sin que progresar un episodio reordene la lista.
    var createdAt: Date?
    /// Nombres de género (no IDs) — se refresca en cada `upsert`, igual que
    /// `animeScore`/`members`. Alimenta el desglose por género de la
    /// pantalla de estadísticas.
    var genreNames: [String]?
    var notes: String?
    var startDate: Date?
    var finishDate: Date?
    var updatedAt: Date

    var status: LibraryStatus {
        get { LibraryStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
    }

    var provider: LibraryProvider {
        get { LibraryProvider(rawValue: providerRaw) ?? .mal }
        set { providerRaw = newValue.rawValue }
    }

    /// Suma 1 episodio. Si alcanza el `totalEpisodes`, marca como completado
    /// y registra la fecha de fin si aún no estaba puesta.
    func incrementProgress() {
        let cap = totalEpisodes ?? Int.max
        guard progress < cap else { return }
        progress += 1
        if let total = totalEpisodes, progress == total {
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
        status: LibraryStatus = .planned,
        progress: Int = 0,
        totalEpisodes: Int? = nil,
        personalScore: Int? = nil,
        animeScore: Double? = nil,
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
        self.progress = progress
        self.totalEpisodes = totalEpisodes
        self.personalScore = personalScore
        self.animeScore = animeScore
        self.members = members
        self.createdAt = createdAt
        self.genreNames = genreNames
        self.notes = notes
        self.startDate = startDate
        self.finishDate = finishDate
        self.updatedAt = updatedAt
    }
}
