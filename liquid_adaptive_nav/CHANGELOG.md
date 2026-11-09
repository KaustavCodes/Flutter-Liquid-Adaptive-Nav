## 0.0.3

* Updated `display_posture_detector` dependency to `^0.0.5`.
* Synchronized `0.0.3` version metadata across iOS/macOS podspecs and `README.md`.

## 0.0.2

* Shortened `pubspec.yaml` package `description` to within pub.dev's 60–180 character guideline.
* Synchronized `0.0.2` version metadata across iOS/macOS podspecs and `README.md`.

## 0.0.1

* Initial release of `liquid_adaptive_nav` with support for **iOS**, **macOS**, and **Android**.
* Added `LiquidGlassCapsule` with automatic native iOS 26+ `UIGlassEffect` (`UiKitView` passthrough platform view), pre-iOS 26 `UIBlurEffect` fallback, and cross-platform `BackdropFilter` rendering.
* Added `FloatingPillNavBar` supporting arbitrary destination counts, sliding active indicator, vertical foldable/iPhone Duo side-strip docking, and Material 3 Android `NavigationBar` (`FloatingNavPlatformStyle`).
* Added `MacOSSidebarNavigation` with collapsible sectioned navigation, generic headers/footers, and animated collapsed toolbar toggle.
* Added `DuoSideActionStrip` and `LiquidDuoPageContainer` for pushed sub-screens with camera/status occlusion avoidance.
* Added `LiquidAdaptiveNavShell` and `ResponsivePostureBuilder` powered by `display_posture_detector`.
* Added `LiquidAdaptiveNavTheme` (`ThemeExtension`) and `LiquidAdaptiveNavThemeScope` with `.light()`, `.dark()`, `.fromColorScheme()`, `.adaptive()`, full typography/font-family cascading, and customizable selected/unselected/indicator colors.
