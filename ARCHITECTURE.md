# XStreamPlay — Architecture

A short guide to how the app is put together, and the rules that keep it that way.
Read this first; every file also has a header comment explaining its one job.
The long version (modules, CI, releases) is in `ENGINEERING_GUIDE.md`.

## Layers

```
┌────────────────────────────────────────────────────────────────┐
│ App/            Composition root + navigation                  │
│   SceneDelegate → AppDIContainer → AppCoordinator              │
│                                     └→ MovieFlowCoordinator    │
├────────────────────────────────────────────────────────────────┤
│ Features/       Screens (MVVM)                                 │
│   Home · SeeAll · MovieDetails · Splash · Shared               │
│   ViewController  ──uses──▶  ViewModel  ──uses──▶  protocol    │
├────────────────────────────────────────────────────────────────┤
│ Domain/         What the app is about (no UIKit, no JSON)      │
│   Movie, MoviePage, MovieDetails, MediaType, MovieListSource   │
│   protocol MovieListRepository / MovieDetailsRepository        │
├────────────────────────────────────────────────────────────────┤
│ Data/           How the domain is fetched from TMDB            │
│   TMDBMovieRepository · DTOs · DTO → domain mappers            │
│   Endpoint+TMDB (every TMDB path) · TMDBImageURLBuilder        │
├────────────────────────────────────────────────────────────────┤
│ Infrastructure/ Generic plumbing                               │
│   APIClient (URLSession) · Endpoint · APIError                 │
│   AppEnvironment (config) · Log (OSLog)                        │
│ Core/           Reusable UI + utilities                        │
│   NibReusable · Storyboard · Haptics · AppAlert · gradients    │
└────────────────────────────────────────────────────────────────┘
```

Arrows only point **down**. A view model never imports Kingfisher, never builds a
URL, and never knows TMDB exists — it only knows the repository *protocol*.

### Folder map

```
XStreamPlay/
├── App/                      AppDelegate, SceneDelegate, AppDIContainer, AppCoordinator, MovieFlowCoordinator
├── Features/
│   ├── Home/                 Home.storyboard, HomeViewController, HomeViewModel
│   ├── SeeAll/               SeeAll.storyboard, SeeAllViewController, SeeAllViewModel
│   ├── MovieDetails/         MovieDetails.storyboard, MovieDetailsViewController, MovieDetailsViewModel, MovieDetailsContent
│   │   └── Views/            MovieDetailsHeroCell, MovieDetailsSummaryCell, MovieDetailsTabsHeaderView, Cast…Cell
│   ├── Splash/               Splash.storyboard, VideoSplashViewController
│   └── Shared/               Routing, PaginatedMovieLoader, MovieRail, MovieRailContent
│       └── Views/            MovieRailCell, MoviePosterCell (used by more than one screen)
├── Domain/
│   ├── Entities/             Movie, MoviePage, MovieDetails, MediaType, MovieListSource
│   └── Repositories/         MovieListRepository, MovieDetailsRepository (protocols only)
├── Data/
│   ├── DTOs/                 MovieDTO, MovieDetailsDTO, PageDTO
│   ├── Mappers/              Movie+DTO, MovieDetails+DTO
│   ├── Repositories/         TMDBMovieRepository
│   └── TMDB/                 Endpoint+TMDB, TMDBImageURLBuilder
├── Infrastructure/
│   ├── Networking/           APIClient, URLSessionAPIClient, Endpoint, HTTPMethod, APIError
│   ├── Configuration/        AppEnvironment
│   └── Logging/              Log, AppLogger
├── Core/                     Navigation/, UIComponents/, Haptics/, Alerts/, Extensions/
├── Resources/                Assets, fonts, theme, LaunchScreen, splash video
└── SupportingFiles/          Info.plist
```

## Flow of one tap

User taps a poster on Home:

1. `MovieRailCell` (cell) calls its `onMovieSelected` closure with the `Movie`.
2. `HomeViewController` plays a haptic and calls `router.showMovieDetails(for:)`.
3. `MovieFlowCoordinator` (the router) asks `AppDIContainer` for a details screen.
4. `AppDIContainer.makeMovieDetailsViewController` builds `MovieDetailsViewModel`
   with the shared `TMDBMovieRepository`, then the view controller with that view model.
5. The coordinator pushes it. `viewDidLoad` starts a `Task` that calls `viewModel.load()`.
6. The view model asks the repository → repository builds an `Endpoint` →
   `URLSessionAPIClient` sends it → JSON decodes into `MovieDetailsDTO` →
   mapped to `MovieDetails` → formatted into `MovieDetailsContent` → `@Published`.
