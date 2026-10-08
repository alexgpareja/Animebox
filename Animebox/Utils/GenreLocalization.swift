//
//  GenreLocalization.swift
//  Animebox
//

import Foundation

/// Los ~70 nombres de género/tema únicos de `MALGenres.swift` (y los que
/// llegan tal cual en `Anime.genres`/`Manga.genres` desde la API) están en
/// inglés — es el `name` que se usa para hacer match/filtrar y el que se
/// persiste en `LibraryEntry.genreNames`, así que no se puede tocar. Esto
/// solo traduce lo que se muestra en pantalla; un nombre no reconocido cae
/// de vuelta al texto crudo en inglés, igual que `AnimeAiringStatus`.
enum GenreLocalization {
    static func localizedName(for name: String) -> String {
        guard let spanish = table[name] else { return name }
        return AppLanguage.current.string(spanish)
    }

    static func isKnown(_ name: String) -> Bool {
        table[name] != nil
    }

    private static let table: [String: String] = [
        "Action": "Acción",
        "Adult Cast": "Reparto Adulto",
        "Adventure": "Aventura",
        "Anthropomorphic": "Antropomórfico",
        "Avant Garde": "Vanguardista",
        "Award Winning": "Premiada",
        "Boys Love": "Boys Love",
        "CGDCT": "CGDCT",
        "Childcare": "Cuidado Infantil",
        "Combat Sports": "Deportes de Combate",
        "Comedy": "Comedia",
        "Crossdressing": "Travestismo",
        "Delinquents": "Delincuentes",
        "Detective": "Detectives",
        "Drama": "Drama",
        "Educational": "Educativo",
        "Fantasy": "Fantasía",
        "Gag Humor": "Humor Gag",
        "Girls Love": "Girls Love",
        "Gore": "Gore",
        "Gourmet": "Gourmet",
        "Harem": "Harem",
        "High Stakes Game": "Juegos de Alto Riesgo",
        "Historical": "Histórico",
        "Horror": "Terror",
        "Idols (Female)": "Idols (Femenino)",
        "Idols (Male)": "Idols (Masculino)",
        "Isekai": "Isekai",
        "Iyashikei": "Iyashikei",
        "Love Polygon": "Polígono Amoroso",
        "Love Status Quo": "Statu Quo Amoroso",
        "Magical Sex Shift": "Cambio de Sexo Mágico",
        "Mahou Shoujo": "Chica Mágica",
        "Martial Arts": "Artes Marciales",
        "Mecha": "Mecha",
        "Medical": "Médico",
        "Memoir": "Memorias",
        "Military": "Militar",
        "Music": "Música",
        "Mystery": "Misterio",
        "Mythology": "Mitología",
        "Organized Crime": "Crimen Organizado",
        "Otaku Culture": "Cultura Otaku",
        "Parody": "Parodia",
        "Performing Arts": "Artes Escénicas",
        "Pets": "Mascotas",
        "Psychological": "Psicológico",
        "Racing": "Carreras",
        "Reincarnation": "Reencarnación",
        "Reverse Harem": "Harem Inverso",
        "Romance": "Romance",
        "Samurai": "Samurái",
        "School": "Escolar",
        "Sci-Fi": "Ciencia Ficción",
        "Showbiz": "Mundo del Espectáculo",
        "Slice of Life": "Recuentos de la Vida",
        "Space": "Espacio",
        "Sports": "Deportes",
        "Strategy Game": "Juego de Estrategia",
        "Super Power": "Superpoderes",
        "Supernatural": "Sobrenatural",
        "Survival": "Supervivencia",
        "Suspense": "Suspenso",
        "Team Sports": "Deportes de Equipo",
        "Time Travel": "Viajes en el Tiempo",
        "Urban Fantasy": "Fantasía Urbana",
        "Vampire": "Vampiros",
        "Video Game": "Videojuegos",
        "Villainess": "Villana",
        "Visual Arts": "Artes Visuales",
        "Workplace": "Ambiente Laboral"
    ]
}

extension NamedEntity {
    var localizedDisplayName: String { GenreLocalization.localizedName(for: name) }
}
