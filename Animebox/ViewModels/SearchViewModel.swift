//
//  SearchViewModel.swift
//  Animebox
//

import Foundation
import Observation

@Observable
final class SearchViewModel {
    enum LoadState: Equatable {
        case idle
        case searching
        case results([Anime])
        case empty
        case error(String)
    }

    var query: String = ""
    var statusFilter: SearchStatusFilter = .all
    private(set) var selectedGenreID: Int?
    private(set) var availableGenres: [NamedEntity] = []
    private(set) var isLoadingGenres: Bool = false
    private(set) var state: LoadState = .idle

    private let service: JikanServicing
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?

    init(service: JikanServicing = JikanService(), debounce: Duration = .milliseconds(300)) {
        self.service = service
        self.debounce = debounce
    }

    deinit {
        searchTask?.cancel()
    }

    func loadGenres() async {
        guard availableGenres.isEmpty, !isLoadingGenres else { return }
        isLoadingGenres = true
        defer { isLoadingGenres = false }
        do {
            availableGenres = try await service.animeGenres()
        } catch is CancellationError {
            // ignore
        } catch NetworkError.cancelled {
            // ignore
        } catch {
            // Silently degrade: chips simply won't appear. Users can still
            // search by text.
        }
    }

    func toggleGenre(_ id: Int) {
        if selectedGenreID == id {
            selectedGenreID = nil
        } else {
            selectedGenreID = id
        }
        search()
    }

    func search() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !trimmed.isEmpty
        let hasGenre = selectedGenreID != nil
        let filter = statusFilter
        let genreSnapshot = selectedGenreID

        guard hasQuery || hasGenre else {
            state = .idle
            return
        }

        searchTask = Task { [weak self] in
            guard let self else { return }
            do {
                try await Task.sleep(for: self.debounce)
            } catch {
                return
            }
            if Task.isCancelled { return }
            await self.performSearch(
                query: hasQuery ? trimmed : nil,
                status: filter.queryValue,
                genreID: genreSnapshot
            )
        }
    }

    /// Awaits any in-flight search. Intended for tests.
    func awaitCurrentSearch() async {
        await searchTask?.value
    }

    private func performSearch(query: String?, status: String?, genreID: Int?) async {
        state = .searching
        do {
            let results = try await service.searchAnime(
                query: query,
                status: status,
                genres: genreID.map { [$0] },
                limit: 25
            )
            if Task.isCancelled { return }
            let deduped = results.dedupedByMalId()
            state = deduped.isEmpty ? .empty : .results(deduped)
        } catch is CancellationError {
            // ignore
        } catch NetworkError.cancelled {
            // ignore
        } catch {
            let message = (error as? LocalizedError)?.errorDescription
                ?? error.localizedDescription
            state = .error(message)
        }
    }
}
