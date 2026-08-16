//
//  MALConfig.swift
//  Animebox
//

import Foundation

/// Configuración fija de la API oficial de MyAnimeList. `clientID`/`clientSecret`
/// se leen del Info.plist generado (`INFOPLIST_KEY_MALClientID`/`MALClientSecret`,
/// cableados desde `Animebox/Config/Secrets.xcconfig`, fuera de git) — vacíos
/// hasta que ese fichero exista.
nonisolated enum MALConfig {
    static let authorizeURL = URL(string: "https://myanimelist.net/v1/oauth2/authorize")!
    static let tokenURL = URL(string: "https://myanimelist.net/v1/oauth2/token")!
    static let baseURL = URL(string: "https://api.myanimelist.net/v2")!
    static let redirectURI = URL(string: "animebox://oauth-callback")!
    static let redirectURIScheme = "animebox"

    static var clientID: String {
        Bundle.main.object(forInfoDictionaryKey: "MALClientID") as? String ?? ""
    }

    static var clientSecret: String {
        Bundle.main.object(forInfoDictionaryKey: "MALClientSecret") as? String ?? ""
    }
}
