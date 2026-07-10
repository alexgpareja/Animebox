//
//  AnimeCardLayoutTests.swift
//  AnimeboxTests
//
//  Render-tests con ImageRenderer para validar que las cards mantienen
//  la misma altura con o sin score. Sustituye a un UI test, ya que
//  Swift Testing no soporta tests de UI.
//

import SwiftUI
import Testing
@testable import Animebox

@Suite("AnimeCard layout consistency")
@MainActor
struct AnimeCardLayoutTests {

    @Test("AnimeCard mantiene la misma altura con o sin score")
    func animeCardHeightIsConsistentWithOrWithoutScore() throws {
        let withScore = AnimeCard(anime: .fixture(id: 1, title: "Con score", score: 8.50))
        let withoutScore = AnimeCard(anime: .fixture(id: 2, title: "Sin score", score: nil))

        let heightA = try #require(renderedHeight(of: withScore))
        let heightB = try #require(renderedHeight(of: withoutScore))

        #expect(
            abs(heightA - heightB) < 1.0,
            "Cards con y sin score deben renderizar con la misma altura para evitar huecos en el LazyHStack."
        )
    }

    @Test("AnimeCard reserva 2 líneas de título aunque el texto sea corto")
    func animeCardReservesSpaceForTwoLineTitle() throws {
        let shortTitle = AnimeCard(anime: .fixture(id: 1, title: "X", score: 8.0))
        let longTitle = AnimeCard(anime: .fixture(
            id: 2,
            title: "Un título largo que va a romper a dos líneas seguro",
            score: 8.0
        ))

        let heightShort = try #require(renderedHeight(of: shortTitle))
        let heightLong = try #require(renderedHeight(of: longTitle))

        #expect(
            abs(heightShort - heightLong) < 1.0,
            "Títulos de 1 y 2 líneas deben renderizar con la misma altura gracias a lineLimit(2, reservesSpace: true)."
        )
    }

    private func renderedHeight(of view: some View) -> CGFloat? {
        let renderer = ImageRenderer(content: view)
#if canImport(UIKit)
        return renderer.uiImage?.size.height
#elseif canImport(AppKit)
        return renderer.nsImage?.size.height
#else
        return nil
#endif
    }
}