7. The view controller's Combine sink receives it and reloads the table.

## SOLID, as applied here

| Principle | Where you can see it |
|---|---|
| **S**ingle responsibility | Cells only display. View models only hold state and call repositories. Coordinators only navigate. `PaginatedMovieLoader` only paginates. |
| **O**pen/closed | Add a Home rail by adding one `MovieRail` line in `MovieRail.homeScreen` — no other file changes. |
| **L**iskov substitution | Anything conforming to `MovieListRepository` (real or `MockMovieRepository`) works in every view model unchanged. |
| **I**nterface segregation | `MovieListRepository` vs `MovieDetailsRepository`; `MovieDetailsRouting` vs `SeeAllRouting`. See All only gets the router it needs. |
| **D**ependency inversion | View models depend on repository protocols; screens depend on router protocols; `AppDIContainer` picks the concrete types. |

## Dependency injection rules

1. **Constructor injection only.** Every dependency arrives through `init`. Storyboard
   screens use `init?(coder:…)` via `UIStoryboard.instantiate(creator:)`; their plain
   `init(coder:)` is marked unavailable so a screen can't be created without its dependencies.
2. **One composition root.** Only `AppDIContainer` creates services (`URLSessionAPIClient`,
   `TMDBMovieRepository`, `UIKitHapticFeedbackProvider`). No `.shared` singletons.
3. **Depend on protocols.** Store dependencies as `MovieListRepository`,
   `HapticFeedbackProviding`, etc. — not the concrete class.
4. **Routers are `weak`.** Screens hold their router weakly; `AppCoordinator` owns
   `MovieFlowCoordinator`, and `SceneDelegate` owns `AppCoordinator`.

## Threading rules

- View models, the loader and coordinators are `@MainActor`. All UI state changes on the
  main thread automatically — no `DispatchQueue.main.async` in view models.
- View models expose `async` functions; **view controllers start the `Task`**.
- `@Published` emits *before* the value changes. In a `sink`, use the value you receive,
  don't re-read the view model. Views keep their own snapshot (`rails`, `movies`, `content`)
  and the data source reads only that.

## Naming conventions

Names are how the next developer finds things. If a name needs a comment to explain it,
change the name.

### Files and types

| Rule | ✅ Do | ❌ Don't |
|---|---|---|
| One type per file, file name = type name | `MovieRailCell.swift` holds `MovieRailCell` | `protocol.swift`, `Model_Genres.swift` |
| Types are `UpperCamelCase`, no underscores or prefixes | `MovieDetailsDTO` | `Model_MovieDetails`, `Model_Production_companies` |
| Extensions are `Type+Topic.swift` | `UIView+Animations.swift`, `Movie+DTO.swift` | `Extensions.swift` |
| Folder names match what's inside | `Features/MovieDetails/` for `MovieDetails…` types | `MovieDetail/` holding `MovieDetails…` |
| `final class` by default, `private` by default | | |

Only exception: `Features/Shared/Routing.swift` holds every routing protocol, so all
navigation is visible in one place.

### Suffixes — say what the type *is*

| Suffix | Meaning | Examples |
|---|---|---|
| `ViewController` | A screen (UIKit) | `HomeViewController` |
| `ViewModel` | Screen state + logic, no UIKit | `HomeViewModel` |
| `Cell` | Table or collection cell (**not** `TVC`/`CVC`) | `MovieRailCell`, `MoviePosterCell` |
| `HeaderView` | Table/collection header | `MovieDetailsTabsHeaderView` |
| `Content` | Ready-to-display values for a view | `MovieDetailsContent`, `MovieRailContent` |
| `Coordinator` | Owns a navigation flow | `MovieFlowCoordinator` |
| `Routing` | Protocol a screen calls to navigate | `MovieDetailsRouting` |
| `Repository` | Protocol (Domain) or implementation (Data) that fetches entities | `MovieListRepository`, `TMDBMovieRepository` |
| `DTO` | Mirrors API JSON, Data layer only | `MovieDTO`, `PageDTO` |
| `-ing` / `-able` protocol | A capability | `HapticFeedbackProviding`, `NibReusable` |
| `Mock` / `Stub` / `Spy` | Test doubles | `MockMovieRepository`, `StubURLProtocol` |

Prefix a concrete type with its technology only when there could be another one:
`TMDBMovieRepository`, `URLSessionAPIClient`, `UIKitHapticFeedbackProvider`.

