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
    var typeFilter: AnimeTypeFilter = .all
    var ratingFilter: AnimeRatingFilter = .all
    var yearFrom: Int?
    var yearTo: Int?
    private(set) var selectedGenreIDs: Set<Int> = []
    private(set) var availableGenres: [NamedEntity] = []
    private(set) var availableThemes: [NamedEntity] = []
    private(set) var isLoadingGenres: Bool = false
    private(set) var state: LoadState = .idle

    var hasActiveFilters: Bool {
        statusFilter != .all || typeFilter != .all || ratingFilter != .all || yearFrom != nil || yearTo != nil
    }

    private let service: ContentServicing
    private let debounce: Duration
    private var searchTask: Task<Void, Never>?

    init(service: ContentServicing = JikanService(), debounce: Duration = .milliseconds(300)) {
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
            async let genres = service.animeGenres()
            async let themes = service.animeThemes()
            (availableGenres, availableThemes) = try await (genres, themes)
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
        if selectedGenreIDs.contains(id) {
            selectedGenreIDs.remove(id)
        } else {
            selectedGenreIDs.insert(id)
        }
        search()
    }

    func search() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let hasQuery = !trimmed.isEmpty
        let hasGenres = !selectedGenreIDs.isEmpty
        let hasOtherFilters = hasActiveFilters
        let statusSnapshot = statusFilter
        let typeSnapshot = typeFilter
        let ratingSnapshot = ratingFilter
        let yearFromSnapshot = yearFrom
        let yearToSnapshot = yearTo
        let genresSnapshot = selectedGenreIDs

        guard hasQuery || hasGenres || hasOtherFilters else {
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
                status: statusSnapshot.queryValue,
                genreIDs: genresSnapshot,
                type: typeSnapshot.queryValue,
                rating: ratingSnapshot.queryValue,
                yearFrom: yearFromSnapshot,
                yearTo: yearToSnapshot
            )
        }
    }

    /// Awaits any in-flight search. Intended for tests.
    func awaitCurrentSearch() async {
        await searchTask?.value
    }

    private func performSearch(
        query: String?,
        status: String?,
        genreIDs: Set<Int>,
        type: String?,
        rating: String?,
        yearFrom: Int?,
        yearTo: Int?
    ) async {
        state = .searching
        do {
            let results = try await service.searchAnime(
                query: query,
                status: status,
                genres: genreIDs.isEmpty ? nil : Array(genreIDs),
                type: type,
                rating: rating,
                startDate: yearFrom.map { "\($0)-01-01" },
                endDate: yearTo.map { "\($0)-12-31" },
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
