//
//  MangaLibraryEmptyState.swift
//  Animebox
//

import SwiftUI

struct MangaLibraryEmptyState: View {
    let status: MangaStatus

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(description)
        )
    }

    private var title: LocalizedStringKey {
        switch status {
        case .reading: "Aún no estás leyendo nada"
        case .onHold: "No tienes mangas en pausa"
        case .completed: "Aún no has completado ningún manga"
        case .dropped: "No has abandonado ningún manga"
        case .planned: "Tu lista de pendientes está vacía"
        }
    }

    private var description: LocalizedStringKey {
        switch status {
        case .reading: "Añade desde el detalle de cualquier manga."
        case .onHold: "Aquí aparecerán los mangas que pongas en pausa."
        case .completed: "Cuando termines un manga, márcalo como completado."
        case .dropped: "Aquí aparecerán los mangas que dejes a medias."
        case .planned: "Guarda mangas que quieras leer más adelante."
        }
    }

    private var icon: String {
        switch status {
        case .reading: "book"
        case .onHold: "pause.rectangle"
        case .completed: "checkmark.seal"
        case .dropped: "xmark.bin"
        case .planned: "bookmark"
        }
    }
}
