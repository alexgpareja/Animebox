//
//  AniListLibrarySyncing.swift
//  Animebox
//

import Foundation

/// Conforma al protocolo ya existente `MALLibrarySyncing` — sus métodos ya
/// son agnósticos de backend, no hace falta renombrarlo para dar cabida a
/// un segundo proveedor.
///
/// **Normalización de puntuación**: la puntuación de AniList es configurable
/// por usuario (`ScoreFormat`: POINT_100/POINT_10/POINT_5/POINT_3...), pero
/// tanto el campo `MediaList.score(format:)` como el parámetro de mutación
/// `scoreRaw` de `SaveMediaListEntry` permiten forzar/enviar siempre en
/// escala 0-100 sin importar la preferencia del usuario — así que no hace
/// falta leer ni cachear su `scoreFormat`, solo escalar ×10 al empujar y ÷10
/// al leer, contra la escala fija 0-10 que usa el resto de la app.
///
/// `MediaListStatus.REPEATING` (sin equivalente local) se lee como
/// `.watching`/`.reading`; nunca se escribe ese valor.
struct AniListLibrarySyncService: MALLibrarySyncing {
    let api: AniListAPIService

    init(aniListSession: AniListSession) {
        self.api = AniListAPIService(aniListSession: aniListSession)
    }

    func pushAnimeStatus(malId: Int, status: LibraryStatus, progress: Int, score: Int?) async throws {
        try await save(mediaId: malId, status: status.aniListStatus, progress: progress, score: score)
    }

    func pushMangaStatus(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) async throws {
        try await save(
            mediaId: malId, status: status.aniListStatus, progress: chaptersRead,
            progressVolumes: volumesRead, score: score
        )
    }

    func deleteAnimeStatus(malId: Int) async throws {
        try await delete(mediaId: malId)
    }

    func deleteMangaStatus(malId: Int) async throws {
        try await delete(mediaId: malId)
    }

    func pullAnimeList() async throws -> [MALPulledAnimeEntry] {
        try await pullCollection(type: "ANIME").compactMap { entry in
            guard let status = LibraryStatus(aniListStatus: entry.status), let media = entry.media else { return nil }
            return MALPulledAnimeEntry(
                anime: Anime(aniListNode: media),
                status: status,
                progress: entry.progress ?? 0,
                score: Self.normalizedScore(entry.score),
                startDate: nil,
                finishDate: nil
            )
        }
    }

    func pullMangaList() async throws -> [MALPulledMangaEntry] {
        try await pullCollection(type: "MANGA").compactMap { entry in
            guard let status = MangaStatus(aniListStatus: entry.status), let media = entry.media else { return nil }
            return MALPulledMangaEntry(
                manga: Manga(aniListNode: media),
                status: status,
                chaptersRead: entry.progress ?? 0,
                volumesRead: 0,
                score: Self.normalizedScore(entry.score),
                startDate: nil,
                finishDate: nil
            )
        }
    }

    // MARK: - Privado

    private func save(
        mediaId: Int, status: String, progress: Int, progressVolumes: Int? = nil, score: Int?
    ) async throws {
        var variables: [String: Any] = ["mediaId": mediaId, "status": status, "progress": progress]
        if let progressVolumes { variables["progressVolumes"] = progressVolumes }
        if let score { variables["scoreRaw"] = score * 10 }
        let query = """
        mutation ($mediaId: Int, $status: MediaListStatus, $progress: Int, $progressVolumes: Int, $scoreRaw: Int) {
            SaveMediaListEntry(mediaId: $mediaId, status: $status, progress: $progress, progressVolumes: $progressVolumes, scoreRaw: $scoreRaw) {
                id
            }
        }
        """
        _ = try await api.graphQL(
            query: query, variables: variables, authenticated: true, as: AniListSaveMediaListEntryResponse.self
        )
    }

    private func delete(mediaId: Int) async throws {
        // Hace falta el id de la entrada de lista (no el de media) para
        // borrar — se resuelve primero vía `mediaListEntry` en `Media`.
        let lookupQuery = """
        query ($id: Int!) {
            Media(id: $id) {
                mediaListEntry { id status }
            }
        }
        """
        let lookup = try await api.graphQL(
            query: lookupQuery, variables: ["id": mediaId], authenticated: true, as: AniListMediaResponse.self
        )
        guard let entryId = lookup.Media.mediaListEntry?.id else { return }
        let deleteQuery = """
        mutation ($id: Int!) {
            DeleteMediaListEntry(id: $id) {
                deleted
            }
        }
        """
        _ = try await api.graphQL(
            query: deleteQuery, variables: ["id": entryId], authenticated: true, as: AniListDeleteResponse.self
        )
    }

    private func pullCollection(type: String) async throws -> [AniListMediaListEntry] {
        let query = """
        query ($type: MediaType!, $userId: Int!) {
            MediaListCollection(type: $type, userId: $userId) {
                lists {
                    entries {
                        id
                        status
                        progress
                        score(format: POINT_100)
                        media {
                            \(Self.mediaFieldsForList)
                        }
                    }
                }
            }
        }
        """
        let userId = try await fetchViewerId()
        let response = try await api.graphQL(
            query: query, variables: ["type": type, "userId": userId], authenticated: true,
            as: AniListMediaListCollectionResponse.self
        )
        return response.MediaListCollection.lists.flatMap(\.entries)
    }

    private func fetchViewerId() async throws -> Int {
        let query = "query { Viewer { id name } }"
        let response = try await api.graphQL(query: query, authenticated: true, as: AniListViewerResponse.self)
        return response.Viewer.id
    }

    private static let mediaFieldsForList = """
    id
    title { romaji english native }
    coverImage { large medium }
    format
    status
    description
    averageScore
    popularity
    episodes
    chapters
    volumes
    genres
    startDate { year month day }
    """

    private static func normalizedScore(_ raw: Double?) -> Int? {
        guard let raw, raw > 0 else { return nil }
        return Int((raw / 10).rounded())
    }
}

nonisolated struct AniListDeleteResponse: Decodable, Sendable {
    let DeleteMediaListEntry: AniListDeletedFlag
}

nonisolated struct AniListDeletedFlag: Decodable, Sendable {
    let deleted: Bool
}

private extension LibraryStatus {
    var aniListStatus: String {
        switch self {
        case .watching: "CURRENT"
        case .onHold: "PAUSED"
        case .completed: "COMPLETED"
        case .dropped: "DROPPED"
        case .planned: "PLANNING"
        }
    }

    init?(aniListStatus raw: String?) {
        switch raw {
        case "CURRENT", "REPEATING": self = .watching
        case "PAUSED": self = .onHold
        case "COMPLETED": self = .completed
        case "DROPPED": self = .dropped
        case "PLANNING": self = .planned
        default: return nil
        }
    }
}

private extension MangaStatus {
    var aniListStatus: String {
        switch self {
        case .reading: "CURRENT"
        case .onHold: "PAUSED"
        case .completed: "COMPLETED"
        case .dropped: "DROPPED"
        case .planned: "PLANNING"
        }
    }

    init?(aniListStatus raw: String?) {
        switch raw {
        case "CURRENT", "REPEATING": self = .reading
        case "PAUSED": self = .onHold
        case "COMPLETED": self = .completed
        case "DROPPED": self = .dropped
        case "PLANNING": self = .planned
        default: return nil
        }
    }
}
