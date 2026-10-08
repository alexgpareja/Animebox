//
//  MangaPublishingStatus.swift
//  Animebox
//

import Foundation

/// Normaliza el campo `status` crudo de `Manga` a una etiqueta localizada.
/// Ver `AnimeAiringStatus` — mismo motivo (tres vocabularios según el backend
/// que respondió, incluyendo AniList en SCREAMING_SNAKE_CASE), aquí con los
/// valores de manga. AniList reusa el mismo enum `MediaStatus` para anime y
/// manga, así que `CANCELLED`/`HIATUS` mapean a los casos ya existentes
/// `discontinued`/`onHiatus` en vez de necesitar casos nuevos.
enum MangaPublishingStatus: Equatable {
    case publishing
    case finished
    case onHiatus
    case discontinued
    case notYetPublished

    init?(apiValue: String) {
        switch apiValue {
        case "Publishing", "currently_publishing", "RELEASING": self = .publishing
        case "Finished", "finished", "FINISHED": self = .finished
        case "On Hiatus", "on_hiatus", "HIATUS": self = .onHiatus
        case "Discontinued", "discontinued", "CANCELLED": self = .discontinued
        case "Not yet published", "not_yet_published", "NOT_YET_RELEASED": self = .notYetPublished
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .publishing: AppLanguage.current.string("Publicándose")
        case .finished: AppLanguage.current.string("Finalizado")
        case .onHiatus: AppLanguage.current.string("En pausa")
        case .discontinued: AppLanguage.current.string("Descontinuado")
        case .notYetPublished: AppLanguage.current.string("Aún no publicado")
        }
    }
}
