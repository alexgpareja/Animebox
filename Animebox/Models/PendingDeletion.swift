//
//  PendingDeletion.swift
//  Animebox
//

import Foundation
import SwiftData

/// Recuerda un borrado hecho en modo invitado (sin sesión) hasta que haya
/// ocasión de empujarlo a MAL. Si el borrado ocurre con sesión iniciada, se
/// empuja al instante (`LibrarySyncCoordinator.deleteRemoteAnime/Manga`) y
/// nunca pasa por aquí — sin este recordatorio, `MALSyncReconciler.reconcile()`
/// al iniciar sesión volvía a traer de MAL lo que se había borrado en local,
/// porque MAL nunca se enteró del borrado.
@Model
final class PendingDeletion {
    var malId: Int
    /// El `provider` de la entrada borrada (no el que se conecte después) —
    /// un ID de MAL borrado en modo invitado solo tiene sentido empujarlo si
    /// se reconecta a MAL; empujarlo contra AniList podría, por coincidencia
    /// de espacios de ID, borrar algo sin relación. Cada reconciler solo
    /// consume las suyas.
    var providerRaw: String = LibraryProvider.mal.rawValue
    var kindRaw: String
    var deletedAt: Date

    var kind: MediaKind {
        get { MediaKind(rawValue: kindRaw) ?? .anime }
        set { kindRaw = newValue.rawValue }
    }

    var provider: LibraryProvider {
        get { LibraryProvider(rawValue: providerRaw) ?? .mal }
        set { providerRaw = newValue.rawValue }
    }

    init(malId: Int, provider: LibraryProvider = .mal, kind: MediaKind, deletedAt: Date = .now) {
        self.malId = malId
        self.providerRaw = provider.rawValue
        self.kindRaw = kind.rawValue
        self.deletedAt = deletedAt
    }
}
