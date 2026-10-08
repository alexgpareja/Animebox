//
//  HomeSectionOrderSettings.swift
//  Animebox
//

import SwiftUI

/// Envoltorio observable de `HomeSectionOrderStore` — mismo patrón que
/// `AppLanguageSettings`, creado localmente en `HomeView` (no hace falta
/// inyectarlo en toda la app, solo Inicio lo usa).
@Observable
@MainActor
final class HomeSectionOrderSettings {
    var animeOrder: [HomeSectionSlot] {
        didSet { HomeSectionOrderStore.setOrder(animeOrder, for: .anime) }
    }
    var mangaOrder: [HomeSectionSlot] {
        didSet { HomeSectionOrderStore.setOrder(mangaOrder, for: .manga) }
    }

    init() {
        animeOrder = HomeSectionOrderStore.order(for: .anime)
        mangaOrder = HomeSectionOrderStore.order(for: .manga)
    }

    func order(for kind: MediaKind) -> [HomeSectionSlot] {
        kind == .anime ? animeOrder : mangaOrder
    }

    func move(kind: MediaKind, from offsets: IndexSet, to destination: Int) {
        switch kind {
        case .anime: animeOrder.move(fromOffsets: offsets, toOffset: destination)
        case .manga: mangaOrder.move(fromOffsets: offsets, toOffset: destination)
        }
    }
}
