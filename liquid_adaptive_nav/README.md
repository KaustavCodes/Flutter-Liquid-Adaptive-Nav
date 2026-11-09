# liquid_adaptive_nav

Adaptive Apple **Liquid Glass** navigation bars, foldable & iPhone Duo vertical side-strip docking, a collapsible macOS/desktop sidebar, and full Light/Dark theme customization — built on top of [`display_posture_detector`](https://github.com/KaustavCodes/Flutter-Display-Posture-Detector-Plugin).

## Features

- **Native iOS 26+ `UIGlassEffect` Capsules**: Renders real non-interactive UIKit liquid glass backdrops (`LiquidGlassCapsule`) behind crisp Flutter icons and labels, with automatic `UIBlurEffect` fallback on pre-iOS 26 and `BackdropFilter` fallback on macOS, Android, and headless widget tests.
- **Responsive Multi-Platform Navigation Shell (`LiquidAdaptiveNavShell`)**:
  - **iOS / macOS Compact**: Floating frosted glass pill (`FloatingPillNavBar`) with sliding active indicator.
  - **Foldable / iPhone Duo Side Strip**: Docks vertically along the asymmetric hardware strip edge while keeping hardware camera/status regions clear and expanding `MediaQuery` safe insets for content automatically.
  - **macOS / Desktop / Landscape Tablet**: Collapsible sectioned sidebar (`MacOSSidebarNavigation`) with custom brand header, footer, and animated collapsed toolbar.
  - **Android**: Material 3 `NavigationBar` by default (`FloatingNavPlatformStyle.adaptive`) — or opt into frosted glass anywhere with `FloatingNavPlatformStyle.appleGlass`.
- **Pushed Screen Action Strip (`DuoSideActionStrip` & `LiquidDuoPageContainer`)**: Vertical frosted action capsule (Back, Edit, Delete, etc.) docked cleanly on asymmetric Duo strips.
- **Full Light/Dark & Typography Theming (`LiquidAdaptiveNavTheme`)**:
  - `LiquidAdaptiveNavTheme.light(...)`, `.dark(...)`, `.fromColorScheme(...)`, and `.adaptive(...)`
  - Works seamlessly with `ThemeData.extensions` (with smooth `lerp` crossfades), `LiquidAdaptiveNavThemeScope` for `CupertinoApp`, or per-widget overrides.
  - Customize `fontFamily`, per-state `TextStyle`s, `selectedColor`, `unselectedColor`, icon/label/indicator colors, gradients, glass blur sigma, and native iOS `tintColor`.

## Supported Platforms

| Platform | Navigation Style | Hardware Glass / Backdrop |
| --- | --- | --- |
| **iOS** | Floating Pill + Asymmetric Duo Vertical Strip + `DuoSideActionStrip` | Native `UIGlassEffect` (iOS 26+) -> `UIBlurEffect` (< iOS 26) |
| **macOS** | Collapsible Sectioned Sidebar + Collapsed Toolbar (Floating Pill when compact) | `BackdropFilter` Frosted Capsule |
| **Android** | Material 3 `NavigationBar` (or optional `appleGlass` Pill) + Foldable Posture Support | Material 3 / `BackdropFilter` |

## Quick Start

```dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_adaptive_nav/liquid_adaptive_nav.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      themeMode: ThemeMode.system,
      theme: ThemeData(
        brightness: Brightness.light,
        extensions: [
          LiquidAdaptiveNavTheme.light(
            fontFamily: 'Avenir Next',
            selectedColor: const Color(0xFF007AFF),
            unselectedColor: const Color(0xFF3A3A3C),
            activeIndicatorColor: const Color(0xFFE8EEF5),
          ),
        ],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        extensions: [
          LiquidAdaptiveNavTheme.dark(
            fontFamily: 'Avenir Next',
            selectedColor: const Color(0xFF38BDF8),
            unselectedColor: const Color(0xFF8E8E93),
            activeIndicatorColor: const Color(0x333B82F6),
          ),
        ],
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return LiquidAdaptiveNavShell(
      sidebarTitle: 'MyApp',
      destinations: const [
        LiquidNavDestination(
          id: 'home',
          label: 'Home',
          icon: CupertinoIcons.house,
          selectedIcon: CupertinoIcons.house_fill,
          materialIcon: Icons.home_outlined,
          materialSelectedIcon: Icons.home,
        ),
        LiquidNavDestination(
          id: 'library',
          label: 'Library',
          icon: CupertinoIcons.book,
          selectedIcon: CupertinoIcons.book_fill,
          materialIcon: Icons.menu_book_outlined,
          materialSelectedIcon: Icons.menu_book,
        ),
        LiquidNavDestination(
          id: 'settings',
          label: 'Settings',
          icon: CupertinoIcons.gear_alt,
          selectedIcon: CupertinoIcons.gear_alt_fill,
          materialIcon: Icons.settings_outlined,
          materialSelectedIcon: Icons.settings,
        ),
      ],
      selectedIndex: _selectedIndex,
      onDestinationSelected: (i) => setState(() => _selectedIndex = i),
      bodyBuilder: (context, metrics) => Center(
        child: Text('Tab $_selectedIndex • ${metrics.sizeClass.name}'),
      ),
    );
  }
}
```

## Example App

See [`example/lib/main.dart`](example/lib/main.dart) for an interactive demo featuring Light/Dark/System switching, color presets, live font family & label size customization, blur slider, native iOS `UIGlassEffect` tinting, pushed `LiquidDuoPageContainer` / `DuoSideActionStrip`, and collapsible macOS sidebar controls.
