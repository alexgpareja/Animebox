//
//  MALLibrarySyncingSpy.swift
//  AnimeboxTests
//

import Foundation
@testable import Animebox

@MainActor
final class MALLibrarySyncingSpy: MALLibrarySyncing {
    private(set) var pushedAnimeStatuses: [(malId: Int, status: LibraryStatus, progress: Int, score: Int?)] = []
    private(set) var pushedMangaStatuses: [(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?)] = []
    private(set) var deletedAnimeIDs: [Int] = []
    private(set) var deletedMangaIDs: [Int] = []

    var animeToPull: [MALPulledAnimeEntry] = []
    var mangaToPull: [MALPulledMangaEntry] = []
    var pushErrorToThrow: Error?

    func pushAnimeStatus(malId: Int, status: LibraryStatus, progress: Int, score: Int?) async throws {
        if let pushErrorToThrow { throw pushErrorToThrow }
        pushedAnimeStatuses.append((malId, status, progress, score))
    }

    func pushMangaStatus(malId: Int, status: MangaStatus, chaptersRead: Int, volumesRead: Int, score: Int?) async throws {
        if let pushErrorToThrow { throw pushErrorToThrow }
        pushedMangaStatuses.append((malId, status, chaptersRead, volumesRead, score))
    }

    func deleteAnimeStatus(malId: Int) async throws {
        deletedAnimeIDs.append(malId)
    }

    func deleteMangaStatus(malId: Int) async throws {
        deletedMangaIDs.append(malId)
    }

    func pullAnimeList() async throws -> [MALPulledAnimeEntry] {
        animeToPull
    }

    func pullMangaList() async throws -> [MALPulledMangaEntry] {
        mangaToPull
    }
}
