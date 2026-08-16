# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Animebox is a native iOS app (SwiftUI + SwiftData) for tracking anime the user has watched, is watching, or plans to watch. Anime metadata (search, top rankings, seasonal releases, genres) comes from the public [Jikan API](https://api.jikan.moe/v4) (unofficial MyAnimeList API, no key required) for guests, or from the official MyAnimeList API v2 (OAuth2 + PKCE) once signed in — see Architecture below. The user's personal library (status, progress, personal score, notes) is persisted locally with SwiftData, and read-write synced to the user's real MAL account when signed in.

UI strings and code comments are in Spanish; identifiers and API-facing code are in English.

## Working on this codebase

This is a 100% Swift/SwiftUI codebase. For any implementation request, query, or bug fix, apply the relevant guidance from these skills before writing or reviewing code:

- `/swiftui-pro` — SwiftUI views, modifiers, state, layout.
- `/swift-testing-pro:swift-testing-pro` — anything touching `AnimeboxTests` (Swift Testing framework).
- `/swift-concurrency-pro:swift-concurrency-pro` — `async`/`await`, actors, `@Observable`/`@MainActor`, Sendable conformance.
- `/emil-design-eng` — any new animation or interaction. See "Animations" below for the concrete patterns already established in this codebase; follow them instead of inventing new ones.

## Commands

Build and test via `xcodebuild` (scheme: `Animebox`, project: `Animebox.xcodeproj`). Requires a full Xcode install selected via `xcode-select` (not just Command Line Tools).

```bash
# Build for simulator
xcodebuild build -project Animebox.xcodeproj -scheme Animebox -destination 'platform=iOS Simulator,name=iPhone 16'

# Run all tests (AnimeboxTests + AnimeboxUITests)
xcodebuild test -project Animebox.xcodeproj -scheme Animebox -destination 'platform=iOS Simulator,name=iPhone 16'

# Run a single test (Swift Testing suite/test name)
xcodebuild test -project Animebox.xcodeproj -scheme Animebox -destination 'platform=iOS Simulator,name=iPhone 16' \
  -only-testing:AnimeboxTests/LibraryStoreTests/upsertCreatesEntry
```

Unit tests (`AnimeboxTests`) use the **Swift Testing** framework (`import Testing`, `@Test`, `#expect`), not XCTest. UI tests (`AnimeboxUITests`) use XCTest, since Swift Testing doesn't support UI automation.

## Architecture

MVVM with protocol-based dependency injection, no third-party dependencies.

