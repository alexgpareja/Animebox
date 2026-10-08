//
//  AppLanguage.swift
//  Animebox
//

import Foundation

/// Selector de idioma manual (Ajustes > Idioma), independiente del idioma
/// del sistema. `current` es la fuente de verdad — se lee directamente de
/// `UserDefaults` (no solo desde el `@Observable` de abajo) para que los
/// `displayName` de los enums de dominio (`LibraryStatus`, `AnimeTypeFilter`,
/// `GenreLocalization`...) puedan resolver el idioma correcto pasando
/// `locale:` explícito a `String(localized:)` sin depender del entorno de
/// SwiftUI, que no llega a código fuera de una `View`.
enum AppLanguage: String, CaseIterable, Identifiable, Sendable {
    case spanish = "es"
    case english = "en"

    var id: String { rawValue }
    var locale: Locale { Locale(identifier: rawValue) }

    var displayName: String {
        switch self {
        case .spanish: "Español"
        case .english: "English"
        }
    }

    /// Si el idioma preferido del dispositivo es español, arranca en
    /// español; para cualquier otro (todavía no soportamos más idiomas),
    /// cae a inglés en vez de forzar español a un usuario que no lo pidió.
    static var systemPreferred: AppLanguage {
        (Locale.preferredLanguages.first?.hasPrefix("es") ?? false) ? .spanish : .english
    }

    private static let storageKey = "appLanguage"
    /// El mismo App Group que ya comparte el store de SwiftData con
    /// `AnimeboxWidget` (ver `AnimeboxApp.swift`) — así el widget resuelve
    /// sus propios `String(localized:)` en el idioma elegido en Ajustes en
    /// vez de quedarse siempre en el idioma del sistema.
    private static let defaults = UserDefaults(suiteName: "group.Alexdev.Animebox") ?? .standard

    static var current: AppLanguage {
        get {
            defaults.string(forKey: storageKey).flatMap(AppLanguage.init) ?? systemPreferred
        }
        set { defaults.set(newValue.rawValue, forKey: storageKey) }
    }

    /// `String(localized:locale:)`'s `locale:` parameter does not reliably
    /// force a *different* `.lproj` table than whatever the bundle already
    /// considers its preferred localization — confirmed by testing (the
    /// override was silently ignored, always resolving the base/Spanish
    /// string). Loading the target `.lproj` bundle directly and asking it
    /// for the string is the well-established, reliable way to force one
    /// specific language regardless of system/device settings.
    func string(_ key: String) -> String {
        guard let path = Bundle.main.path(forResource: rawValue, ofType: "lproj"),
              let bundle = Bundle(path: path) else {
            return key
        }
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
}
