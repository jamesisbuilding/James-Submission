# aurora_test (IMGO)

Flutter coding-assessment project for Aurora.

IMGO is a feed-based, luxury-travel inspiration app with:
- intro video + seamless transition into an image carousel,
- AI-generated titles/descriptions for accessibility/storytelling,
- text-to-speech playback with word-highlighting,
- favourites + share,
- dynamic colour-driven UI.

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
11. Expansion mode - expand the image such that you can see the title, description and colour palette of the image
12. Linear interpolation between colors – as the carousel moves the background palette changes with respect to the ratio of which image is primarily visible
13. Expandable image cards – tap an image to expand and see the full title and description, with the play button for TTS
14. Accessibility – interfaces with Eleven Labs API to read out the short story/description of the image and have highlighted text on each word. 
15. Favourite and Share – users can favourite and share images. Share has two modes: collapsed shares the raw image and description; expanded mode captures a screenshot of the carousel (excluding the control bar)
16. Dynamic 'Another' button – changes colour based on the image's color palette, ensuring at least 7 contrast levels for accessibility and holds next up image or selected image as a faint background. 
17. Light and Dark mode – toggle via the button at the top right
18. Control bar – collapsible and updates to changes in selected image colors. Background loading indicator sits 8px above the right edge of the control bar and moves with expand/collapse
19. Main button – dynamic and changes depending on whether we're in image view, loading view or expanded (play/pause for TTS) Contrast ratio threshold (WCAG AAA). Minimum 7:1 for accessibility.
20. Error dialogs – we surface fetch failures and duplicate exhaustion so the user knows what's going on


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
- `cubit` – TtsCubit for playback, FavouritesCubit for favourites (kept separate to limit rebuilds)
- `view` – Flow (ImageViewerFlow) orchestrates video + image viewer, plus pages and widgets

**Patterns**

---

## Key product capabilities

**Refactoring and optimisation (done)**

The view layer has been refactored: the background loading indicator is integrated into the control bar and moves with it on expand/collapse. Bloc handlers use the current state at catch time (not the event’s original loading type) so error surfacing correctly tracks manual vs background loading even when state changes mid-fetch. Duplication handling uses URL deduplication before processing, pixel signature checks, `FailureType.duplicate` from the analysis service, and a bloc-level defensive filter; three sequential duplicates trigger `NoMoreImagesException` and fail fast. Image analysis requests use a 10s timeout with `TimeoutException` surfaced for manual fetches. The Another button uses precache for its color/background image to avoid flash when new images load.

**Still to improve – Eleven Labs and LLM resilience**

Eleven Labs (TTS) and LLM (ChatGPT/Gemini) could be made more robust – retries, fallbacks, clearer error handling and user feedback when those services fail. 

### Recommended next hardening steps
1. Add automated tests:
   - unit tests for bloc/cubit transitions and repository retry/duplicate logic,
   - widget tests for critical controls and expanded card behaviour,
   - integration test for video -> viewer transition + initial fetch.
2. Introduce environment-driven pipeline selection (ChatGPT vs Gemini) instead of code-level toggle.
3. Add structured logging/telemetry and production log-level controls.
4. Consider an explicit repository/result error model to remove generic thrown exceptions.
5. Add CI checks for formatting, linting, and test execution across packages.

---

## Known constraints

- Current optimization target is iPhone-class form factors; broader device matrix testing is still needed.
- External provider limits/latency (image API, OpenAI/Gemini, ElevenLabs) can impact perceived responsiveness.
- Test coverage is currently minimal in the repository.

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
