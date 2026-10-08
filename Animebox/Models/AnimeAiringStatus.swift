//
//  AnimeAiringStatus.swift
//  Animebox
//

import Foundation

/// Normaliza el campo `status` crudo de `Anime` a una etiqueta localizada.
/// El valor crudo llega en tres vocabularios distintos según quién respondió
/// (`ContentRouter`): Jikan usa Title Case ("Currently Airing"), MAL v2 usa
/// snake_case ("currently_airing"), AniList usa SCREAMING_SNAKE_CASE
/// ("RELEASING") y además distingue `CANCELLED`/`HIATUS`, sin equivalente en
/// los otros dos backends. Valores no reconocidos no rompen la UI —
/// `AnimeDetailInfoRow` cae de vuelta al texto crudo.
enum AnimeAiringStatus: Equatable {
    case airing
    case finished
    case notYetAired
    case cancelled
    case onHiatus

    init?(apiValue: String) {
        switch apiValue {
        case "Currently Airing", "currently_airing", "RELEASING": self = .airing
        case "Finished Airing", "finished_airing", "FINISHED": self = .finished
        case "Not yet aired", "not_yet_aired", "NOT_YET_RELEASED": self = .notYetAired
        case "CANCELLED": self = .cancelled
        case "HIATUS": self = .onHiatus
        default: return nil
        }
    }

    var displayName: String {
        switch self {
        case .airing: AppLanguage.current.string("Emitiéndose")
        case .finished: AppLanguage.current.string("Finalizado")
        case .notYetAired: AppLanguage.current.string("Aún no emitido")
        case .cancelled: AppLanguage.current.string("Cancelado")
        case .onHiatus: AppLanguage.current.string("En pausa")
        }
    }
}
