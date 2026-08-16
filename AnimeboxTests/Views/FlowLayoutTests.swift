//
//  FlowLayoutTests.swift
//  AnimeboxTests
//
//  Render-test con ImageRenderer: confirma que FlowLayout envuelve a varias
//  filas cuando el contenido no cabe en una sola, en vez de recortarlo o
//  desbordarse en una única fila (como hacía el ScrollView horizontal previo).
//

import SwiftUI
import Testing
@testable import Animebox

@Suite("FlowLayout")
@MainActor
struct FlowLayoutTests {

    @Test("FlowLayout envuelve en más filas cuantos más chips recibe")
    func wrapsIntoMoreRowsAsContentGrows() throws {
        let fewGenres = Array(PreviewSamples.genres.prefix(4))
        let allGenres = PreviewSamples.genres

        let shortHeight = try #require(renderedHeight(of: chipsRow(fewGenres)))
        let tallHeight = try #require(renderedHeight(of: chipsRow(allGenres)))

        #expect(
            tallHeight > shortHeight * 3,
            "Con ~65 géneros el layout debe ocupar bastantes más filas que con 4."
        )
    }

    private func chipsRow(_ genres: [NamedEntity]) -> some View {
        // collapsedLimit desactivado (= todos los elementos) para que este test
        // mida el wrap de FlowLayout, no el "Ver más" de GenreChipsRow.
        GenreChipsRow(title: "Test", genres: genres, selectedIDs: [], onTap: { _ in }, collapsedLimit: genres.count)
            .frame(width: 402)
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
