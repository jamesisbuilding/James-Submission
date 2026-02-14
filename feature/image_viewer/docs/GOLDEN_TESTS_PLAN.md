# Golden Tests Plan — UI Regression Safety

Specification for golden snapshot tests to protect the image_viewer UI from regressions.

---

## Golden Set to Capture

| # | Snapshot | Widget / State | Notes |
|---|----------|----------------|-------|
| 1 | **Intro state** | Video thumbnail visible | `VideoView` shows `Assets.video.thumbnail` before video initializes |
| 2 | **Carousel collapsed** | Multiple cards, none expanded | `ImageCarousel` + collapsed cards |
| 3 | **Expanded card** | Long title/description | `ImageViewerExpandedBody` with wrapping text, ellipsis |
| 4 | **Control bar collapsed** | Bottom bar, carousel not expanded | `ControlBar` with `carouselExpanded: false` |
| 5 | **Control bar expanded** | Full-width bar, carousel expanded | `ControlBar` with `carouselExpanded: true` |
| 6 | **Light mode** | Theme: light | `MaterialApp(theme: lightTheme, themeMode: ThemeMode.light)` |
| 7 | **Dark mode** | Theme: dark | `MaterialApp(theme: darkTheme, themeMode: ThemeMode.dark)` |
| 8 | **Loading indicator** | Spinner visible | `BackgroundLoadingIndicator` when loading |
| 9 | **Error dialog** | `showCustomDialog` with error message | `BlocListener` fires → dialog overlay |
| 10 | **Animated background colors** | `LiquidBackground` driven by carousel | `blendedColorsNotifier` reflects selected image palette |

---

## Implementation Strategy

### 1. Dependencies

