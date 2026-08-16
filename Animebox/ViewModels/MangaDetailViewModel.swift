//
//  MangaDetailViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class MangaDetailViewModel {
    enum LoadState: Equatable {
        case idle
        case refreshing
        case refreshed
        case error(String)
    }

    private(set) var manga: Manga
    private(set) var state: LoadState = .idle

    private let service: ContentServicing

    init(initialManga: Manga, service: ContentServicing = JikanService()) {
        self.manga = initialManga
        self.service = service
    }

    func refreshDetails() async {
        guard state == .idle else { return }
        state = .refreshing
        do {
            let full = try await service.mangaDetails(id: manga.malId)
            self.manga = full
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
