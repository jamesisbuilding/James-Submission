# aurora_test (IMGO)

Flutter coding-assessment project for Aurora.

IMGO is a feed-based, luxury-travel inspiration app with:
- intro video + seamless transition into an image carousel,
- AI-generated titles/descriptions for accessibility/storytelling,
- text-to-speech playback with word-highlighting,
- favourites + share,
- dynamic colour-driven UI.

> **Best experienced on a physical device in `--profile` mode:**  
This app uses haptic feedback, which is only available on real devices (not emulators/simulators). Running in `--profile` ensures Ahead-of-Time (AOT) compilation, leading to smoother animations and reduced jank. For the intended experience, use:

```
flutter run --profile
```

on a real device.


## Demo
- Video demos: https://drive.google.com/drive/folders/1iASAfGXv4h4pXNdNDrNEwNQArccPV5KO?usp=sharing
- Recommended clip to review: **audio and text highlighting**.

---

## Monorepo layout

This repo is intentionally modular and package-oriented:

- `app/` – composition root (app bootstrap, routing, dependency registration, theme)
- `feature/image_viewer/` – primary feature package (domain/data/state/UI flow)
- `core/design_system/` – shared theme, assets, reusable widgets/buttons
- `core/services/image_analysis_service/` – image processing + caption generation pipelines (ChatGPT/Gemini)
- `core/services/tts_service/` – ElevenLabs-backed TTS generation + playback helper
- `core/services/share_service/` – sharing adapter using `share_plus`

### Architectural style
- **Feature-first modularization** with clean package boundaries.
- **Dependency Injection via GetIt** at app level; feature modules register their own dependencies.
- **BLoC + Cubit split by responsibility**:
  - `ImageViewerBloc` handles image retrieval, carousel selection, loading/error state.
  - Separate cubits handle TTS state, favourites, and collected colors to reduce unrelated rebuilds.
- **Flow orchestration pattern** in `ImageViewerFlow`: preloads image state while intro video overlays, then fades out.

This is architecturally sound for a small-to-mid Flutter product because dependencies flow one way:
`app -> feature/core`, and shared core packages are reused by features without reverse coupling.

---

## Runtime flow (current implementation)

1. `app/main.dart` initializes Firebase, registers dependencies, and launches `MaterialApp.router`.
2. Router opens `/image-viewer` and creates `ImageViewerFlow`.
3. `ImageViewerFlow` creates feature blocs/cubits and triggers initial fetch (`ImageViewerFetchRequested`).
4. Intro video (`assets/video/intro.mp4`) is shown while image content preloads behind it.
5. Image retrieval pipeline:
   - remote URL fetch from `https://november7-730026606190.europe-west1.run.app/image/`
   - image analysis service enriches each image with AI title/description and palette/signature data
   - duplicate protection combines URL-level and pixel-signature checks
   - retries + exponential backoff for transient failures
6. User interactions:
   - swipe carousel, expand/collapse cards, trigger “Another” fetch
   - start/stop TTS with text highlighting
   - favourite or share image + text
   - toggle light/dark mode

---

## Setup

## 1) Prerequisites
- Flutter SDK compatible with Dart `^3.10.0`
- iOS/Android tooling for your target device
- Firebase config files already present in repo (`firebase_options.dart`, platform files)

## 2) Environment variables
Create `app/.env` with:

```env
OPENAI_API_KEY=your_key
ELEVENLABS_API_KEY=your_key
```

> Note: `OPENAI_API_KEY` is required for the configured default image-analysis pipeline (`chatGpt`).

## 3) Install dependencies
```bash
cd app
flutter pub get
```

## 4) Generate env code
```bash
dart run build_runner build -d
```

The app is best optimized for iPhone 17 Pro. Although it should run on other devices, additional testing is required to ensure full compatibility.


### The app contains the following ###

### Launch
1. Native splash screen (platform launch screen - better with sound (no sound in emulator recording))
2. Launcher video 
3. Streaming in initial batch of images – preloads whilst the video plays

### Fetching and Processing Images
4. Background fetch – awaiting more images in the background as the user scrolls, triggered by their position in the carousel
5. Manual fetch – users can request more images via the another button when we don't have any prefetched
6. Prefetch caching – if we have images preloaded we give the impression of low latency
7. Data augmentation – use of an LLM interface (ChatGPT or Gemini) to provide the image with a title and description for accessibility
8. Duplication management – ensure no images are duplicated, using both URL checking and pixel color analysis. If we get 3 duplicate images in a row, we notify the user
9. Exponential back off – if we receive an error from our image fetching service we retry with exponential back off until the target batch is satisfied or we hit our attempt limit
10. Image visualisation fallbacks – we save the image locally and use cached network images so we have stable loading into the widget (no empty state)