### Cells and views: name by *what they show*, then by *where*

- Shared cells describe the content: `MoviePosterCell`, `MovieRailCell`.
- Screen-specific cells start with the screen: `MovieDetailsHeroCell`, `MovieDetailsSummaryCell`.
- A XIB has the same name as its class, so `tableView.register(MovieRailCell.self)` and
  `let cell: MovieRailCell = tableView.dequeueReusableCell(for:)` work with no strings.
- Storyboard ID = class name (`StoryboardIdentifiable`). One storyboard per feature,
  named like its folder: `Home.storyboard`, `SeeAll.storyboard`, `MovieDetails.storyboard`, `Splash.storyboard`.

### Properties, outlets and methods

| Rule | ✅ Do | ❌ Don't |
|---|---|---|
| Outlets end with the UIKit type, no abbreviations | `titleLabel`, `posterImageView`, `watchNowButton`, `titleHeightConstraint` | `lblTitle`, `imageThumbnail`, `watchNowBtn`, `DetailtableView` |
| Outlets are `private` | `@IBOutlet private weak var titleLabel: UILabel!` | public outlets set from outside |
| Name by meaning, not position | `placeholderTitleLabel`, `audioLanguagesLabel` | `centerTitleLabel`, `subLabel`, `buttonViewtitleLbl` |
| Booleans read as a question | `isLoading`, `hasMorePages`, `showsSeeAll` | `loading`, `seeAll` |
| Closures for cell events: `on` + event | `onMovieSelected`, `onSeeAllTapped` | `delegate` protocols for one callback |
| `@IBAction`: control + event | `seeAllButtonTapped(_:)` | `btnClick(_:)` |
| Functions start with a verb | `loadNextPage()`, `makeContent(from:)`, `showMovieDetails(for:)` | `nextPage()`, `content()` |
| Factories in `AppDIContainer`: `make` + type | `makeHomeViewController(router:)` | `homeVC()` |
| IDs use `ID`, URLs use `URL` | `movieID`, `posterURL` | `movieId`, `posterUrl` |

### MARK sections, in this order

`// MARK: - Outlets`, `Dependencies`, `State`, `Init`, `Lifecycle`, `Setup`,
`Configuration` / `Rendering`, `Actions`, `Private`, then one per protocol
conformance (`// MARK: - UITableViewDataSource`).

### Tests

`test_<whatIsTested>_<condition>_<expectedResult>`, e.g.
`test_loadNextPage_whenUnauthorized_stopsPaginatingAndExplainsWhy`.
Test files mirror the app folders: `Networking/`, `Data/`, `Features/`, `Models/`, `Support/`.

## Configuration and secrets

`Secrets.xcconfig` (git-ignored) → `Configurations/XStreamPlay.xcconfig` → `Info.plist`
(`$(TMDB_ACCESS_TOKEN)` …) → `AppEnvironment`. New developer: copy
`Secrets.example.xcconfig` to `Secrets.xcconfig` and paste a TMDB read-access token.
A missing token never crashes the app — requests fail with "unauthorized" and the console says why.

## Adding a new screen (checklist)

1. Domain: add any entity / repository method you need (protocol first).
2. Data: implement it in `TMDBMovieRepository` (+ DTO + mapper) and add an `Endpoint` factory in `Endpoint+TMDB.swift`.
3. Feature: `Features/X/` with `X.storyboard`, `XViewModel` (`@MainActor`, takes protocols in `init`)
   and `XViewController` (`init?(coder:viewModel:router:…)`, `StoryboardIdentifiable`).
   Add a `case x = "X"` to `Storyboard`.
4. Add a routing protocol in `Features/Shared/Routing.swift` if other screens open it.
5. `AppDIContainer.makeXViewController(...)` and a method on `MovieFlowCoordinator`.
6. Tests: view model with `MockMovieRepository`; repository with `StubURLProtocol`.

## Tests

`XStreamPlayTests/`
- `Support/` — `StubURLProtocol` (fake network), `Fixtures` (JSON), `MockMovieRepository`.
- `Networking/` — `Endpoint`, `APIError` and `URLSessionAPIClient`.
- `Data/` — `TMDBMovieRepository` against stubbed JSON (paths + mapping).
- `Features/` — `PaginatedMovieLoader`, `HomeViewModel`, `MovieDetailsViewModel` with the mock repository.
- `Models/` — DTO decoding.

Run with ⌘U. No test touches the real network.