- **Models/** — `Anime` (Jikan API response shape, `Codable`) vs. `LibraryEntry` (`@Model` SwiftData entity for the persisted library). `Anime+LibraryEntry.swift` bridges the two. `Anime+Dedupe.swift` dedupes by `malId` — Jikan sometimes repeats an anime across ranking/season pages, which breaks SwiftUI `ForEach`.
- **Services/** — `APIServicing`/`APIService` is a thin generic JSON GET wrapper over `URLSession` mapping HTTP/transport failures to `NetworkError`. `ContentServicing` (renamed from `JikanServicing` once a second implementation existed) declares the content-fetching surface (top/season/search/details/genres for anime+manga); `JikanService` implements it against Jikan, `MALContentService` against the official MAL v2 API. `ContentRouter: ContentServicing` picks between the two **per call** based on live `MALSession.isSignedIn` state (not cached at construction) — every View constructs its ViewModels with a `ContentRouter`, so the ViewModels themselves never know which backend answered. `LibraryStore`/`MangaStore` are `@MainActor` structs wrapping `ModelContext` for library CRUD (`upsert`/`delete`/`entry(for:)`/`save()`); `upsert` is find-or-create keyed on `malId`. **`LibrarySyncCoordinator` is the single mutation chokepoint** for both — it calls the stores locally first, then (only if signed in) pushes to MAL in the background via `MALLibrarySyncing`, without blocking or undoing the local save on a push failure (surfaced instead via `MALSession.lastSyncError`). Nothing should call `LibraryStore`/`MangaStore` directly outside the coordinator and `LibrarySyncCoordinator` itself.
- **ViewModels/** — `@Observable` classes (not `ObservableObject`), one per screen (Home, Search, AnimeDetail). Take their service dependency via initializer injection (default arg = real implementation), enabling swapping in fakes/previews for tests.
- **Views/** — organized by feature (`Home/`, `Search/`, `Library/`, `Detail/`, `Components/`). SwiftData is threaded through via `.modelContext` / `@Query` at the view layer; view models stay SwiftData-agnostic where possible (library persistence goes through `LibraryStore`, not `@Query`, so it can be unit tested with an in-memory container).
- **Preview/** (`#if DEBUG` only) — `PreviewJikanService` (canned `JikanServicing`) and `PreviewLibrary` (in-memory `ModelContainer` with sample `LibraryEntry` rows) for SwiftUI canvas previews. Don't reference these outside of `#Preview` blocks.
- **Utils/** — `Constants.swift` holds the app's color palette (`AppColors`), spacing scale (`AppSpacing`), and API config (`APIConfig`: base URL, timeout, search debounce). `NetworkError` is the single error type surfaced by the networking layer.
  - `AppSpacing` is a 4pt-grid scale: `microSpacing` (4, icon-to-label gaps), `compactSpacing` (8, tight stack/card spacing), `itemSpacing` (12, default stack spacing, grid gaps), `padding` (16, screen/card edge insets), `sectionSpacing` (24, gap between stacked sections on a screen), `cornerRadius` (12, all rounded corners in the app). Never hardcode a spacing/padding number — pick the closest token, or add a new named one to the enum if the scale is genuinely missing a step. Matches `/swiftui-pro`'s guidance ("place stack spacing, padding, rounding... into a shared enum of constants"; "avoid hard-coded values for padding and stack spacing").
- **AnimeboxWidget/** — separate WidgetKit extension target (`com.apple.product-type.app-extension`), embedded into the main app. `AnimeboxWidgetBundle.swift` (`@main`) → `WatchingNowWidget.swift` (`StaticConfiguration`, `.systemSmall`/`.systemMedium`) → `WatchingNowProvider.swift` (`TimelineProvider`, opens its own `ModelContainer` against the shared App Group store, `.never` refresh policy — relies entirely on explicit `WidgetCenter.shared.reloadTimelines(ofKind: "WatchingNowWidget")` calls, no periodic polling) → `WatchingNowEntryView.swift`. No poster art in v1 (no image-caching mechanism exists anywhere in the app; would need its own App-Group cache, deferred). Anime-only for v1 (manga's "next chapter" doesn't fit the "next episode" framing).
  - **Cross-target file sharing**: the widget target does *not* declare the whole `Animebox/` synced folder as a member (that would drag in `AnimeboxApp.swift`'s `@main`, views, networking — everything). Instead, `Models/LibraryEntry.swift`, `Models/LibraryStatus.swift`, `Services/WatchingNowQuery.swift`, and `Utils/Constants.swift` are added as individual, explicit `PBXFileReference`/`PBXBuildFile` entries directly on the widget target's Sources phase (classic pre-synced-groups mechanism, coexists fine with the main app's `PBXFileSystemSynchronizedRootGroup`-based targets). Extending sharing to a new file means adding one more explicit reference the same way, not restructuring folders.
  - `WatchingNowQuery.swift` (in the main `Animebox` target, so `AnimeboxTests` can cover it via `@testable import Animebox`) holds `watchingNowItems(in:limit:)` and the plain `WatchingNowItem` DTO — the widget crosses into `LibraryEntry`'s data as a `Sendable` struct, never the `@Model` reference itself.
  - App Group: `group.Alexdev.Animebox`, declared in both `Animebox/Animebox.entitlements` and `AnimeboxWidget/AnimeboxWidget.entitlements`, wired via `CODE_SIGN_ENTITLEMENTS` on both targets. `AnimeboxApp.swift`'s `ModelContainer` uses `groupContainer: .identifier(...)` so the app and the widget process open the exact same SwiftData store.
  - The target was added to the existing hand-crafted `.pbxproj` (Xcode 26 format, `objectVersion 77`, `PBXFileSystemSynchronizedRootGroup`-based) programmatically via the `xcodeproj` Ruby gem rather than by hand — see git history for the generating script if another target ever needs to be added the same way.
- **Services/Auth/** — the MyAnimeList sign-in mode. `MALSession` (`@Observable @MainActor`, single instance created in `AnimeboxApp.swift`, injected via `.environment(malSession)` — read it via `@Environment(MALSession.self)` in any View that needs to show account UI or build a `ContentRouter`/`LibrarySyncCoordinator`; ViewModels never reference it directly, only the `ContentServicing` protocol) exposes `isSignedIn`/`username`/`lastSyncError` and an internal `accessToken()` that refreshes via `MALAuthService` (real `ASWebAuthenticationSession` + PKCE flow, `code_challenge_method=plain` — MAL doesn't support S256) with a 60s expiry margin, falling back to signed-out on a failed refresh. `KeychainTokenStore` (Security framework only) persists `MALTokenSet`. `MALAPIService: APIServicing` injects the bearer token per-request and retries once on a 401 via a forced refresh. `MALLibrarySyncing`/`MALLibrarySyncService` are the account-only read/write endpoints (`PATCH .../my_list_status`, `DELETE .../my_list_status`, paginated `GET /v2/users/@me/{anime,manga}list`) that have no Jikan equivalent, used by `LibrarySyncCoordinator`. `MALSyncReconciler.reconcile()` runs right after a successful sign-in: pushes every current local entry first (so guest-mode data isn't silently discarded), then pulls the full real MAL list and lets it win — no bidirectional conflict resolution beyond that, a deliberate v1 simplification.
  - **Known, accepted limitation**: MAL v2 has no genre-list endpoint and its search (`GET /v2/anime`/`/v2/manga`) has no server-side genre/type/date filters and requires `q`. `MALContentService` covers this with a client-side approximation (`Utils/MALGenres.swift` static genre/theme lists sourced from MAL's own search-form HTML, not Jikan; fetch a wider pool — via `q` search if present, via ranking if not — then filter in-memory before truncating to the requested limit) — signed-in search is measurably weaker than Jikan's server-side filtered search. Don't "fix" this by silently falling back to Jikan while signed in; that defeats the point (Jikan being down is what motivated MAL sign-in as a content source in the first place). When there's no `q` (genre/theme-only search), the ranking pool is paginated 5×100 in parallel via `offset` (`MALContentService.maxRankingPages`) rather than a single capped page — a niche genre/theme (Horror, Harem, ...) rarely cracks the top 100 all-time-ranked anime, so a single-page pool silently returned zero results for those before this was added.
  - **Secrets**: `Animebox/Config/Secrets.xcconfig` (git-ignored, template at `Secrets.xcconfig.example`) supplies `MAL_CLIENT_ID` as a `baseConfigurationReference` on the `Animebox` target. It's read into the app via a literal `MALClientID` key + `$(MAL_CLIENT_ID)` value in the physical `Animebox/Info.plist` — **not** `INFOPLIST_KEY_MALClientID`, which silently does nothing for custom (non-Apple-recognized) keys even though `GENERATE_INFOPLIST_FILE=YES` is otherwise set; confirmed by inspecting the compiled `Info.plist`, not assumed. No `client_secret` is sent — the registered app is type "iOS" (public client), which MAL only issues a Client ID for, and `MALAuthService` omits `client_secret` from the token exchange/refresh body entirely when `MALConfig.clientSecret` is empty. `Secrets.xcconfig`'s two files are excluded from the `Animebox` target's Resources phase via a `PBXFileSystemSynchronizedBuildFileExceptionSet` (same mechanism already used to exclude `Info.plist`) — without that they get bundled as plain-text resources into the shipped app despite being git-ignored.
  - **`onHold`** is a real `LibraryStatus`/`MangaStatus` case (not collapsed into `.dropped` the way the XML importer used to) — required once sync is read-write, since silently relabeling a real MAL "on hold" entry as "dropped" and pushing that back would corrupt the user's actual account state, not just a local display nuance.

### Testing patterns

- SwiftData-backed code is tested against an in-memory `ModelContainer` (`ModelConfiguration(isStoredInMemoryOnly: true)`), not a real store.
- `JikanService` is tested by injecting fake `APIServicing` implementations from `AnimeboxTests/Support/` (`RecordingAPI` captures requested URLs, `FailingAPI` asserts no network call happens, `JikanServiceStub` for view-model-level tests). This avoids network calls entirely.
- `AnimeboxTests/Support/AnimeFixture.swift` provides an `Anime.fixture(...)` factory for building test data without repeating the full initializer.
- The `.networking` tag (`AnimeboxTests/Support/Tags.swift`) marks tests that exercise `JikanService`'s URL-building logic.
- Same fake-first approach for the MAL sign-in mode: `InMemoryTokenStore` (swaps in for `KeychainTokenStore` — `KeychainTokenStoreTests` is the one suite that deliberately exercises the real Simulator Keychain, and is marked `.serialized` because its tests share one real Keychain item and race each other otherwise), `ContentServiceSpy` (call-counting `ContentServicing` double, used to assert `ContentRouter` routes to the right backend), and `MALLibrarySyncingSpy` (records pushed/pulled/deleted calls, used by `LibrarySyncCoordinatorTests`/`MALSyncReconcilerTests`) all live in `AnimeboxTests/Support/`.

## Animations

Motion follows [Emil Kowalski's design engineering principles](https://animations.dev) (`/emil-design-eng` skill): used sparingly, only where it serves a purpose (feedback, avoiding a jarring content swap), never just for show — most interactions stay under 300ms. When adding a new screen or interaction, reuse these established patterns instead of inventing new ones:

- **Tappable cards/chips on `.buttonStyle(.plain)`** (poster cards, genre chips) — use `.buttonStyle(.pressableCard)` (`Views/Components/PressableCardStyle.swift`) instead, so the tap gets the same subtle `scaleEffect` press feedback everywhere. Don't add press feedback to controls that already have native iOS feedback (`.buttonStyle(.borderedProminent)`/`.bordered`, `Picker(.segmented)`, `List` swipe actions, sheet/push transitions) — those are already correct out of the box, adding more on top just duplicates it.
- **Content that swaps based on a toggle or filter** (the Anime/Manga `MediaKindPicker`, status pickers, search `LoadState`) — bind `.animation(.easeInOut(duration: 0.2), value: theDiscriminatingValue)` where the `switch`/conditional content lives, so old and new content crossfade instead of popping instantly.
- **List rows that appear/disappear as a result of a mutation** (completing a show removes it from the "Viendo" filter, deleting an entry) — wrap the state mutation itself in `withAnimation(.easeInOut(duration: 0.25))`, not just a view modifier.
- **Skip animation entirely on anything triggered at high frequency** (typing in the search field, the segmented picker's own selection indicator) — both already have adequate native feedback, and animating something seen dozens of times a session makes the UI feel slower, not more polished.

## Roadmap

Current state: anime **and** manga, guest-only — backed by Jikan (read-only, unofficial, no auth) + local SwiftData library, with local import of an existing MyAnimeList export (XML) and advanced search filters (type/rating/year on top of query/status/genres). Items below are grouped by priority so work can proceed incrementally without different pieces stepping on each other; none are scoped yet — treat each as direction, not a spec, until requirements are nailed down when it's actually picked up.

**Shipped** (kept here only as a pointer, not as a spec — see Architecture above for how they actually work): manga as a first-class category (`Manga`/`MangaLibraryEntry`, mirrors `Anime`/`LibraryEntry`); MAL list XML import (`MALListImporter`, `ImportListViewModel`, toolbar button in `LibraryView`); advanced search filters (`AnimeTypeFilter`/`AnimeRatingFilter`/`MangaTypeFilter`, year via `start_date`/`end_date` — Jikan's `/anime`+`/manga` search has no raw `season` param, only the fixed `/seasons/{year}/{season}` endpoint already used for "current season"); iOS home screen widget (`AnimeboxWidget` target — see Architecture above); official MyAnimeList API sign-in mode (OAuth2 + PKCE, read-write library sync, `ContentRouter`/`MALContentService`/`Services/Auth/` — see Architecture above).

### Near-term (highest value, closes existing gaps)

Nothing queued right now — pick the next item from Medium-term below.

### Medium-term

1. **Stats screen** (Swift Charts) — total episodes/chapters, estimated time watched, genre breakdown. Derivable entirely from existing `LibraryEntry` data.
2. **Next-episode notifications**, using the `broadcast`/`airing` fields Jikan already returns. `Animebox.entitlements` already has `aps-environment` (now wired via `CODE_SIGN_ENTITLEMENTS`, see Architecture above) and `Info.plist` already sets `UIBackgroundModes: remote-notification` — the entitlement/plist groundwork is active, but no notification-scheduling code exists yet.
3. **Custom tags/favorites** beyond the fixed five `LibraryStatus`/`MangaStatus` cases (`watching`/`onHold`/`completed`/`dropped`/`planned` and the reading equivalent).
4. **iCloud sync (SwiftData + CloudKit)** for the local library, independent of MAL account sync — protects guest users from losing their list on device change. `Animebox.entitlements` already declares `com.apple.developer.icloud-services: CloudKit`, just needs an actual `CKContainer`/`ModelConfiguration` wired up (`AnimeboxApp.swift` now uses an App Group `ModelConfiguration` for the widget, still not CloudKit-backed).

### Long-term / exploratory

5. **Manga reading via external extensions**, similar to Paperback's source-extension model. Reference implementation/format: `/Users/alex/spanish-manga-extensions` (separate repo, Paperback-style TS extensions) — read that repo when this is picked up. Legality needs to be evaluated before building this; don't start implementation without revisiting that question.
6. **Swipe-based recommendations tab** ("Tinder for anime/manga"): suggests titles based on the user's library (genres/scores of watched & saved entries), swipe left/right to reject/save.
7. **Tier list builder**: users create anime/manga tier lists from scratch, or the app generates a random starting set. Aimed partly at content creators (shareable/streamable tier lists as organic promotion).
8. **Social/friends list comparison** — compare libraries/scores with friends.
9. **Siri Shortcuts / App Intents** — e.g. "mark next episode of X as watched".
