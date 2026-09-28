# XStreamPlay — Engineering Guide

> How we build XStreamPlay: **Clean Architecture + MVVM (with binding) + SOLID + Dependency Injection**, split into **independent Swift Package Manager (SPM) modules** that are versioned with **Semantic Versioning**.
>
> Written for developers with ~3 years of iOS experience. Every rule has a short reason and a small code example from this app.

---

## Table of contents

1. [Goals](#1-goals)
2. [Architecture at a glance](#2-architecture-at-a-glance)
3. [Clean Architecture layers](#3-clean-architecture-layers)
4. [Modules: independent SPM packages](#4-modules-independent-spm-packages)
5. [Semantic Versioning for packages](#5-semantic-versioning-for-packages)
6. [SOLID in practice](#6-solid-in-practice)
7. [MVVM with binding](#7-mvvm-with-binding)
8. [Dependency Injection](#8-dependency-injection)
9. [Navigation with Coordinators](#9-navigation-with-coordinators)
10. [Networking (REST)](#10-networking-rest)
11. [Concurrency: async/await, actors, Combine](#11-concurrency-asyncawait-actors-combine)
12. [App lifecycle and the Apple ecosystem](#12-app-lifecycle-and-the-apple-ecosystem)
13. [Performance and scalability](#13-performance-and-scalability)
14. [Testing strategy](#14-testing-strategy)
15. [Code style and folder rules](#15-code-style-and-folder-rules)
16. [Git workflow](#16-git-workflow)
17. [CI/CD with Jenkins + Fastlane](#17-cicd-with-jenkins--fastlane)
18. [Releasing to the App Store](#18-releasing-to-the-app-store)
19. [Secrets and configuration](#19-secrets-and-configuration)
20. [Migration plan from the current code](#20-migration-plan-from-the-current-code)
21. [Skills map: role requirements → where you practise them here](#21-skills-map-role-requirements--where-you-practise-them-here)
22. [PR checklist](#22-pr-checklist)

---

## 1. Goals

| Goal | What it means for us |
|---|---|
| **Easy to understand** | A new developer can follow one tap from the screen to the network in under 10 minutes. |
| **Easy to change** | Changing the API, the image library or a screen touches one module, not ten files. |
| **Easy to test** | Every view model and repository can be tested without the network or a simulator UI. |
| **Fast to build** | Modules compile separately and are cached, so a change in `Home` doesn't rebuild `Networking`. |
| **Safe to release** | Every PR is linted, built and tested by CI. Releases are automated. |

---

## 2. Architecture at a glance

```
                    ┌────────────────────────────────────────┐
                    │            XStreamPlay (App)           │
                    │  SceneDelegate · AppDIContainer ·       │
                    │  AppCoordinator  (composition root)     │
                    └───────────────┬────────────────────────┘
                                    │ creates & wires
        ┌───────────────┬───────────┼────────────┬────────────────┐
        ▼               ▼           ▼            ▼                ▼
  ┌──────────┐   ┌────────────┐ ┌──────────┐ ┌──────────┐   ┌─────────────┐
  │ HomeFeat │   │ DetailFeat │ │ SeeAll   │ │ Splash   │   │ (next…)     │   Presentation
  └────┬─────┘   └─────┬──────┘ └────┬─────┘ └────┬─────┘   └─────────────┘   (MVVM)
       └───────────────┴──────┬──────┴────────────┘
                              ▼
                      ┌───────────────┐     ┌───────────────┐
                      │   XSDomain    │◀────│    XSData     │   Data implements Domain
                      │ entities,     │     │ repositories, │
                      │ use cases,    │     │ DTOs, mappers │
                      │ repo protocols│     └──────┬────────┘
                      └───────────────┘            │
                                                   ▼
                      ┌───────────────┐     ┌───────────────┐
                      │ XSDesignSystem│     │ XSNetworking  │   Infrastructure
                      │ colors, fonts,│     │ APIClient,    │
                      │ cells, alerts │     │ Endpoint      │
                      └───────────────┘     └───────────────┘
                      ┌───────────────┐
                      │   XSCore      │   logging, extensions (no UIKit in core logic)
                      └───────────────┘
```

**The dependency rule:** arrows point **inward**, toward `XSDomain`.
`XSDomain` depends on nothing. A feature never imports `XSData` or `XSNetworking`, only `XSDomain`.

---

## 3. Clean Architecture layers

| Layer | Contains | May import | Must NOT import |
|---|---|---|---|
| **Domain** | Entities (`Movie`, `MovieDetails`), use cases (`FetchMovieListUseCase`), repository **protocols** | `Foundation` | UIKit, Kingfisher, URLSession, DTOs |
| **Data** | Repository **implementations**, DTOs (`MovieDTO`), DTO → entity mappers | Domain, Networking | UIKit, features |
| **Presentation** | ViewModels, ViewControllers, Cells, Coordinators' routing protocols | Domain, DesignSystem | Data, Networking |
| **Infrastructure** | `APIClient`, `Endpoint`, image loading, persistence | Core | Domain entities |
| **App** | Composition root: creates everything and connects it | Everything | — |

### Entities vs DTOs

```swift
// Data layer — mirrors the JSON exactly
struct MovieDTO: Decodable {
    let id: Int
    let title: String?
    let name: String?          // TV shows use `name`
    let posterPath: String?
}

// Domain layer — shaped for the app, no JSON knowledge
public struct Movie: Hashable, Identifiable, Sendable {
    public let id: Int
    public let title: String
    public let mediaType: MediaType
    public let posterURL: URL?
}
```

> **Why:** if TMDB renames a field, only the DTO and mapper change. Screens never notice.

### Use cases

A use case is one business action. Keep them tiny.

```swift
public protocol FetchMovieListUseCase {
    func execute(source: MovieListSource, page: Int) async throws -> MoviePage
}

public final class DefaultFetchMovieListUseCase: FetchMovieListUseCase {
    private let repository: MovieListRepository

    public init(repository: MovieListRepository) {
        self.repository = repository
    }

    public func execute(source: MovieListSource, page: Int) async throws -> MoviePage {
        try await repository.fetchMovies(from: source, page: page)
    }
}
```

> **Rule:** add a use case when there is real logic (combining two repositories, filtering, caching rules). For a plain pass-through, the view model may call the repository protocol directly. Don't add empty layers just for the diagram.

---

## 4. Modules: independent SPM packages

### 4.1 Package list

| Package | Type | Depends on | Owns |
|---|---|---|---|
| `XSCore` | Library | — | `Log`, small Foundation extensions |
| `XSNetworking` | Library | `XSCore` | `APIClient`, `URLSessionAPIClient`, `Endpoint`, `APIError` |
| `XSDomain` | Library | — | Entities, use cases, repository protocols |
| `XSData` | Library | `XSDomain`, `XSNetworking` | `TMDBMovieRepository`, DTOs, mappers, TMDB endpoints |
| `XSDesignSystem` | Library | `XSCore` | `AppColors`, fonts, `GradientView`, `HomeMovieCVC`, `NibReusable`, `AppAlert` |
| `XSImageLoading` | Library | `Kingfisher` | `UIImageView.setRemoteImage(from:)`: the only place that imports Kingfisher |
| `XSHomeFeature` | Library | `XSDomain`, `XSDesignSystem`, `XSImageLoading` | Home screen + rails |
| `XSMovieDetailFeature` | Library | same as Home | Details screen |
| `XSSeeAllFeature` | Library | same as Home | See All grid |
| `XSTestSupport` | Library (tests only) | `XSDomain` | `MockMovieRepository`, fixtures, `StubURLProtocol` |

The **app target** becomes thin: `AppDelegate`, `SceneDelegate`, `AppDIContainer`, coordinators, assets, `Info.plist`.

### 4.2 Two ways to host packages

| Option | When | How |
|---|---|---|
| **Local packages (monorepo)**: start here | One team, fast iteration | `Packages/XSDomain/Package.swift`, added to the Xcode project as a local package |
| **Remote packages (own repos)** | Shared with other apps / teams | Each package in its own Git repo, released with Git tags (`1.4.0`) |

Start with local packages. Move a package to its own repo only when a second app needs it.

### 4.3 Example `Package.swift`

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "XSData",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "XSData", targets: ["XSData"])
    ],
    dependencies: [
        .package(path: "../XSDomain"),
        .package(path: "../XSNetworking")
        // Remote form, once published:
        // .package(url: "https://github.com/playboxtv/XSNetworking.git", from: "1.2.0")
    ],
    targets: [
        .target(
            name: "XSData",
            dependencies: ["XSDomain", "XSNetworking"],
            swiftSettings: [.enableExperimentalFeature("StrictConcurrency")]
        ),
        .testTarget(
            name: "XSDataTests",
            dependencies: ["XSData", .product(name: "XSTestSupport", package: "XSTestSupport")],
            resources: [.process("Fixtures")]
        )
    ]
)
```

### 4.4 Module rules

1. **`public` is a promise.** Only mark what other modules must use as `public`. Everything else stays `internal`.
2. **No circular dependencies.** If A needs B and B needs A, move the shared part into a lower module.
3. **Resources inside packages** (XIBs, images, JSON) use `Bundle.module`, never `Bundle.main`.
4. **Each package has its own tests** and can be tested alone: `swift test` or `xcodebuild test -scheme XSData`.
5. **Feature modules don't import each other.** Home opens Details through a routing protocol; the app's coordinator connects them.

---

## 5. Semantic Versioning for packages

Every package has a version `MAJOR.MINOR.PATCH` (for example `2.3.1`).

| Change | Bump | Example |
|---|---|---|
| Breaking public API (renamed/removed a `public` type or method, changed a signature) | **MAJOR** `1.4.2 → 2.0.0` | `APIClient.send(_:)` now `throws` a different error type |
| New public API, backwards compatible | **MINOR** `1.4.2 → 1.5.0` | Added `Endpoint.searchMulti(query:)` |
| Bug fix, no API change | **PATCH** `1.4.2 → 1.4.3` | Fixed 429 retry delay parsing |

### Rules

- **Tag every release** on the package repo: `git tag 1.5.0 && git push origin 1.5.0`.
- **Keep a `CHANGELOG.md`** in each package (sections: Added / Changed / Fixed / Removed).
- **Pin sensibly in consumers:**
  - `from: "1.5.0"`: accepts `1.x.x` ≥ 1.5.0 (default, recommended).
  - `.upToNextMinor(from: "1.5.0")`: only `1.5.x` (for fragile packages).
  - `exact:` only for emergencies.
- **Commit `Package.resolved`** for the app, so every developer and CI builds the same versions.
- **Deprecate before removing:** mark with `@available(*, deprecated, renamed: "newName")` in a MINOR release, remove in the next MAJOR.
- `0.x.y` versions mean "unstable": anything may break. Go to `1.0.0` once other modules depend on it.

---

## 6. SOLID in practice

### S — Single Responsibility
One reason to change per type.

| Type | Its one job |
|---|---|
| `HomeMovieCVC` | Show a poster and a title |
| `HomeViewModel` | Hold Home state and ask for data |
| `PaginatedMovieLoader` | Page-by-page loading rules |
| `TMDBMovieRepository` | Turn a domain request into a TMDB call and back |
| `MovieFlowCoordinator` | Push screens |

**Smell:** a view controller that builds URLs, parses JSON and pushes other screens.

### O — Open/Closed
Add behaviour by adding code, not editing existing code.

```swift
// Adding a Home rail = one new line. Nothing else changes.
static let homeScreen: [HomeRail] = [
    HomeRail(title: "Trending", source: .trending, showsSeeAll: true, showsPosterTitle: false),
    HomeRail(title: "Popular Movies", source: .popular, showsSeeAll: true, showsPosterTitle: true),
    // HomeRail(title: "Now Playing", source: .nowPlaying, ...)   ← new rail
]
```

### L — Liskov Substitution
Any implementation of a protocol must work wherever the protocol is used. `MockMovieRepository` and `TMDBMovieRepository` are interchangeable in every view model, with no `if isTesting` checks.

### I — Interface Segregation
Small protocols. A screen that only lists movies shouldn't see "fetch details".

```swift
public protocol MovieListRepository {
    func fetchMovies(from source: MovieListSource, page: Int) async throws -> MoviePage
}
public protocol MovieDetailsRepository {
    func fetchDetails(id: Int, mediaType: MediaType) async throws -> MovieDetails
}
```

### D — Dependency Inversion
High-level code depends on abstractions; the app decides the concrete type.

```swift
final class HomeViewModel {
    private let fetchMovies: FetchMovieListUseCase      // ✅ protocol
    // private let repo = TMDBMovieRepository()        // ❌ concrete + creates its own dependency
}
```

---

## 7. MVVM with binding

### 7.1 Roles

| Piece | Knows about | Never does |
|---|---|---|
| **View / ViewController** | ViewModel's **output** | Networking, formatting, navigation decisions |
| **ViewModel** | Use cases / repository protocols | `import UIKit`, `push`, `present` |
| **Model (Domain)** | Nothing | — |

### 7.2 Input / Output pattern (recommended)

Make the view model's API explicit: what the view **sends** and what it **receives**.

```swift
@MainActor
public final class MovieDetailsViewModel {

    // MARK: Input (view → view model)
    public enum Input {
        case viewDidLoad
        case retryTapped
        case movieTapped(Movie)
    }

    // MARK: Output (view model → view)
    public struct State: Equatable {
        var content: MovieDetailsContent?
        var similar: [Movie] = []
        var isLoading = false
        var errorMessage: String?
    }

    @Published public private(set) var state = State()

    private let fetchDetails: FetchMovieDetailsUseCase
    private weak var router: MovieDetailsRouting?

    public init(fetchDetails: FetchMovieDetailsUseCase, router: MovieDetailsRouting) {
        self.fetchDetails = fetchDetails
        self.router = router
    }

    public func send(_ input: Input) {
        switch input {
        case .viewDidLoad, .retryTapped:
            Task { await load() }
        case .movieTapped(let movie):
            router?.showMovieDetails(for: movie)
        }
    }

    private func load() async { /* set state.isLoading, call use case, set state */ }
}
```

### 7.3 Binding in UIKit (Combine)

```swift
private func bind() {
    viewModel.$state
        .receive(on: DispatchQueue.main)
        .removeDuplicates()
        .sink { [weak self] state in self?.render(state) }
        .store(in: &cancellables)
}

private func render(_ state: MovieDetailsViewModel.State) {
    activityIndicator.isHidden = !state.isLoading
    snapshot(for: state)           // diffable data source → no row-count crashes
    if let message = state.errorMessage { showError(message) }
}
```

**Binding rules**
1. **One `state` stream** per screen is easier to reason about than five separate `@Published` properties.
2. `@Published` emits in `willSet`. Use the value passed to `sink`; don't read `viewModel.state` inside the sink.
3. Always `[weak self]` in `sink`, and store in `cancellables`.
4. Cells get a **small display model** (`MovieCellModel(title:posterURL:)`), not the view model.
5. SwiftUI screens bind the same view model with `@StateObject` / `@ObservedObject` (make it `ObservableObject`). The same view model works for both UIKit and SwiftUI.

---

## 8. Dependency Injection

### 8.1 Rules
1. **Constructor injection only.** Dependencies come in through `init`. No `var viewModel: X!` that someone must remember to set.
2. **One composition root:** `AppDIContainer` in the app target is the only place that creates concrete services.
3. **No singletons in feature code** (`.shared`). Apple singletons (`URLSession.shared`, `NotificationCenter.default`) are wrapped behind protocols or injected.
4. **Depend on protocols**, stored as `let`.
5. **Storyboards/XIBs still get injection** with `instantiateViewController(identifier:creator:)` (iOS 13+).

### 8.2 Per-feature dependencies

Each feature module declares *what it needs*, and the app provides it.

```swift
// Inside XSHomeFeature
public protocol HomeDependencies {
    var fetchMovieList: FetchMovieListUseCase { get }
    var haptics: HapticFeedbackProviding { get }
}

public enum HomeModule {
    @MainActor
    public static func makeHome(dependencies: HomeDependencies, router: HomeRouting) -> UIViewController {
        let viewModel = HomeViewModel(fetchMovies: dependencies.fetchMovieList)
        return HomeViewController(viewModel: viewModel, router: router, haptics: dependencies.haptics)
    }
}

// Inside the app
extension AppDIContainer: HomeDependencies {
    var fetchMovieList: FetchMovieListUseCase { DefaultFetchMovieListUseCase(repository: movieRepository) }
}
```

> **Why:** the feature module compiles and is tested without knowing `XSData` exists.

### 8.3 Lifetimes

| Lifetime | Example | How |
|---|---|---|
| App-wide (one instance) | `APIClient`, repository, image cache | `lazy var` in `AppDIContainer` |
| Per screen | View model | Created in `make…` every time |
| Per flow | Coordinator | Owned by parent coordinator |

We don't use a DI framework (Swinject, Resolver). Plain Swift is enough at our size, and it's checked at compile time.

---

## 9. Navigation with Coordinators

- Screens **never** `push`/`present` other screens. They call a router protocol.
- A coordinator implements the router protocols and asks `AppDIContainer` for the next screen.
- Parent coordinators **retain** children; screens keep routers **weak**.

```swift
@MainActor public protocol MovieDetailsRouting: AnyObject {
    func showMovieDetails(for movie: Movie)
}

final class MovieFlowCoordinator: Coordinator, MovieDetailsRouting, SeeAllRouting {
    func showMovieDetails(for movie: Movie) {
        push(container.makeMovieDetails(for: movie, router: self))
    }
}
```

Deep links (`xstreamplay://movie/550`) and push notifications enter through the coordinator too, so there is one place to handle them.

---

## 10. Networking (REST)

### 10.1 Building blocks

| Type | Job |
|---|---|
| `Endpoint` | A value describing one request: path, method, query, headers, body |
| `APIClient` (protocol) | `send<T: Decodable>(_ endpoint:) async throws -> T` |
| `URLSessionAPIClient` | The only type that touches `URLSession` |
| `APIError` | Closed set of failures + `userMessage` + `isRetryable` |

### 10.2 Rules
1. **Auth goes in headers** (`Authorization: Bearer …`), never in the query string, because query strings end up in logs.
2. **Build URLs with `URLComponents`/`URLQueryItem`**, never string interpolation.
3. **Decode with one configured decoder** (`.convertFromSnakeCase`, date strategy).
4. **Map every failure to `APIError`.** The UI shows `error.userMessage`, never raw errors.
5. **Retry only retryable errors** (timeouts, 5xx, 429 with `Retry-After`), with exponential backoff (max 3 attempts).
6. **Paginate using the server's `total_pages`**, not "did the last page come back empty".
7. **Cancel work that's no longer needed.** Keep the `Task` handle and call `cancel()` in `deinit`/on reuse.
8. **Log requests with `OSLog`** at `.debug`, never with `print`, and never log tokens.
9. **Cache** with `URLCache` for GETs; add an offline cache in `XSData` (Core Data / SwiftData) only when there's a real offline need.

### 10.3 Testing networking
Use a `URLProtocol` stub (`StubURLProtocol`) injected via `URLSessionConfiguration.protocolClasses`. Tests assert the URL, headers, and the decoded result, all without real network.

---

## 11. Concurrency: async/await, actors, Combine

| Use | For |
|---|---|
| `async/await` | All request/response work (network, disk) |
| `@MainActor` | View models, coordinators, anything touching UIKit |
| `actor` | Shared mutable state off the main thread (for example an in-memory cache) |
| `Task { }` | Starting async work from UIKit callbacks (`viewDidLoad`, button taps) |
| `async let` / `TaskGroup` | Several independent requests at once (for example details + similar) |
| Combine | Binding view model state to views, debouncing search text |
| `AsyncStream` | Turning callback/delegate APIs into `for await` loops |

### Rules
1. **View models are `@MainActor`**, so no `DispatchQueue.main.async` inside them.
2. **Don't block the main thread:** decoding big JSON or processing images happens off-main (`Task.detached` or an actor).
3. **Handle cancellation:** check `Task.isCancelled` / `try Task.checkCancellation()` in long loops.
4. **Prefer structured concurrency** (`async let`, `TaskGroup`) over loose `Task {}` inside async code.
5. **`Sendable`:** domain entities are value types marked `Sendable`. Turn on **Strict Concurrency Checking = Complete** per package, and fix warnings before moving to Swift 6 mode.

```swift
actor ImageMemoryCache {
    private var storage: [URL: UIImage] = [:]
    func image(for url: URL) -> UIImage? { storage[url] }
    func insert(_ image: UIImage, for url: URL) { storage[url] = image }
}
```

Functional style we use: `map`, `compactMap`, `filter`, `reduce`, value types, pure formatting functions (easy to unit test, for example `MovieDetailsViewModel.makeContent(from:)`).

---

## 12. App lifecycle and the Apple ecosystem

| Event | Where | What we do |
|---|---|---|
| Launch | `AppDelegate.didFinishLaunching` | Configure logging, crash reporting, appearance |
| Scene connect | `SceneDelegate.willConnectTo` | Build window, `AppDIContainer`, start `AppCoordinator`; handle launch deep link |
| Foreground/active | `sceneDidBecomeActive` | Resume playback, refresh stale data |
| Background | `sceneDidEnterBackground` | Pause video, save state, schedule `BGAppRefreshTask` if needed |
| Memory warning | `didReceiveMemoryWarning` / notification | Clear image memory cache |
| Deep link / Universal Link | `scene(_:openURLContexts:)`, `continue userActivity` | Forward to coordinator |

Ecosystem items to know and use when a feature needs them: **AVKit/AVFoundation** (playback, Picture in Picture), **Background Modes**, **Push Notifications (APNs)**, **Universal Links**, **Keychain** (tokens), **App Transport Security**, **Privacy manifests (`PrivacyInfo.xcprivacy`)**, **TestFlight**, **App Store Connect**, **Instruments**.

Third-party libraries are allowed only behind our own wrapper (one adapter file). Current list:

| Library | Why | Wrapped by |
|---|---|---|
| Kingfisher | Image download + cache | `XSImageLoading` |
| (Alamofire: not needed; remove unused package) | — | — |

---

## 13. Performance and scalability

1. **Lists:** use `UICollectionViewDiffableDataSource` + `UICollectionViewCompositionalLayout` for Home (one collection view with horizontal sections instead of table-in-table).
2. **Prefetching:** implement `UICollectionViewDataSourcePrefetching` for posters and next pages.
3. **Images:** request the right size (`w342` for tiles, not `original`), downsample, cancel on reuse.
4. **Reload only what changed:** apply snapshots, don't call `reloadData()` for everything.
5. **Measure, don't guess:** Instruments (Time Profiler, Allocations, Leaks), MetricKit for field data.
6. **Launch time:** keep `didFinishLaunching` light and create services lazily.
7. **Build time:** modules + `-warn-long-function-bodies=200` in Debug to catch slow type-checking.
8. **Memory:** `[weak self]` in escaping closures; check the Debug Memory Graph after each feature.

---

## 14. Testing strategy

| Level | Tool | What | Target |
|---|---|---|---|
| Unit | XCTest / Swift Testing | ViewModels, use cases, mappers, repositories (with stub network) | ≥ 80% of Domain + Data + ViewModels |
| Snapshot | swift-snapshot-testing | Cells and screens in light/dark and large text | Key screens |
| UI | XCUITest | Launch → Home → Details → back | Smoke path only |
| Contract | JSON fixtures | Real TMDB responses decode | Every DTO |

**Naming:** `test_<whatIsTested>_<condition>_<expectedResult>`, for example `test_loadNextPage_whenUnauthorized_stopsPaginating`.

**Test doubles:** hand-written mocks in `XSTestSupport` (`MockMovieRepository`, `SpyRouter`). No mocking frameworks needed.

---

## 15. Code style and folder rules

- **SwiftLint** runs in CI and as a build phase (`.swiftlint.yml` in repo). No `!` force unwraps, no `print`.
- **Naming:** types `UpperCamelCase`, everything else `lowerCamelCase`. Cells end with `Cell` in new code (`MoviePosterCell`).
- **One type per file**, file name = type name. **No duplicate file names in one target** (it breaks the build: "Multiple commands produce … .stringsdata").
- **`final class` by default**; `private` by default.
- **MARK sections:** `// MARK: - Lifecycle`, `// MARK: - Setup`, `// MARK: - Actions`, `// MARK: - Private`.
- **Comments explain *why*,** in short, simple sentences. The code shows *what*.
- **Folder layout inside a feature package:**
  ```
  XSHomeFeature/
    Sources/XSHomeFeature/
      HomeModule.swift          ← public factory
      HomeViewController.swift
      HomeViewModel.swift
      Views/ (cells + XIBs)
    Tests/XSHomeFeatureTests/
  ```

---

## 16. Git workflow

| Branch | Purpose |
|---|---|
| `main` | Always releasable. Only merges from `release/*` and `hotfix/*`. |
| `develop` | Integration branch for the next release. |
| `feature/<ticket>-short-name` | One feature or fix, branched from `develop`. |
| `release/1.3.0` | Stabilise a release; only fixes. |
| `hotfix/1.3.1` | Urgent fix from `main`. |

**Rules**
1. Small PRs (< 400 lines changed). One reviewer minimum, CI must be green.
2. **Commit messages:** Conventional Commits: `feat(home): add Now Playing rail`, `fix(details): crash when section reloads`, `chore(ci): cache SPM`.
3. **Never commit** secrets (`Secrets.xcconfig`), `xcuserdata/`, `.DS_Store`, `DerivedData`. A correct `.gitignore` must exist on **every** branch.
4. **Before switching branches,** commit or stash **including untracked files** (`git stash -u`). Otherwise new files follow you to the other branch and can break its build.
5. Rebase your feature branch on `develop` before merging; squash-merge to keep history clean.
6. Tag app releases: `v1.3.0`.

---

## 17. CI/CD with Jenkins + Fastlane

### 17.1 Pipeline stages

```
Checkout → Resolve SPM → SwiftLint → Build → Unit tests (+ coverage) → Package tests
        → (develop) Archive + TestFlight  → (release/*) Archive + App Store submission
```

### 17.2 `Jenkinsfile` (declarative)

```groovy
pipeline {
    agent { label 'macos-xcode16' }
    environment {
        TMDB_ACCESS_TOKEN = credentials('tmdb-read-token')   // injected, never in git
        FASTLANE_SKIP_UPDATE_CHECK = '1'
    }
    options { timeout(time: 45, unit: 'MINUTES'); timestamps() }

    stages {
        stage('Setup')  { steps { sh 'bundle install && bundle exec fastlane setup_ci' } }
        stage('Lint')   { steps { sh 'swiftlint --strict --reporter junit > swiftlint.xml' } }
        stage('Test')   { steps { sh 'bundle exec fastlane tests' } }
        stage('Beta') {
            when { branch 'develop' }
            steps { sh 'bundle exec fastlane beta' }
        }
        stage('Release') {
            when { branch pattern: 'release/.*', comparator: 'REGEXP' }
            steps { sh 'bundle exec fastlane release' }
        }
    }
    post {
        always { junit '**/fastlane/test_output/*.junit, swiftlint.xml' }
    }
}
```

### 17.3 `Fastfile` (key lanes)

```ruby
default_platform(:ios)

platform :ios do
  lane :tests do
    scan(scheme: "XStreamPlay", device: "iPhone 16", code_coverage: true, result_bundle: true)
  end

  lane :beta do
    match(type: "appstore", readonly: true)           # certificates from a private repo
    increment_build_number(build_number: ENV["BUILD_NUMBER"])
    gym(scheme: "XStreamPlay", export_method: "app-store")
    pilot(skip_waiting_for_build_processing: true)    # TestFlight
  end

  lane :release do
    match(type: "appstore", readonly: true)
    gym(scheme: "XStreamPlay", export_method: "app-store")
    deliver(submit_for_review: true, automatic_release: false, force: true)
  end
end
```

**Notes**
- **Maven** is the Java/Android build tool. Its role on iOS is taken by **SPM** (dependencies) + **Fastlane** (build/release). An Android version of XStreamPlay would use **Gradle** (or Maven) in the same Jenkins pipeline with its own stage.
- Cache `~/Library/Caches/org.swift.swiftpm` between builds to speed up CI.

---

## 18. Releasing to the App Store

**App version rules:** `CFBundleShortVersionString` = `MAJOR.MINOR.PATCH` (what users see); `CFBundleVersion` = CI build number (always increasing).

**Checklist before submission**
- [ ] All CI stages green on `release/x.y.z`
- [ ] Tested on the oldest supported iOS (15) and the newest
- [ ] Dark mode, Dynamic Type, VoiceOver basic pass
- [ ] Privacy manifest + App Store privacy "nutrition label" up to date
- [ ] No debug alerts or test endpoints (`#if DEBUG` checked)
- [ ] Screenshots + release notes in App Store Connect
- [ ] Phased release ON; monitor crashes (Xcode Organizer / Crashlytics) for 48 h
- [ ] Tag `vX.Y.Z` and merge `release/*` into `main` and `develop`

**Google Play (for the Android counterpart):** same flow with internal → closed → production tracks, and the same semantic app versions (`versionName`) plus an increasing `versionCode`. Android UI follows **Material Design** guidelines; iOS follows the **Human Interface Guidelines**. Keep features and behaviour in sync, but use each platform's native patterns.

---

## 19. Secrets and configuration

- Secrets live in **`Secrets.xcconfig`** (git-ignored), then `Info.plist` `$(TMDB_ACCESS_TOKEN)`, then read by `AppEnvironment`.
- `Secrets.example.xcconfig` (committed) shows new developers what to fill in.
- CI injects secrets as **environment variables** from Jenkins credentials.
- Missing config must **never crash** the app: log a clear message, show a debug-only alert, fail requests with 401.
- Tokens that must stay on the device at runtime (user login) go in the **Keychain**, never `UserDefaults`.
- If a key was ever committed, **rotate it**. Removing it from the latest commit is not enough.

---

## 20. Migration plan from the current code

| Phase | Work | Done when |
|---|---|---|
| **0. Hygiene** | Add `.gitignore` to every branch; untrack `xcuserdata/` and `.DS_Store`; rotate the TMDB key that is in git history; remove unused Alamofire | `git status` is clean after opening Xcode |
| **1. In-app layers** | Restore the refactor from `_refactor_backup/` onto `dc_ScrollingBanner`: `Domain/`, `Data/`, coordinators, `AppDIContainer`, constructor injection | App builds and runs; tests pass |
| **2. Extract packages** | `XSCore`, `XSNetworking`, `XSDomain` → local packages under `Packages/` | App target no longer contains these folders |
| **3. Data + Design system** | `XSData`, `XSDesignSystem`, `XSImageLoading` | Only `XSImageLoading` imports Kingfisher |
| **4. Features** | One package per feature (Home, Details, SeeAll) with `…Dependencies` protocols | Features don't import `XSData` |
| **5. MVVM Input/Output** | Move each view model to `send(_:)` + single `state`; diffable data sources | No manual `reloadSections` |
| **6. CI/CD** | Jenkinsfile + Fastlane lanes; TestFlight from `develop` | Every PR tested automatically |
| **7. Versioning** | `CHANGELOG.md` + tags per package; move shared packages to own repos if reused | Packages consumed by version |

Do one phase per PR series. The app must build and run at the end of every phase.

---

## 21. Skills map: role requirements → where you practise them here

| Requirement | Where in XStreamPlay |
|---|---|
| Professional Swift (3+ years) | Whole codebase; SOLID, protocols, generics (`NibReusable`, `APIClient.send<T>`) |
| iOS ecosystem & third-party libraries | Kingfisher behind a wrapper; AVFoundation splash; SPM dependency management (§4, §12) |
| iOS app lifecycle | `SceneDelegate` + coordinators, background/foreground handling (§12) |
| REST back-end integration | `XSNetworking` + `XSData` against TMDB (§10) |
| Functional & asynchronous Swift | `map/compactMap`, pure formatters, async/await, actors, Combine (§11) |
| Scalable, high-performance apps | Modules, diffable data sources, prefetching, image sizing, Instruments (§4, §13) |
| Releasing to App Store (and Google Play) | Fastlane `beta`/`release` lanes, release checklist, Play tracks (§17, §18) |
| Jenkins / CI server, Git | `Jenkinsfile`, Git flow, Conventional Commits (§16, §17) |
| Maven | Android/Java counterpart build step in the same Jenkins pipeline (§17 notes) |
| Android UI patterns / Material UI | Parity notes: Material on Android, HIG on iOS (§18) |
| macOS apps with Swift | Domain/Data/Networking packages are UIKit-free, so a macOS (AppKit/SwiftUI) target can reuse them; add `.macOS(.v13)` to their `platforms` |
| Java / Objective-C (desirable) | Obj-C interop via `@objc` (selectors, KVO in the splash); bridging header if an Obj-C SDK is added |

### Things you should be able to explain (interview-ready)
1. Walk one tap from `HomeBucketTVC` to TMDB and back, naming each layer.
2. Why `@Published` + reading the view model inside `sink` gives stale values.
3. How `instantiateViewController(identifier:creator:)` enables constructor injection with storyboards.
4. When you'd add a use case vs call the repository directly.
5. MAJOR vs MINOR vs PATCH for a real change in `XSNetworking`.
6. How you'd make `ImageMemoryCache` thread-safe (actor) and why `@MainActor` on view models.
7. How CI stops a broken build or leaked secret from reaching `main`.

---

## 22. PR checklist

- [ ] Follows the dependency rule (no feature imports `XSData`/`XSNetworking`)
- [ ] New dependencies are injected through `init`, not created inside
- [ ] View model has no `import UIKit` and no navigation code
- [ ] Unit tests added/updated; CI green
- [ ] No force unwraps, no `print`, SwiftLint clean
- [ ] Public API change? Package version bumped + `CHANGELOG.md` updated
- [ ] No secrets, `xcuserdata/` or `.DS_Store` in the diff
- [ ] Screenshots attached for UI changes (light + dark)
