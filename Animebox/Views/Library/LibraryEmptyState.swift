//
//  LibraryEmptyState.swift
//  Animebox
//

import SwiftUI

struct LibraryEmptyState: View {
    let status: LibraryStatus

    var body: some View {
        ContentUnavailableView(
            title,
            systemImage: icon,
            description: Text(description)
        )
    }

    private var title: LocalizedStringKey {
        switch status {
        case .watching: "Aún no estás viendo nada"
        case .completed: "Aún no has completado ningún anime"
        case .dropped: "No has abandonado ningún anime"
        case .planned: "Tu lista de pendientes está vacía"
        }
    }

    private var description: LocalizedStringKey {
        switch status {
        case .watching: "Añade desde el detalle de cualquier anime."
        case .completed: "Cuando termines un anime, márcalo como completado."
        case .dropped: "Aquí aparecerán los animes que dejes a medias."
        case .planned: "Guarda animes que quieras ver más adelante."
        }
    }

    private var icon: String {
        switch status {
        case .watching: "play.rectangle"
        case .completed: "checkmark.seal"
        case .dropped: "xmark.bin"
        case .planned: "bookmark"
        }
    }
}
