//
//  LibraryEntryTests.swift
//  AnimeboxTests
//

import Foundation
import Testing
@testable import Animebox

@MainActor
struct LibraryEntryTests {

    @Test("incrementProgress promueve a .completed al alcanzar el último episodio")
    func promotesToCompletedOnLastEpisode() {
        let entry = LibraryEntry(
            malId: 1, title: "x",
            status: .watching, progress: 11, totalEpisodes: 12,
            finishDate: nil
        )
        entry.incrementProgress()

        #expect(entry.progress == 12)
        #expect(entry.status == .completed)
        #expect(entry.finishDate != nil)
    }

    @Test("incrementProgress preserva un finishDate existente al promover")
    func keepsExistingFinishDateWhenPromoting() {
        let prior = Date(timeIntervalSince1970: 1_000_000)
        let entry = LibraryEntry(
            malId: 1, title: "x",
            status: .watching, progress: 11, totalEpisodes: 12,
            finishDate: prior
        )
        entry.incrementProgress()

        #expect(entry.status == .completed)
        #expect(entry.finishDate == prior)
    }

    @Test("incrementProgress no promueve si aún no es el último episodio")
    func doesNotPromoteMidway() {
        let entry = LibraryEntry(
            malId: 1, title: "x",
            status: .watching, progress: 5, totalEpisodes: 12
        )
        entry.incrementProgress()

        #expect(entry.progress == 6)
        #expect(entry.status == .watching)
        #expect(entry.finishDate == nil)
    }

    @Test("incrementProgress no pasa del total")
    func capsAtTotalEpisodes() {
        let entry = LibraryEntry(
            malId: 1, title: "x",
            status: .completed, progress: 12, totalEpisodes: 12
        )
        entry.incrementProgress()

        #expect(entry.progress == 12)
    }

    @Test("incrementProgress sin totalEpisodes solo suma, no promueve")
    func withoutTotalEpisodesDoesNotPromote() {
        let entry = LibraryEntry(
            malId: 1, title: "x",
            status: .watching, progress: 5, totalEpisodes: nil
        )
        entry.incrementProgress()

        #expect(entry.progress == 6)
        #expect(entry.status == .watching)
    }
}
