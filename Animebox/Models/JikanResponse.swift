//
//  JikanResponse.swift
//  Animebox
//

import Foundation

nonisolated struct JikanListResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let data: [T]
    let pagination: JikanPagination?
}

nonisolated struct JikanSingleResponse<T: Decodable & Sendable>: Decodable, Sendable {
    let data: T
}

nonisolated struct JikanPagination: Decodable, Sendable {
    let lastVisiblePage: Int?
    let hasNextPage: Bool?
    let currentPage: Int?
    let items: JikanPaginationItems?

    enum CodingKeys: String, CodingKey {
        case lastVisiblePage = "last_visible_page"
        case hasNextPage = "has_next_page"
        case currentPage = "current_page"
        case items
    }
}

nonisolated struct JikanPaginationItems: Decodable, Sendable {
    let count: Int?
    let total: Int?
    let perPage: Int?

    enum CodingKeys: String, CodingKey {
        case count, total
        case perPage = "per_page"
    }
}
