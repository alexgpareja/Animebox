//
//  LinkedAccount.swift
//  Animebox
//

import Foundation

/// Sustituye a `MALSession` como lo que se inyecta en la raíz y se lee en
/// cada vista para enrutar (`ContentRouter`/`LibrarySyncCoordinator`) — una
/// sola cuenta oficial activa a la vez (MAL *o* AniList, decisión ya
/// tomada), nunca ambas. `mal`/`aniList` siguen siendo los objetos que
/// conocen los detalles de cada proveedor (username, `lastSyncError`,
/// `signIn()`/`signOut()`); esto solo decide cuál de los dos manda.
@Observable
@MainActor
final class LinkedAccount {
    let mal: MALSession
    let aniList: AniListSession

    init(mal: MALSession, aniList: AniListSession) {
        self.mal = mal
        self.aniList = aniList
    }

    var isSignedIn: Bool { activeProvider != nil }

    /// Proveedor cuyas entradas locales se muestran: el de la cuenta activa,
    /// o `.mal` en modo invitado (Tenrai comparte el espacio de IDs de MAL).
    /// Sin este filtro, una serie guardada antes con otro proveedor aparece
    /// duplicada junto a la que se descarga al iniciar sesión.
    var libraryProvider: LibraryProvider { activeProvider ?? .mal }

    /// Si por algún motivo ambas sesiones tuvieran tokens válidos a la vez
    /// (no debería pasar — la UI de Ajustes cierra una antes de abrir la
    /// otra), MAL gana por ser la que existía primero. No es una elección
    /// del usuario, es solo una salvaguarda determinista.
    var activeProvider: LibraryProvider? {
        if mal.isSignedIn { return .mal }
        if aniList.isSignedIn { return .aniList }
        return nil
    }

    var lastSyncError: String? {
        get {
            switch activeProvider {
            case .mal: mal.lastSyncError
            case .aniList: aniList.lastSyncError
            case nil: nil
            }
        }
        set {
            switch activeProvider {
            case .mal: mal.lastSyncError = newValue
            case .aniList: aniList.lastSyncError = newValue
            case nil: break
            }
        }
    }
}
