//
//  LibraryStatusTests.swift
//  AnimeboxTests
//

import Testing
@testable import Animebox

struct LibraryStatusTests {

    @Test("LibraryStatus expone nombres legibles", arguments: [
        (LibraryStatus.watching, "Viendo"),
        (LibraryStatus.completed, "Completado"),
        (LibraryStatus.dropped, "Abandonado"),
        (LibraryStatus.planned, "Planeado"),
    ])
    func displayName(status: LibraryStatus, expected: String) {
        #expect(status.displayName == expected)
    }
}