### UI
11. Expansion mode – expand the image to see title, description and colour palette. Stealth colour collector: tap "Collect Colors" in the palette view to save the image’s palette; collected state persists and reduces rebuild scope via CollectedColorsCubit
12. Linear interpolation between colors – as the carousel moves the background palette changes with respect to the ratio of which image is primarily visible
13. Expandable image cards – tap an image to expand and see the full title and description, with the play button for TTS
14. Accessibility – interfaces with Eleven Labs API to read out the short story/description of the image and have highlighted text on each word. 
15. Favourite and Share – users can favourite and share images. Share has two modes: collapsed shares the raw image and description; expanded mode captures a screenshot of the carousel (excluding the control bar)
16. **Control bar main button** – dynamic button with multiple states:
    - **Background image:** shows the next image (from prefetched queue) if available; if none are fetched, shows the current/selected image; when carousel is expanded, shows the current image as a faint background. Colours driven by the image palette.
    - **Loading state:** shows a spinner when manually fetching ("Another" tapped with no prefetched images) or when loading audio.
    - **Audio mode:** when the carousel is expanded, the button switches to play/pause for TTS (replacing the "Another" label).
    - Contrast ratio threshold (WCAG AAA). Minimum 7:1 for accessibility.
17. Light and Dark mode – toggle via the button at the top right
18. Control bar – collapsible and updates to changes in selected image colors. Background loading indicator sits 8px above the right edge of the control bar and moves with expand/collapse. Hidden/collapsed until the first image arrives, then reveals and pops up to expanded.
19. Error dialogs – we surface fetch failures and duplicate exhaustion so the user knows what's going on


### Architecture

The project is structured as a modular Flutter app – each feature and core concern lives in its own package so we can slot things together and keep dependencies clear.

**Packages**

- `app` – Shell, main entry, routing (GoRouter), dependency injection (GetIt), theme
- `feature/image_viewer` – Main feature: domain, data, bloc/cubits, views
- `core/design_system` – Shared widgets, theming, assets
- `core/services` – image_analysis_service, tts_service, share_service

**Feature structure (image_viewer)**

- `domain` – Repository contracts, exceptions
- `data` – Datasources, repository implementations
- `bloc` – ImageViewerBloc for image state (fetch, selection, carousel)
- `cubit` – TtsCubit for playback, FavouritesCubit for favourites, CollectedColorsCubit for colour collector (kept separate to limit rebuilds)
- `view` – Flow (ImageViewerFlow) orchestrates video + image viewer, plus pages and widgets

**Patterns**

---

## Key product capabilities

**Refactoring and optimisation (done)**

The view layer has been refactored: the background loading indicator is integrated into the control bar and moves with it on expand/collapse. Bloc handlers use the current state at catch time (not the event’s original loading type) so error surfacing correctly tracks manual vs background loading even when state changes mid-fetch. Duplication handling uses URL deduplication before processing, pixel signature checks, `FailureType.duplicate` from the analysis service, and a bloc-level defensive filter; three sequential duplicates trigger `NoMoreImagesException` and fail fast. Image analysis requests use a 10s timeout with `TimeoutException` surfaced for manual fetches. The Another button uses precache for its color/background image to avoid flash when new images load.

**Still to improve – Eleven Labs and LLM resilience**

Eleven Labs (TTS) and LLM (ChatGPT/Gemini) could be made more robust – retries, fallbacks, clearer error handling and user feedback when those services fail. 

