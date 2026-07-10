//
//  LibraryEntry.swift
//  Animebox
//

import Foundation
import SwiftData

@Model
final class LibraryEntry {
    @Attribute(.unique) var malId: Int
    var title: String
    var imageURL: String?
    var statusRaw: String
    var progress: Int
    var totalEpisodes: Int?
    var personalScore: Int?
    var animeScore: Double?
    var notes: String?
    var startDate: Date?
    var finishDate: Date?
    var updatedAt: Date

    var status: LibraryStatus {
        get { LibraryStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
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
        title: String,
        imageURL: String? = nil,
        status: LibraryStatus = .planned,
        progress: Int = 0,
        totalEpisodes: Int? = nil,
        personalScore: Int? = nil,
        animeScore: Double? = nil,
        notes: String? = nil,
        startDate: Date? = .now,
        finishDate: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.malId = malId
        self.title = title
        self.imageURL = imageURL
        self.statusRaw = status.rawValue
        self.progress = progress
        self.totalEpisodes = totalEpisodes
        self.personalScore = personalScore
        self.animeScore = animeScore
        self.notes = notes
        self.startDate = startDate
        self.finishDate = finishDate
        self.updatedAt = updatedAt
    }
}