Add to `feature/image_viewer/pubspec.yaml`:

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  golden_toolkit: ^0.15.0  # or latest compatible
```

**Alternative:** Use built-in `expectLater(tester, matchesGoldenFile('path.png'))` from `flutter_test` (no extra dep). `GoldenToolkit` adds multi-resolution and easier setup.

### 2. Test Harness / Pumping

**Core harness** (reuse from `image_viewer_flow_test.dart`):

- `FakeImageRemoteDatasource` / `FakeImageAnalysisService` for deterministic image data
- `FakeTtsService` for TTS
- `GetIt` setup with fakes
- `MaterialApp` wrapping `ImageViewerFlow` or individual screens

**Theme injection:**

```dart
MaterialApp(
  theme: lightTheme,   // or darkTheme from design_system
  darkTheme: darkTheme,
  themeMode: ThemeMode.light,  // or ThemeMode.dark
  home: ...,
)
```

**Fixed viewport:**

```dart
testWidgets('...', (tester) async {
  await tester.binding.setSurfaceSize(const Size(430, 932));  // iPhone 17 Pro
  addTearDown(() => tester.binding.setSurfaceSize(null));
  ...
});
```

### 3. Per-Snapshot Pumping Guide

#### 1. Intro state (video thumbnail)

- Use `overlayBuilder` to inject a **static** widget instead of `VideoView` (avoids video init in tests)
- Or: mock `VideoPlayerController.asset` and only pump until thumbnail is visible (before `_controller.value.isInitialized`)
- **Simplest:** Custom overlay that shows `Assets.video.thumbnail.designImage(...)` → golden capture

#### 2. Carousel collapsed

- Pump with `FakeImageRemoteDatasource` returning 3+ URLs
- Wait for `state.visibleImages.isNotEmpty`
- Ensure `expandedView: false`
- Skip video: use `overlayBuilder` that immediately calls `onVideoComplete` so content shows

#### 3. Expanded card (long title/description)

- Provide `ImageModel` with long `title` and `description` (e.g. 80+ chars each)
- Trigger expand: `onExpanded(true)` or tap-to-expand flow
- Pump to allow layout/overflow handling

#### 4 & 5. Control bar collapsed / expanded

- `ControlBar(carouselExpanded: false)` vs `carouselExpanded: true`
- Can test `ControlBar` in isolation with mock `CollectedColorsCubit`, `TtsCubit`, etc.

#### 6 & 7. Light / dark mode

- Same widget tree, `MaterialApp` with `themeMode: ThemeMode.light` or `ThemeMode.dark`
- Capture both; golden filenames e.g. `control_bar_light.png`, `control_bar_dark.png`

#### 8. Loading indicator

- `BackgroundLoadingIndicator` shown when `loadingType != none`
- Use bloc that emits `loadingType: ViewerLoadingType.manual` (or `.background`)
- Or pump `BackgroundLoadingIndicator` in isolation with `isLoading: true`

#### 9. Error dialog

- Trigger `BlocListener` by emitting `errorType: ViewerErrorType.noMoreImages` (or `.fetchTimeout`, `.unableToFetchImage`)
- `showCustomDialog` uses `addPostFrameCallback` → need `pump()` then `pump()` to show dialog
- Capture overlay; dialog is centered with `Icons.image_not_supported_outlined`, message, "Okay" button

#### 10. Animated background (carousel position colors)

- `LiquidBackground` receives colors from `blendedColorsNotifier` (driven by `displayImageForColor` from carousel)
- **Shader constraint:** `LiquidBackground` uses `FragmentShader` + `gradient.frag`. Flutter golden tests run in a software renderer; shaders *may* produce different pixels across machines.
- **Options:**
  - **A)** Golden-test a **shader-free fallback** widget when `kGoldenTests` is true (e.g. `Gradient` or `CustomPaint` with `Canvas.drawRect` + solid colors)
  - **B)** Skip `LiquidBackground` in golden tests; test `AnimatedBackground` with a mock `colorsListenable` that provides fixed colors
  - **C)** Use `RenderRepaintBoundary` + `toImage()` and compare a small region (e.g. center) — may still be flaky across CI
- **Recommended:** Option B — create a testable `AnimatedBackground` variant that accepts `colors: [Color, ...]` directly and uses a simple gradient (no shader). Golden test that. Document that shader output is tested separately (manual/visual).

---

## File Layout

```
feature/image_viewer/
├── test/
│   └── golden/
│       ├── golden_test.dart           # Main golden test file
│       ├── golden_test_config.dart    # loadAppFonts, defaultPump, etc.
│       └── golden/
│           ├── intro_state.png
│           ├── carousel_collapsed.png
│           ├── expanded_card_long_text.png
│           ├── control_bar_collapsed.png
│           ├── control_bar_expanded.png
│           ├── control_bar_light.png
│           ├── control_bar_dark.png
│           ├── loading_indicator.png
│           ├── error_dialog.png
│           └── animated_background_colors.png
```

---

## Run Commands

```bash
# Create/update goldens (first run or after intentional UI change)
cd feature/image_viewer
flutter test test/golden/golden_test.dart --update-goldens

# Verify goldens (CI)
flutter test test/golden/golden_test.dart
```

---

## Edge Cases & Caveats

| Issue | Mitigation |
|-------|------------|
| Shader (`gradient.frag`) pixel variance | Use shader-free fallback or mock `colorsListenable` for snapshot |
| Video init async | Use `overlayBuilder` with static thumbnail for intro golden |
| `showCustomDialog` deferred | `pump()` + `pump()` to flush `addPostFrameCallback` |
| Font rendering differences | `GoldenToolkit.loadAppFonts()` or use `testGoldenFile` with consistent font fallback |
| Device pixel ratio | Lock `MediaQuery` / surface size per golden |
| Animations mid-frame | `pumpAndSettle()` or `pump(duration)` to reach stable state |

---

## Implemented (10 tests)

| Golden | Status |
|--------|--------|
| control_bar_collapsed | ✓ |
| control_bar_expanded | ✓ |
| control_bar_light | ✓ |
| control_bar_dark | ✓ |
| loading_indicator | ✓ |
| intro_state | ✓ |
| expanded_card_long_text | ✓ |
| error_dialog | ✓ |
| carousel_collapsed | ✓ |
| animated_background_colors | ✓ |

**Shader fallback:** `LiquidBackground` catches shader load failures and renders a `LinearGradient` fallback when the `.frag` asset isn't available (e.g. in package tests). Production uses the real shader.

## Checklist Before Merging

- [x] 10 golden snapshots captured and committed
- [x] README updated with golden test section
