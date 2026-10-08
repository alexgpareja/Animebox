//
//  AniListConfig.swift
//  Animebox
//

import Foundation

/// Configuración fija de la API de AniList. `clientID` se lee del Info.plist
/// generado (`AniListClientID`, cableado desde `Animebox/Config/Secrets.xcconfig`,
/// fuera de git) — vacío hasta que ese fichero exista. A diferencia de MAL,
/// no hay `clientSecret`: el Implicit Grant no lo necesita.
nonisolated enum AniListConfig {
    static let authorizeURL = URL(string: "https://anilist.co/api/v2/oauth/authorize")!
    static let graphQLURL = URL(string: "https://graphql.anilist.co")!
    /// Distinto del `redirectURI` de MAL aunque comparten el mismo scheme
    /// `animebox` ya registrado en Info.plist — así el callback de cada
    /// proveedor se distingue sin ambigüedad al volver de `ASWebAuthenticationSession`.
    static let redirectURI = URL(string: "animebox://anilist-callback")!
    static let redirectURIScheme = "animebox"

    static var clientID: String {
        Bundle.main.object(forInfoDictionaryKey: "AniListClientID") as? String ?? ""
    }
}
