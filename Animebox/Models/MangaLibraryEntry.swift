//
//  MangaLibraryEntry.swift
//  Animebox
//

import Foundation
import SwiftData

@Model
final class MangaLibraryEntry {
    @Attribute(.unique) var malId: Int
    var title: String
    var imageURL: String?
    var statusRaw: String
    var chaptersRead: Int
    var volumesRead: Int
    var totalChapters: Int?
    var totalVolumes: Int?
    var personalScore: Int?
    var mangaScore: Double?
    var notes: String?
    var startDate: Date?
    var finishDate: Date?
    var updatedAt: Date

    var status: MangaStatus {
        get { MangaStatus(rawValue: statusRaw) ?? .planned }
        set { statusRaw = newValue.rawValue }
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
        title: String,
        imageURL: String? = nil,
        status: MangaStatus = .planned,
        chaptersRead: Int = 0,
        volumesRead: Int = 0,
        totalChapters: Int? = nil,
        totalVolumes: Int? = nil,
        personalScore: Int? = nil,
        mangaScore: Double? = nil,
        notes: String? = nil,
        startDate: Date? = .now,
        finishDate: Date? = nil,
        updatedAt: Date = .now
    ) {
        self.malId = malId
        self.title = title
        self.imageURL = imageURL
        self.statusRaw = status.rawValue
        self.chaptersRead = chaptersRead
        self.volumesRead = volumesRead
        self.totalChapters = totalChapters
        self.totalVolumes = totalVolumes
        self.personalScore = personalScore
        self.mangaScore = mangaScore
        self.notes = notes
        self.startDate = startDate
        self.finishDate = finishDate
        self.updatedAt = updatedAt
    }
}
