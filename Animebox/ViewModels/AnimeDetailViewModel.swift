//
//  AnimeDetailViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class AnimeDetailViewModel {
    enum LoadState: Equatable {
        case idle
        case refreshing
        case refreshed
        case error(String)
    }

    private(set) var anime: Anime
    private(set) var state: LoadState = .idle

    private let service: ContentServicing

    init(initialAnime: Anime, service: ContentServicing = JikanService()) {
        self.anime = initialAnime
        self.service = service
    }

    func refreshDetails() async {
        guard state != .refreshing else { return }
        state = .refreshing
        do {
            let full = try await service.animeDetails(id: anime.malId)
            self.anime = full
            self.state = .refreshed
        } catch is CancellationError {
            state = .idle
        } catch NetworkError.cancelled {
            state = .idle
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            self.state = .error(message)
        }
    }
}
