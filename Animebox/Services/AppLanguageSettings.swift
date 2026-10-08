//
//  AppLanguageSettings.swift
//  Animebox
//

import Foundation

/// Envoltorio observable de `AppLanguage.current` — mismo patrón que
/// `MALSession`: una única instancia creada en `AnimeboxApp.swift` e
/// inyectada vía `.environment(...)`, para que cambiar el idioma en Ajustes
/// dispare un refresco de toda la jerarquía de vistas (incluida
/// `.environment(\.locale:)` en la raíz, que es lo que resuelve `Text("...")`
/// y `LocalizedStringKey`).
@Observable
@MainActor
final class AppLanguageSettings {
    var language: AppLanguage {
        didSet { AppLanguage.current = language }
    }

    init() {
        language = AppLanguage.current
    }
}
