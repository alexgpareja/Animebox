//
//  HomeViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class HomeViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case error(String)
    }

    private(set) var topAnime: [Anime] = []
    private(set) var currentSeason: [Anime] = []
    private(set) var state: LoadState = .idle

    private let service: ContentServicing

    init(service: ContentServicing = JikanService()) {
        self.service = service
    }

    func load() async {
        if topAnime.isEmpty && currentSeason.isEmpty {
            state = .loading
        }
        do {
            async let top = service.topAnime(limit: 25)
            async let season = service.currentSeason(limit: 25)
            let (topResult, seasonResult) = try await (top, season)
            self.topAnime = topResult.dedupedByMalId()
            self.currentSeason = seasonResult.dedupedByMalId()
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
