//
//  MangaHomeViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class MangaHomeViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    private(set) var topManga: [Manga] = []
    private(set) var currentlyPublishing: [Manga] = []
    private(set) var state: LoadState = .idle

    private let service: ContentServicing

    init(service: ContentServicing = JikanService()) {
        self.service = service
    }

    func load() async {
        if topManga.isEmpty && currentlyPublishing.isEmpty {
            state = .loading
        }
        do {
            async let top = service.topManga(limit: 25)
            async let publishing = service.currentlyPublishingManga(limit: 25)
            let (topResult, publishingResult) = try await (top, publishing)
            self.topManga = topResult.dedupedByMalId()
            self.currentlyPublishing = publishingResult.dedupedByMalId()
            self.state = .loaded
        } catch is CancellationError {
            // view lifecycle cancellation — ignore
        } catch NetworkError.cancelled {
            // request cancelled by APIService — ignore
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            self.state = .error(message)
        }
    }

    func refresh() async {
        await load()
    }
}
