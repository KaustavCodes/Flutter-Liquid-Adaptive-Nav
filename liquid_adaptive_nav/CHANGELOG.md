## 0.0.4

* Wide Android windows and `FloatingNavPlatformStyle.material` now use a Material 3 `NavigationRail`. Compact windows still use `NavigationBar`. `appleGlass` keeps the frosted pill and the desktop sidebar.
* Horizontal glass pills expand the content `MediaQuery` bottom padding so `SafeArea` and list padding clear the bar.
* The active pill indicator follows right-to-left layouts.
* The Flutter `BackdropFilter` capsule honors `tintColor`. Opaque tints are drawn as a light wash. Translucent tints keep their alpha.
* `LiquidAdaptiveNavTheme` implements `==` and `hashCode`.
* A collapsed sidebar ignores pointers and drops its semantics.
* Hinge gap helpers return `0` when that axis has no hinge thickness.
* The example can preview iOS, Android, and macOS chrome, right-to-left layout, glass tint, and bottom clearance.

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
