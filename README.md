# Animebox

**Animebox** is a native iOS app for discovering and tracking anime. Browse top-ranked series, explore the current season, search by title or genre, and keep your personal library organized — all in one place.

> 🚧 Currently in active development.

---

## Screenshots

<img width="284" height="503" alt="image" src="https://github.com/user-attachments/assets/446438bf-06f8-4e45-927c-e73ad256efcc" />
<img width="293" height="506" alt="image" src="https://github.com/user-attachments/assets/e68f45bb-658a-48f6-b94f-eda7f81877fb" />
<img width="274" height="505" alt="image" src="https://github.com/user-attachments/assets/4fec95dd-f4f6-4ad8-953c-fdb8c8d13abb" />
<img width="266" height="503" alt="image" src="https://github.com/user-attachments/assets/af036fa0-85c9-44e3-b864-916bf23e3e13" />


---

## Features

- **Home** — Top Anime and Current Season, loaded in parallel on launch
- **Search** — Full-text search with real-time debouncing, genre chip filters, and status filters (Airing · Completed · Upcoming)
- **Anime Detail** — Full detail view: hero poster, synopsis, genres, stats (score, rank, popularity, episodes)
- **Personal Library** — Add any anime to your library with status tracking:
  - *Viendo* (Watching)
  - *Completado* (Completed)
  - *Abandonado* (Dropped)
  - *Planeado* (Planned)
- **Progress Tracking** — Log episode progress manually; auto-marks as completed when you reach the finale
- **Offline Storage** — Library persists locally via SwiftData, no account required
- **Dark theme** — Designed for comfortable night watching sessions

---

## Tech Stack

| Layer | Technology |
|---|---|
| Language | Swift 5 |
| UI Framework | SwiftUI |
| Local Persistence | SwiftData |
| Concurrency | Swift async/await |
| Architecture | MVVM + Protocol-based services |
| Anime Data | [Jikan API v4](https://jikan.moe) (MyAnimeList) |
| Testing | XCTest (unit tests for ViewModels, Models, Services) |

---

## Architecture

The project follows a clean **MVVM** structure with protocol-based dependency injection, which makes the codebase fully testable and easy to extend.

```
Animebox/
├── Models/          # Anime, LibraryEntry, LibraryStatus, JikanResponse...
├── ViewModels/      # HomeViewModel, SearchViewModel, AnimeDetailViewModel
├── Views/
│   ├── Home/        # HomeView, WatchingNowSection, HomeAnimeSection
│   ├── Search/      # SearchView, SearchBar, GenreChipsRow, SearchResultCard
│   ├── Detail/      # AnimeDetailView, AddToLibrarySheet, AnimeDetailHero
│   ├── Library/     # LibraryView, LibraryEntryRow, LibraryStatusPicker
│   └── Components/  # AnimeCard, GenrePill, LoadingView, ErrorView
├── Services/
│   ├── JikanService.swift    # Jikan API integration (protocol-based)
│   ├── APIService.swift      # Generic HTTP layer (async/await)
│   └── LibraryStore.swift    # SwiftData CRUD operations
└── Utils/
    ├── Constants.swift        # AppColors, AppSpacing, APIConfig
    └── NetworkError.swift     # Typed network error handling
```

**Key design decisions:**
- `JikanServicing` protocol allows full test isolation via stubs — no real network calls in tests
- `LibraryStore` wraps SwiftData's `ModelContext` for clean, testable persistence logic
- Search debouncing (300ms) is handled inside `SearchViewModel` via cancellable `Task`
- `@Observable` (Swift 5.9 Observation framework) instead of `ObservableObject` for all ViewModels

---

## Getting Started

### Requirements

- Xcode 16+
- iOS 17+
- No API key needed (Jikan API is free and open)

### Installation

```bash
git clone https://github.com/alexgpareja/Animebox.git
cd Animebox
open Animebox.xcodeproj
```

Press `Cmd + R` to build and run on the simulator or a connected device.

---

## Data Source

Animebox uses the **[Jikan API v4](https://jikan.moe)** — a free, open-source REST API for [MyAnimeList](https://myanimelist.net) data. No authentication required.

Endpoints used:
- `GET /top/anime` — Top ranked anime
- `GET /seasons/now` — Current season
- `GET /anime?q=...` — Search with filters
- `GET /anime/{id}/full` — Full anime details
- `GET /genres/anime` — Genre list for filter chips

---

## Author

**Àlex Gil Pareja**
[GitHub](https://github.com/alexgpareja) · [LinkedIn](https://linkedin.com/in/alexgpareja)