### Recommended next hardening steps
1. Extend automated tests:
   - ✅ unit tests for ImageViewerBloc fetch + duplicate + error paths (see [Testing](#testing)),
   - widget tests for critical controls and expanded card behaviour,
   - integration test for video → viewer transition + initial fetch.
2. Introduce environment-driven pipeline selection (ChatGPT vs Gemini) instead of code-level toggle.
3. Add structured logging/telemetry and production log-level controls.
4. Consider an explicit repository/result error model to remove generic thrown exceptions.
5. Add CI checks for formatting, linting, and test execution across packages.

---

## Known constraints

- Current optimization target is iPhone-class form factors; broader device matrix testing is still needed.
- External provider limits/latency (image API, OpenAI/Gemini, ElevenLabs) can impact perceived responsiveness.
- ImageViewerBloc has unit test coverage; widget/integration coverage is minimal.

---

## Testing

**Test coverage summary** (25 tests in `feature/image_viewer`)

| Suite | Tests | Path |
|-------|-------|------|
| ImageViewerBloc | 13 | `test/bloc/image_viewer_bloc_test.dart` |
| ImageRepositoryImpl | 5 | `test/data/repositories/image_repository_impl_test.dart` |
| TtsCubit | 4 | `test/cubit/tts_cubit_test.dart` |
| FavouriteStarButton | 3 | `test/view/widgets/control_bar/favourite_star_button_test.dart` |

### ImageViewerBloc unit tests

The `feature/image_viewer` package includes unit tests for fetch logic, duplicate handling, and error surfacing. Run from the image_viewer package:

```bash
cd feature/image_viewer
flutter test test/bloc/image_viewer_bloc_test.dart
```

**Coverage (13 tests)**

*Fetch + duplicate guard:*
| Test | Covers |
|------|--------|
| first load sets visibleImages + selectedImage correctly | Initial fetch, first image path |
| manual fetch while on last page appends and navigates path | Manual fetch on last page, append + select |
| duplicate signatures are skipped via reservation guard | Duplicate handling via `tryReserveSignature` |
| NoMoreImagesException only shows manual-mode errors | Manual-only error surfacing |
| NoMoreImagesException during background fetch does NOT show error | Background fetch silently ignores |
| TimeoutException only shows manual-mode errors | Manual-only error surfacing |
| TimeoutException during background fetch does NOT show error | Background fetch silently ignores |
| background fetch completion resets loading to none | Loading state reset on stream complete |

*Fetch trigger behavior (manual, scrolling, Another button):*
| Test | Covers |
|------|--------|
| AnotherImageEvent with exactly 1 prefetched: consumes and triggers background fetch | Prefetch when queue drops to 1 after consume |
| AnotherImageEvent with 2+ prefetched: consumes first, no fetch when 2+ remain | No redundant fetch while well-stocked |
| AnotherImageEvent with no prefetched and loading none: triggers manual fetch | Manual fetch when user taps Another with empty queue |
| AnotherImageEvent with no prefetched and loading background: switches to manual, no new fetch | User waiting – switch to manual, no duplicate request |
| ImageViewerFetchRequested with default params triggers background prefetch | Scroll-to-page (length-2) prefetch path |

**Fetch triggers (where `ImageViewerFetchRequested` is dispatched):**

| Trigger | Location | Type | When |
|---------|----------|------|------|
| Initial load | `ImageViewerFlow` | Background (count 3) | On flow mount |
| Scroll prefetch near end | `_onPageChange` (image_viewer_main_view) | Background (count 3) | When `page == images.length - 2` and `loadingType == none` |
| Another (has prefetched) | `AnotherImageEvent` via `onNextPage` | Background (count 3) | When consuming last prefetched (length was 1) |
| Another (no prefetched) | `AnotherImageEvent` | Manual (count 3) | When `loadingType == none` |
| Another (no prefetched, already loading) | `AnotherImageEvent` | Switch to manual | When `loadingType == background` – no new request |

Uses `mocktail` to mock `ImageRepository`; no `bloc_test` (dependency conflicts with `flutter_bloc 9`).

### ImageRepositoryImpl unit tests

Repository dedupe, retry, and duplicate-exhaustion logic are tested with fake datasource and fake analysis service:

```bash
cd feature/image_viewer
flutter test test/data/repositories/image_repository_impl_test.dart
```

**Coverage (5 tests)**

| Test | Covers |
|------|--------|
| URL dedupe (rawUrls.toSet()) works | Duplicate URLs from parallel fetches are deduped before analysis |
| duplicate result increments sequential duplicate counter and throws at threshold | `FailureType.duplicate` → `NoMoreImagesException` at 3 sequential |
| non-duplicate results decrement remainingToFetch and stream yields expected count | Success path, stream yields exactly `count` images |
| backoff retries stop once target count is reached | No extra rounds once target met |
| throws when all attempts fail | Generic `Exception` after all retries exhausted |

Uses `FakeImageRemoteDatasource` and `FakeImageAnalysisService` (no mocks).

### TtsCubit unit tests

TTS playback state transitions and stream subscription behavior:

```bash
cd feature/image_viewer
flutter test test/cubit/tts_cubit_test.dart
```

**Coverage (4 tests)**

| Test | Covers |
|------|--------|
| play() emits loading -> playing | State transition on successful play |
| onPlaybackComplete clears isPlaying/currentWord | Callback clears playback state and word highlight |
| stop() always clears state | Cancel + clear regardless of current state |
| exception in TTS service resets state and rethrows | Catch block clears state, rethrows to caller |

Uses `FakeTtsService` with controllable completion and error behavior.

### FavouriteStarButton widget tests

Favourites star rebuild behavior (selective `buildWhen`):

```bash
cd feature/image_viewer
flutter test test/view/widgets/control_bar/favourite_star_button_test.dart
```

**Coverage (3 tests)**

| Test | Covers |
|------|--------|
| tapping star toggles state | Add/remove UID from FavouritesCubit |
| icon color changes for selected UID when favourited | State drives visual (yellow vs onSurface) |
| unrelated UID toggle does not rebuild target star | `buildWhen` prevents rebuild when other UIDs change |

Uses `debugBuildCount` on `FavouriteStarButton` to instrument rebuilds.

### Run all tests

```bash
# from app/
flutter test

# image_viewer package only
cd feature/image_viewer && flutter test
```

---

## Quick commands

```bash
# from app/
flutter pub get
dart run build_runner build -d
flutter analyze
flutter test
flutter run
```
