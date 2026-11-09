import 'dart:ui' show lerpDouble;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Comprehensive theme configuration for all `liquid_adaptive_nav` surfaces
/// (`LiquidAdaptiveNavShell`, `FloatingPillNavBar`, `LiquidGlassCapsule`,
/// `DuoSideActionStrip`, and `MacOSSidebarNavigation`).
///
/// Works seamlessly in three ways:
/// 1. As a Material [ThemeExtension] inside light & dark `ThemeData.extensions`
///    (automatically crossfading on `ThemeMode` changes via [lerp]).
/// 2. Via [LiquidAdaptiveNavThemeScope] (ideal for [CupertinoApp] subtrees).
/// 3. Directly passed to any navigation widget via `theme:` or `lightTheme:` /
///    `darkTheme:`.
@immutable
class LiquidAdaptiveNavTheme extends ThemeExtension<LiquidAdaptiveNavTheme> {
  // Typography
  final String? fontFamily;
  final TextStyle? labelTextStyle;
  final TextStyle? selectedLabelTextStyle;
  final TextStyle? verticalLabelTextStyle;
  final TextStyle? selectedVerticalLabelTextStyle;
  final TextStyle? actionStripLabelTextStyle;
  final TextStyle? sidebarItemTextStyle;
  final TextStyle? selectedSidebarItemTextStyle;
  final TextStyle? sidebarSectionHeaderTextStyle;
  final TextStyle? sidebarTitleTextStyle;
  final TextStyle? collapsedToolbarTitleTextStyle;

  // Pill & Strip Colors
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedIconColor;
  final Color? unselectedIconColor;
  final Color? selectedLabelColor;
  final Color? unselectedLabelColor;
  final Color? activeIndicatorColor;
  final Gradient? activeIndicatorGradient;
  final double activeIndicatorBorderRadius;

  // Android Material NavigationBar Styling
  final Color? androidBarBackgroundColor;
  final Color? androidIndicatorColor;
  final Color? androidSelectedIconColor;
  final Color? androidUnselectedIconColor;
  final Color? androidSelectedLabelColor;
  final Color? androidUnselectedLabelColor;
  final double androidElevation;

  // Liquid Glass Capsule Surface
  final bool enableNativeGlass;
  final double blurSigma;
  final List<Color>? glassGradientColors;
  final Color? glassBorderColor;
  final double glassBorderWidth;
  final Color? glassHairlineBorderColor;
  final List<BoxShadow>? glassShadows;
  final Color? nativeGlassTintColor;

  // Duo Action Strip
  final Color? actionStripIconColor;
  final Color? actionStripLabelColor;
  final Color? actionStripDividerColor;

  // Desktop / macOS Sidebar & Collapsed Toolbar
  final double sidebarWidth;
  final Color? sidebarBackgroundColor;
  final Color? sidebarDividerColor;
  final Color? sidebarSelectedColor;
  final Gradient? sidebarSelectedGradient;
  final Color? sidebarSelectedForegroundColor;
  final Color? sidebarSelectedIconColor;
  final Color? sidebarUnselectedIconColor;
  final Color? sidebarUnselectedTextColor;
  final Color? sidebarSectionHeaderColor;
  final Color? sidebarSelectedBorderColor;
  final Color? sidebarSelectedShadowColor;
  final List<Color>? sidebarToggleButtonColors;
  final Color? sidebarToggleBorderColor;
  final Color? sidebarToggleIconColor;
  final double collapsedToolbarHeight;
  final Color? collapsedToolbarBackgroundColor;
  final Color? collapsedToolbarDividerColor;
  final Color? collapsedToolbarTitleColor;
  final Color? scaffoldBackgroundColor;

  // Horizontal Pill Geometry & Haptics
  final double horizontalPillHeight;
  final double horizontalPillMaxWidth;
  final double horizontalPillCornerRadius;
  final EdgeInsets? horizontalPillMargin;
  final bool enableHaptics;
  final VoidCallback? onInteractionFeedback;

  const LiquidAdaptiveNavTheme({
    this.fontFamily,
    this.labelTextStyle,
    this.selectedLabelTextStyle,
    this.verticalLabelTextStyle,
    this.selectedVerticalLabelTextStyle,
    this.actionStripLabelTextStyle,
    this.sidebarItemTextStyle,
    this.selectedSidebarItemTextStyle,
    this.sidebarSectionHeaderTextStyle,
    this.sidebarTitleTextStyle,
    this.collapsedToolbarTitleTextStyle,
    this.selectedColor,
    this.unselectedColor,
    this.selectedIconColor,
    this.unselectedIconColor,
    this.selectedLabelColor,
    this.unselectedLabelColor,
    this.activeIndicatorColor,
    this.activeIndicatorGradient,
    this.activeIndicatorBorderRadius = 28.0,
    this.androidBarBackgroundColor,
    this.androidIndicatorColor,
    this.androidSelectedIconColor,
    this.androidUnselectedIconColor,
    this.androidSelectedLabelColor,
    this.androidUnselectedLabelColor,
    this.androidElevation = 3.0,
    this.enableNativeGlass = true,
    this.blurSigma = 28.0,
    this.glassGradientColors,
    this.glassBorderColor,
    this.glassBorderWidth = 1.0,
    this.glassHairlineBorderColor,
    this.glassShadows,
    this.nativeGlassTintColor,
    this.actionStripIconColor,
    this.actionStripLabelColor,
    this.actionStripDividerColor,
    this.sidebarWidth = 230.0,
    this.sidebarBackgroundColor,
    this.sidebarDividerColor,
    this.sidebarSelectedColor,
    this.sidebarSelectedGradient,
    this.sidebarSelectedForegroundColor,
    this.sidebarSelectedIconColor,
    this.sidebarUnselectedIconColor,
    this.sidebarUnselectedTextColor,
    this.sidebarSectionHeaderColor,
    this.sidebarSelectedBorderColor,
    this.sidebarSelectedShadowColor,
    this.sidebarToggleButtonColors,
    this.sidebarToggleBorderColor,
    this.sidebarToggleIconColor,
    this.collapsedToolbarHeight = 46.0,
    this.collapsedToolbarBackgroundColor,
    this.collapsedToolbarDividerColor,
    this.collapsedToolbarTitleColor,
    this.scaffoldBackgroundColor,
    this.horizontalPillHeight = 64.0,
    this.horizontalPillMaxWidth = 400.0,
    this.horizontalPillCornerRadius = 36.0,
    this.horizontalPillMargin,
    this.enableHaptics = true,
    this.onInteractionFeedback,
  });

  /// Clean light-mode Apple Liquid Glass preset.
  factory LiquidAdaptiveNavTheme.light({
    String? fontFamily,
    Color selectedColor = const Color(0xFF007AFF),
    Color unselectedColor = const Color(0xFF1C1C1E),
    Color activeIndicatorColor = const Color(0xFFE8EEF5),
    Gradient? activeIndicatorGradient,
    Color? androidIndicatorColor,
    Color? androidBarBackgroundColor,
    Color? sidebarSelectedColor,
    Gradient? sidebarSelectedGradient,
    Color? nativeGlassTintColor,
    bool enableNativeGlass = true,
    double blurSigma = 28.0,
    bool enableHaptics = true,
    VoidCallback? onInteractionFeedback,
  }) {
    final macStart = _shiftLightness(selectedColor, 0.08);
    final macEnd = _shiftLightness(selectedColor, -0.06);
    return LiquidAdaptiveNavTheme(
      fontFamily: fontFamily,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      selectedIconColor: selectedColor,
      unselectedIconColor: unselectedColor,
      selectedLabelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      activeIndicatorColor: activeIndicatorColor,
      activeIndicatorGradient: activeIndicatorGradient,
      androidBarBackgroundColor: androidBarBackgroundColor ?? Colors.white,
      androidIndicatorColor:
          androidIndicatorColor ?? selectedColor.withValues(alpha: 0.16),
      androidSelectedIconColor: selectedColor,
      androidUnselectedIconColor: unselectedColor,
      androidSelectedLabelColor: selectedColor,
      androidUnselectedLabelColor: unselectedColor,
      enableNativeGlass: enableNativeGlass,
      blurSigma: blurSigma,
      glassGradientColors: [
        Colors.white.withValues(alpha: 0.74),
        const Color(0xFFF0F0F5).withValues(alpha: 0.46),
      ],
      glassBorderColor: Colors.white.withValues(alpha: 0.80),
      glassHairlineBorderColor: Colors.black.withValues(alpha: 0.06),
      glassShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.14),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
      nativeGlassTintColor: nativeGlassTintColor,
      actionStripIconColor: const Color(0xFF1C1C1E),
      actionStripLabelColor: const Color(0xFF3A3A3C),
      actionStripDividerColor: Colors.black.withValues(alpha: 0.08),
      sidebarBackgroundColor: const Color(0xFFF2F2F7),
      sidebarDividerColor: const Color(0xFFDCDCE0),
      sidebarSelectedColor: sidebarSelectedColor ?? selectedColor,
      sidebarSelectedGradient:
          sidebarSelectedGradient ??
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [macStart, macEnd],
          ),
      sidebarSelectedForegroundColor: Colors.white,
      sidebarSelectedIconColor: Colors.white,
      sidebarUnselectedIconColor: selectedColor,
      sidebarUnselectedTextColor: const Color(0xFF1C1C1E),
      sidebarSectionHeaderColor: const Color(0xFF8E8E93),
      sidebarSelectedBorderColor: Colors.white.withValues(alpha: 0.22),
      sidebarSelectedShadowColor: macEnd.withValues(alpha: 0.28),
      sidebarToggleButtonColors: const [Colors.white, Color(0xFFE9E9EE)],
      sidebarToggleBorderColor: Colors.black.withValues(alpha: 0.12),
      sidebarToggleIconColor: const Color(0xFF3C3C43),
      collapsedToolbarBackgroundColor: const Color(0xFFF6F6F9),
      collapsedToolbarDividerColor: const Color(0xFFE2E2E8),
      collapsedToolbarTitleColor: const Color(0xFF52525B),
      scaffoldBackgroundColor: const Color(0xFFF8F8FA),
      enableHaptics: enableHaptics,
      onInteractionFeedback: onInteractionFeedback,
    );
  }

  /// Clean dark-mode Apple Liquid Glass preset.
  factory LiquidAdaptiveNavTheme.dark({
    String? fontFamily,
    Color selectedColor = const Color(0xFF38BDF8),
    Color unselectedColor = const Color(0xFF8E8E93),
    Color activeIndicatorColor = const Color(0x333B82F6),
    Gradient? activeIndicatorGradient,
    Color? androidIndicatorColor,
    Color? androidBarBackgroundColor,
    Color? sidebarSelectedColor,
    Gradient? sidebarSelectedGradient,
    Color? nativeGlassTintColor,
    bool enableNativeGlass = true,
    double blurSigma = 28.0,
    bool enableHaptics = true,
    VoidCallback? onInteractionFeedback,
  }) {
    final macStart = const Color(0xFF4B91FF);
    final macEnd = const Color(0xFF2563EB);
    final useCustomSidebarGradient =
        sidebarSelectedGradient == null &&
        selectedColor != const Color(0xFF38BDF8);
    return LiquidAdaptiveNavTheme(
      fontFamily: fontFamily,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      selectedIconColor: selectedColor,
      unselectedIconColor: unselectedColor,
      selectedLabelColor: selectedColor,
      unselectedLabelColor: unselectedColor,
      activeIndicatorColor: activeIndicatorColor,
      activeIndicatorGradient: activeIndicatorGradient,
      androidBarBackgroundColor:
          androidBarBackgroundColor ?? const Color(0xFF1E1E22),
      androidIndicatorColor:
          androidIndicatorColor ?? selectedColor.withValues(alpha: 0.22),
      androidSelectedIconColor: selectedColor,
      androidUnselectedIconColor: unselectedColor,
      androidSelectedLabelColor: selectedColor,
      androidUnselectedLabelColor: unselectedColor,
      enableNativeGlass: enableNativeGlass,
      blurSigma: blurSigma,
      glassGradientColors: [
        const Color(0xFF2C2C35).withValues(alpha: 0.42),
        const Color(0xFF181820).withValues(alpha: 0.25),
      ],
      glassBorderColor: Colors.white.withValues(alpha: 0.18),
      glassHairlineBorderColor: Colors.transparent,
      glassShadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.48),
          blurRadius: 26,
          offset: const Offset(0, 9),
          spreadRadius: -2,
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.25),
          blurRadius: 9,
          offset: const Offset(0, 3),
        ),
      ],
      nativeGlassTintColor: nativeGlassTintColor,
      actionStripIconColor: Colors.white,
      actionStripLabelColor: Colors.white70,
      actionStripDividerColor: Colors.white.withValues(alpha: 0.12),
      sidebarBackgroundColor: const Color(0xFF1E1E22),
      sidebarDividerColor: const Color(0xFF2C2C32),
      sidebarSelectedColor: sidebarSelectedColor ?? selectedColor,
      sidebarSelectedGradient:
          sidebarSelectedGradient ??
          LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: useCustomSidebarGradient
                ? [
                    _shiftLightness(selectedColor, 0.06),
                    _shiftLightness(selectedColor, -0.08),
                  ]
                : [macStart, macEnd],
          ),
      sidebarSelectedForegroundColor: Colors.white,
      sidebarSelectedIconColor: Colors.white,
      sidebarUnselectedIconColor: selectedColor,
      sidebarUnselectedTextColor: const Color(0xFFF4F4F5),
      sidebarSectionHeaderColor: const Color(0xFF71717A),
      sidebarSelectedBorderColor: Colors.white.withValues(alpha: 0.22),
      sidebarSelectedShadowColor:
          (useCustomSidebarGradient ? selectedColor : macEnd).withValues(
            alpha: 0.28,
          ),
      sidebarToggleButtonColors: const [Color(0xFF2E2E35), Color(0xFF232329)],
      sidebarToggleBorderColor: Colors.white.withValues(alpha: 0.14),
      sidebarToggleIconColor: const Color(0xFFE4E4E7),
      collapsedToolbarBackgroundColor: const Color(0xFF18181B),
      collapsedToolbarDividerColor: const Color(0xFF27272D),
      collapsedToolbarTitleColor: const Color(0xFFB4B4BD),
      scaffoldBackgroundColor: const Color(0xFF121214),
      enableHaptics: enableHaptics,
      onInteractionFeedback: onInteractionFeedback,
    );
  }

  /// Derives a cohesive theme from a Material 3 [ColorScheme].
  factory LiquidAdaptiveNavTheme.fromColorScheme(
    ColorScheme colorScheme, {
    String? fontFamily,
    bool enableNativeGlass = true,
  }) {
    final isDark = colorScheme.brightness == Brightness.dark;
    final base = isDark
        ? LiquidAdaptiveNavTheme.dark(
            fontFamily: fontFamily,
            selectedColor: colorScheme.primary,
            unselectedColor: colorScheme.onSurfaceVariant,
            activeIndicatorColor: colorScheme.primaryContainer.withValues(
              alpha: 0.55,
            ),
            androidBarBackgroundColor: colorScheme.surfaceContainer,
            androidIndicatorColor: colorScheme.secondaryContainer,
            enableNativeGlass: enableNativeGlass,
          )
        : LiquidAdaptiveNavTheme.light(
            fontFamily: fontFamily,
            selectedColor: colorScheme.primary,
            unselectedColor: colorScheme.onSurfaceVariant,
            activeIndicatorColor: colorScheme.primaryContainer.withValues(
              alpha: 0.75,
            ),
            androidBarBackgroundColor: colorScheme.surfaceContainer,
            androidIndicatorColor: colorScheme.secondaryContainer,
            enableNativeGlass: enableNativeGlass,
          );
    return base.copyWith(scaffoldBackgroundColor: colorScheme.surface);
  }

  /// Convenience factory selecting [LiquidAdaptiveNavTheme.light] or
  /// [LiquidAdaptiveNavTheme.dark] for [brightness].
  factory LiquidAdaptiveNavTheme.adaptive({
    required Brightness brightness,
    String? fontFamily,
    Color? selectedColor,
    Color? unselectedColor,
    Color? activeIndicatorColor,
    bool enableNativeGlass = true,
  }) {
    return brightness == Brightness.dark
        ? LiquidAdaptiveNavTheme.dark(
            fontFamily: fontFamily,
            selectedColor: selectedColor ?? const Color(0xFF38BDF8),
            unselectedColor: unselectedColor ?? const Color(0xFF8E8E93),
            activeIndicatorColor:
                activeIndicatorColor ?? const Color(0x333B82F6),
            enableNativeGlass: enableNativeGlass,
          )
        : LiquidAdaptiveNavTheme.light(
            fontFamily: fontFamily,
            selectedColor: selectedColor ?? const Color(0xFF007AFF),
            unselectedColor: unselectedColor ?? const Color(0xFF1C1C1E),
            activeIndicatorColor:
                activeIndicatorColor ?? const Color(0xFFE8EEF5),
            enableNativeGlass: enableNativeGlass,
          );
  }

  static Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.05, 0.92))
        .toColor();
  }

  /// Resolves the active [Brightness] considering an explicit override, Material
  /// [Theme], explicit [CupertinoTheme], or system platform brightness.
  static Brightness resolveBrightness(
    BuildContext context, {
    Brightness? brightnessOverride,
  }) {
    if (brightnessOverride != null) return brightnessOverride;
    final inheritedCupertino = context
        .dependOnInheritedWidgetOfExactType<InheritedCupertinoTheme>();
    final materialBrightness = Theme.of(context).brightness;
    if (inheritedCupertino != null &&
        inheritedCupertino.theme.data.brightness != null &&
        materialBrightness == Brightness.light) {
      return inheritedCupertino.theme.data.brightness!;
    }
    return materialBrightness;
  }

  /// Resolves the effective [LiquidAdaptiveNavTheme] for [context], filling any
  /// unspecified fields from the matching light/dark default preset.
  static LiquidAdaptiveNavTheme resolve(
    BuildContext context, {
    LiquidAdaptiveNavTheme? override,
    LiquidAdaptiveNavTheme? lightTheme,
    LiquidAdaptiveNavTheme? darkTheme,
    Brightness? brightnessOverride,
  }) {
    final brightness = resolveBrightness(
      context,
      brightnessOverride: brightnessOverride,
    );
    final isDark = brightness == Brightness.dark;
    final defaults = isDark
        ? LiquidAdaptiveNavTheme.dark()
        : LiquidAdaptiveNavTheme.light();

    final fromMode = isDark ? darkTheme : lightTheme;
    final fromExtension = Theme.of(context).extension<LiquidAdaptiveNavTheme>();
    final fromScope = LiquidAdaptiveNavThemeScope.maybeOf(context);

    final active = override ?? fromMode ?? fromExtension ?? fromScope;
    if (active == null) return defaults;
    return defaults.merge(active);
  }

  /// Triggers the configured interaction feedback if [enableHaptics] is `true`.
  void triggerFeedback() {
    if (!enableHaptics) return;
    if (onInteractionFeedback != null) {
      onInteractionFeedback!();
    } else {
      HapticFeedback.selectionClick();
    }
  }

  /// Applies nullable inline widget overrides cleanly onto a resolved theme
  /// without resetting unrelated theme defaults like [enableNativeGlass],
  /// [blurSigma], or [enableHaptics].
  LiquidAdaptiveNavTheme withOverrides({
    String? fontFamily,
    TextStyle? labelTextStyle,
    TextStyle? selectedLabelTextStyle,
    TextStyle? verticalLabelTextStyle,
    TextStyle? selectedVerticalLabelTextStyle,
    TextStyle? actionStripLabelTextStyle,
    TextStyle? sidebarItemTextStyle,
    TextStyle? selectedSidebarItemTextStyle,
    TextStyle? sidebarSectionHeaderTextStyle,
    TextStyle? sidebarTitleTextStyle,
    TextStyle? collapsedToolbarTitleTextStyle,
    Color? selectedColor,
    Color? unselectedColor,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    Color? activeIndicatorColor,
    Gradient? activeIndicatorGradient,
    Color? androidBarBackgroundColor,
    Color? androidIndicatorColor,
    Color? androidSelectedIconColor,
    Color? androidUnselectedIconColor,
    Color? androidSelectedLabelColor,
    Color? androidUnselectedLabelColor,
    double? androidElevation,
    bool? enableNativeGlass,
    double? blurSigma,
    Color? nativeGlassTintColor,
    Color? actionStripIconColor,
    Color? actionStripLabelColor,
    Color? actionStripDividerColor,
    double? sidebarWidth,
    Color? sidebarBackgroundColor,
    Color? sidebarDividerColor,
    Color? sidebarSelectedColor,
    Gradient? sidebarSelectedGradient,
    Color? sidebarSelectedForegroundColor,
    Color? sidebarUnselectedIconColor,
    Color? sidebarUnselectedTextColor,
    Color? sidebarSectionHeaderColor,
    Color? scaffoldBackgroundColor,
    bool? enableHaptics,
    VoidCallback? onInteractionFeedback,
  }) {
    final nextSelectedIcon = selectedIconColor ?? selectedColor;
    final nextUnselectedIcon = unselectedIconColor ?? unselectedColor;
    final nextSelectedLabel = selectedLabelColor ?? selectedColor;
    final nextUnselectedLabel = unselectedLabelColor ?? unselectedColor;

    return copyWith(
      fontFamily: fontFamily,
      labelTextStyle: labelTextStyle,
      selectedLabelTextStyle: selectedLabelTextStyle,
      verticalLabelTextStyle: verticalLabelTextStyle,
      selectedVerticalLabelTextStyle: selectedVerticalLabelTextStyle,
      actionStripLabelTextStyle: actionStripLabelTextStyle,
      sidebarItemTextStyle: sidebarItemTextStyle,
      selectedSidebarItemTextStyle: selectedSidebarItemTextStyle,
      sidebarSectionHeaderTextStyle: sidebarSectionHeaderTextStyle,
      sidebarTitleTextStyle: sidebarTitleTextStyle,
      collapsedToolbarTitleTextStyle: collapsedToolbarTitleTextStyle,
      selectedColor: selectedColor,
      unselectedColor: unselectedColor,
      selectedIconColor: nextSelectedIcon,
      unselectedIconColor: nextUnselectedIcon,
      selectedLabelColor: nextSelectedLabel,
      unselectedLabelColor: nextUnselectedLabel,
      activeIndicatorColor: activeIndicatorColor,
      activeIndicatorGradient: activeIndicatorGradient,
      androidBarBackgroundColor: androidBarBackgroundColor,
      androidIndicatorColor: androidIndicatorColor ?? activeIndicatorColor,
      androidSelectedIconColor: androidSelectedIconColor ?? nextSelectedIcon,
      androidUnselectedIconColor:
          androidUnselectedIconColor ?? nextUnselectedIcon,
      androidSelectedLabelColor: androidSelectedLabelColor ?? nextSelectedLabel,
      androidUnselectedLabelColor:
          androidUnselectedLabelColor ?? nextUnselectedLabel,
      androidElevation: androidElevation,
      enableNativeGlass: enableNativeGlass,
      blurSigma: blurSigma,
      nativeGlassTintColor: nativeGlassTintColor,
      actionStripIconColor: actionStripIconColor,
      actionStripLabelColor: actionStripLabelColor,
      actionStripDividerColor: actionStripDividerColor,
      sidebarWidth: sidebarWidth,
      sidebarBackgroundColor: sidebarBackgroundColor,
      sidebarDividerColor: sidebarDividerColor,
      sidebarSelectedColor: sidebarSelectedColor ?? selectedColor,
      sidebarSelectedGradient: sidebarSelectedGradient,
      sidebarSelectedForegroundColor: sidebarSelectedForegroundColor,
      sidebarUnselectedIconColor: sidebarUnselectedIconColor ?? selectedColor,
      sidebarUnselectedTextColor: sidebarUnselectedTextColor ?? unselectedColor,
      sidebarSectionHeaderColor: sidebarSectionHeaderColor,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      enableHaptics: enableHaptics,
      onInteractionFeedback: onInteractionFeedback,
    );
  }

  /// Returns a new [LiquidAdaptiveNavTheme] where non-null properties of [other]
  /// take precedence over `this`, automatically deriving dependent icon/label/
  /// indicator colors if `other` only specified broad colors such as
  /// [selectedColor], [unselectedColor], or [fontFamily].
  LiquidAdaptiveNavTheme merge(LiquidAdaptiveNavTheme? other) {
    if (other == null) return this;
    final nextSelected = other.selectedColor ?? selectedColor;
    final nextUnselected = other.unselectedColor ?? unselectedColor;

    final nextSelectedIcon =
        other.selectedIconColor ?? other.selectedColor ?? selectedIconColor;
    final nextUnselectedIcon =
        other.unselectedIconColor ??
        other.unselectedColor ??
        unselectedIconColor;
    final nextSelectedLabel =
        other.selectedLabelColor ?? other.selectedColor ?? selectedLabelColor;
    final nextUnselectedLabel =
        other.unselectedLabelColor ??
        other.unselectedColor ??
        unselectedLabelColor;

    return LiquidAdaptiveNavTheme(
      fontFamily: other.fontFamily ?? fontFamily,
      labelTextStyle: other.labelTextStyle ?? labelTextStyle,
      selectedLabelTextStyle:
          other.selectedLabelTextStyle ?? selectedLabelTextStyle,
      verticalLabelTextStyle:
          other.verticalLabelTextStyle ?? verticalLabelTextStyle,
      selectedVerticalLabelTextStyle:
          other.selectedVerticalLabelTextStyle ??
          selectedVerticalLabelTextStyle,
      actionStripLabelTextStyle:
          other.actionStripLabelTextStyle ?? actionStripLabelTextStyle,
      sidebarItemTextStyle: other.sidebarItemTextStyle ?? sidebarItemTextStyle,
      selectedSidebarItemTextStyle:
          other.selectedSidebarItemTextStyle ?? selectedSidebarItemTextStyle,
      sidebarSectionHeaderTextStyle:
          other.sidebarSectionHeaderTextStyle ?? sidebarSectionHeaderTextStyle,
      sidebarTitleTextStyle:
          other.sidebarTitleTextStyle ?? sidebarTitleTextStyle,
      collapsedToolbarTitleTextStyle:
          other.collapsedToolbarTitleTextStyle ??
          collapsedToolbarTitleTextStyle,
      selectedColor: nextSelected,
      unselectedColor: nextUnselected,
      selectedIconColor: nextSelectedIcon,
      unselectedIconColor: nextUnselectedIcon,
      selectedLabelColor: nextSelectedLabel,
      unselectedLabelColor: nextUnselectedLabel,
      activeIndicatorColor: other.activeIndicatorColor ?? activeIndicatorColor,
      activeIndicatorGradient:
          other.activeIndicatorGradient ?? activeIndicatorGradient,
      activeIndicatorBorderRadius: other.activeIndicatorBorderRadius,
      androidBarBackgroundColor:
          other.androidBarBackgroundColor ?? androidBarBackgroundColor,
      androidIndicatorColor:
          other.androidIndicatorColor ??
          (other.activeIndicatorColor ?? androidIndicatorColor),
      androidSelectedIconColor:
          other.androidSelectedIconColor ?? nextSelectedIcon,
      androidUnselectedIconColor:
          other.androidUnselectedIconColor ?? nextUnselectedIcon,
      androidSelectedLabelColor:
          other.androidSelectedLabelColor ?? nextSelectedLabel,
      androidUnselectedLabelColor:
          other.androidUnselectedLabelColor ?? nextUnselectedLabel,
      androidElevation: other.androidElevation,
      enableNativeGlass: other.enableNativeGlass,
      blurSigma: other.blurSigma,
      glassGradientColors: other.glassGradientColors ?? glassGradientColors,
      glassBorderColor: other.glassBorderColor ?? glassBorderColor,
      glassBorderWidth: other.glassBorderWidth,
      glassHairlineBorderColor:
          other.glassHairlineBorderColor ?? glassHairlineBorderColor,
      glassShadows: other.glassShadows ?? glassShadows,
      nativeGlassTintColor: other.nativeGlassTintColor ?? nativeGlassTintColor,
      actionStripIconColor: other.actionStripIconColor ?? actionStripIconColor,
      actionStripLabelColor:
          other.actionStripLabelColor ?? actionStripLabelColor,
      actionStripDividerColor:
          other.actionStripDividerColor ?? actionStripDividerColor,
      sidebarWidth: other.sidebarWidth,
      sidebarBackgroundColor:
          other.sidebarBackgroundColor ?? sidebarBackgroundColor,
      sidebarDividerColor: other.sidebarDividerColor ?? sidebarDividerColor,
      sidebarSelectedColor:
          other.sidebarSelectedColor ??
          (other.selectedColor ?? sidebarSelectedColor),
      sidebarSelectedGradient:
          other.sidebarSelectedGradient ?? sidebarSelectedGradient,
      sidebarSelectedForegroundColor:
          other.sidebarSelectedForegroundColor ??
          sidebarSelectedForegroundColor,
      sidebarSelectedIconColor:
          other.sidebarSelectedIconColor ?? sidebarSelectedIconColor,
      sidebarUnselectedIconColor:
          other.sidebarUnselectedIconColor ??
          (other.selectedColor ?? sidebarUnselectedIconColor),
      sidebarUnselectedTextColor:
          other.sidebarUnselectedTextColor ??
          (other.unselectedColor ?? sidebarUnselectedTextColor),
      sidebarSectionHeaderColor:
          other.sidebarSectionHeaderColor ?? sidebarSectionHeaderColor,
      sidebarSelectedBorderColor:
          other.sidebarSelectedBorderColor ?? sidebarSelectedBorderColor,
      sidebarSelectedShadowColor:
          other.sidebarSelectedShadowColor ?? sidebarSelectedShadowColor,
      sidebarToggleButtonColors:
          other.sidebarToggleButtonColors ?? sidebarToggleButtonColors,
      sidebarToggleBorderColor:
          other.sidebarToggleBorderColor ?? sidebarToggleBorderColor,
      sidebarToggleIconColor:
          other.sidebarToggleIconColor ?? sidebarToggleIconColor,
      collapsedToolbarHeight: other.collapsedToolbarHeight,
      collapsedToolbarBackgroundColor:
          other.collapsedToolbarBackgroundColor ??
          collapsedToolbarBackgroundColor,
      collapsedToolbarDividerColor:
          other.collapsedToolbarDividerColor ?? collapsedToolbarDividerColor,
      collapsedToolbarTitleColor:
          other.collapsedToolbarTitleColor ?? collapsedToolbarTitleColor,
      scaffoldBackgroundColor:
          other.scaffoldBackgroundColor ?? scaffoldBackgroundColor,
      horizontalPillHeight: other.horizontalPillHeight,
      horizontalPillMaxWidth: other.horizontalPillMaxWidth,
      horizontalPillCornerRadius: other.horizontalPillCornerRadius,
      horizontalPillMargin: other.horizontalPillMargin ?? horizontalPillMargin,
      enableHaptics: other.enableHaptics,
      onInteractionFeedback:
          other.onInteractionFeedback ?? onInteractionFeedback,
    );
  }

  /// Resolves the horizontal pill [TextStyle] for an item.
  TextStyle resolveHorizontalLabelStyle({required bool isSelected}) {
    final color = isSelected
        ? (selectedLabelColor ?? selectedColor ?? const Color(0xFF007AFF))
        : (unselectedLabelColor ?? unselectedColor ?? const Color(0xFF1C1C1E));
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      color: color,
      letterSpacing: -0.1,
    );
    final custom = isSelected
        ? (selectedLabelTextStyle ?? labelTextStyle)
        : labelTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? color,
        );
  }

  /// Resolves the vertical Duo side-strip pill [TextStyle] for an item.
  TextStyle resolveVerticalLabelStyle({required bool isSelected}) {
    final color = isSelected
        ? (selectedLabelColor ?? selectedColor ?? const Color(0xFF007AFF))
        : (unselectedLabelColor ?? unselectedColor ?? const Color(0xFF1C1C1E));
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 8.5,
      height: 1.1,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      color: color,
      letterSpacing: -0.15,
    );
    final custom = isSelected
        ? (selectedVerticalLabelTextStyle ?? verticalLabelTextStyle)
        : verticalLabelTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? color,
        );
  }

  /// Resolves the [DuoSideActionStrip] label [TextStyle].
  TextStyle resolveActionStripLabelStyle({Color? itemColor}) {
    final fallbackColor =
        itemColor ?? actionStripLabelColor ?? const Color(0xFF3A3A3C);
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 8.5,
      height: 1.1,
      fontWeight: FontWeight.w600,
      color: fallbackColor,
      letterSpacing: -0.15,
    );
    final custom = actionStripLabelTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: itemColor ?? custom.color ?? fallbackColor,
        );
  }

  /// Resolves the [MacOSSidebarNavigation] item [TextStyle].
  TextStyle resolveSidebarItemStyle({required bool isSelected}) {
    final color = isSelected
        ? (sidebarSelectedForegroundColor ?? Colors.white)
        : (sidebarUnselectedTextColor ?? const Color(0xFF1C1C1E));
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 13.5,
      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
      color: color,
    );
    final custom = isSelected
        ? (selectedSidebarItemTextStyle ?? sidebarItemTextStyle)
        : sidebarItemTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? color,
        );
  }

  /// Resolves the [MacOSSidebarNavigation] section header [TextStyle].
  TextStyle resolveSidebarSectionHeaderStyle() {
    final color = sidebarSectionHeaderColor ?? const Color(0xFF8E8E93);
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 11,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.2,
      color: color,
    );
    final custom = sidebarSectionHeaderTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? color,
        );
  }

  /// Resolves the [MacOSSidebarNavigation] header title [TextStyle].
  TextStyle resolveSidebarTitleStyle({required bool isDark}) {
    final fallbackColor = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 16,
      fontWeight: FontWeight.w700,
      color: fallbackColor,
    );
    final custom = sidebarTitleTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? fallbackColor,
        );
  }

  /// Resolves the collapsed desktop toolbar title [TextStyle].
  TextStyle resolveCollapsedToolbarTitleStyle({required bool isDark}) {
    final fallbackColor =
        collapsedToolbarTitleColor ??
        (isDark ? const Color(0xFFB4B4BD) : const Color(0xFF52525B));
    final base = TextStyle(
      fontFamily: fontFamily,
      fontSize: 13.5,
      fontWeight: FontWeight.w600,
      color: fallbackColor,
    );
    final custom = collapsedToolbarTitleTextStyle;
    if (custom == null) return base;
    return base
        .merge(custom)
        .copyWith(
          fontFamily: custom.fontFamily ?? fontFamily,
          color: custom.color ?? fallbackColor,
        );
  }

  @override
  LiquidAdaptiveNavTheme copyWith({
    String? fontFamily,
    TextStyle? labelTextStyle,
    TextStyle? selectedLabelTextStyle,
    TextStyle? verticalLabelTextStyle,
    TextStyle? selectedVerticalLabelTextStyle,
    TextStyle? actionStripLabelTextStyle,
    TextStyle? sidebarItemTextStyle,
    TextStyle? selectedSidebarItemTextStyle,
    TextStyle? sidebarSectionHeaderTextStyle,
    TextStyle? sidebarTitleTextStyle,
    TextStyle? collapsedToolbarTitleTextStyle,
    Color? selectedColor,
    Color? unselectedColor,
    Color? selectedIconColor,
    Color? unselectedIconColor,
    Color? selectedLabelColor,
    Color? unselectedLabelColor,
    Color? activeIndicatorColor,
    Gradient? activeIndicatorGradient,
    double? activeIndicatorBorderRadius,
    Color? androidBarBackgroundColor,
    Color? androidIndicatorColor,
    Color? androidSelectedIconColor,
    Color? androidUnselectedIconColor,
    Color? androidSelectedLabelColor,
    Color? androidUnselectedLabelColor,
    double? androidElevation,
    bool? enableNativeGlass,
    double? blurSigma,
    List<Color>? glassGradientColors,
    Color? glassBorderColor,
    double? glassBorderWidth,
    Color? glassHairlineBorderColor,
    List<BoxShadow>? glassShadows,
    Color? nativeGlassTintColor,
    Color? actionStripIconColor,
    Color? actionStripLabelColor,
    Color? actionStripDividerColor,
    double? sidebarWidth,
    Color? sidebarBackgroundColor,
    Color? sidebarDividerColor,
    Color? sidebarSelectedColor,
    Gradient? sidebarSelectedGradient,
    Color? sidebarSelectedForegroundColor,
    Color? sidebarSelectedIconColor,
    Color? sidebarUnselectedIconColor,
    Color? sidebarUnselectedTextColor,
    Color? sidebarSectionHeaderColor,
    Color? sidebarSelectedBorderColor,
    Color? sidebarSelectedShadowColor,
    List<Color>? sidebarToggleButtonColors,
    Color? sidebarToggleBorderColor,
    Color? sidebarToggleIconColor,
    double? collapsedToolbarHeight,
    Color? collapsedToolbarBackgroundColor,
    Color? collapsedToolbarDividerColor,
    Color? collapsedToolbarTitleColor,
    Color? scaffoldBackgroundColor,
    double? horizontalPillHeight,
    double? horizontalPillMaxWidth,
    double? horizontalPillCornerRadius,
    EdgeInsets? horizontalPillMargin,
    bool? enableHaptics,
    VoidCallback? onInteractionFeedback,
  }) {
    return LiquidAdaptiveNavTheme(
      fontFamily: fontFamily ?? this.fontFamily,
      labelTextStyle: labelTextStyle ?? this.labelTextStyle,
      selectedLabelTextStyle:
          selectedLabelTextStyle ?? this.selectedLabelTextStyle,
      verticalLabelTextStyle:
          verticalLabelTextStyle ?? this.verticalLabelTextStyle,
      selectedVerticalLabelTextStyle:
          selectedVerticalLabelTextStyle ?? this.selectedVerticalLabelTextStyle,
      actionStripLabelTextStyle:
          actionStripLabelTextStyle ?? this.actionStripLabelTextStyle,
      sidebarItemTextStyle: sidebarItemTextStyle ?? this.sidebarItemTextStyle,
      selectedSidebarItemTextStyle:
          selectedSidebarItemTextStyle ?? this.selectedSidebarItemTextStyle,
      sidebarSectionHeaderTextStyle:
          sidebarSectionHeaderTextStyle ?? this.sidebarSectionHeaderTextStyle,
      sidebarTitleTextStyle:
          sidebarTitleTextStyle ?? this.sidebarTitleTextStyle,
      collapsedToolbarTitleTextStyle:
          collapsedToolbarTitleTextStyle ?? this.collapsedToolbarTitleTextStyle,
      selectedColor: selectedColor ?? this.selectedColor,
      unselectedColor: unselectedColor ?? this.unselectedColor,
      selectedIconColor: selectedIconColor ?? this.selectedIconColor,
      unselectedIconColor: unselectedIconColor ?? this.unselectedIconColor,
      selectedLabelColor: selectedLabelColor ?? this.selectedLabelColor,
      unselectedLabelColor: unselectedLabelColor ?? this.unselectedLabelColor,
      activeIndicatorColor: activeIndicatorColor ?? this.activeIndicatorColor,
      activeIndicatorGradient:
          activeIndicatorGradient ?? this.activeIndicatorGradient,
      activeIndicatorBorderRadius:
          activeIndicatorBorderRadius ?? this.activeIndicatorBorderRadius,
      androidBarBackgroundColor:
          androidBarBackgroundColor ?? this.androidBarBackgroundColor,
      androidIndicatorColor:
          androidIndicatorColor ?? this.androidIndicatorColor,
      androidSelectedIconColor:
          androidSelectedIconColor ?? this.androidSelectedIconColor,
      androidUnselectedIconColor:
          androidUnselectedIconColor ?? this.androidUnselectedIconColor,
      androidSelectedLabelColor:
          androidSelectedLabelColor ?? this.androidSelectedLabelColor,
      androidUnselectedLabelColor:
          androidUnselectedLabelColor ?? this.androidUnselectedLabelColor,
      androidElevation: androidElevation ?? this.androidElevation,
      enableNativeGlass: enableNativeGlass ?? this.enableNativeGlass,
      blurSigma: blurSigma ?? this.blurSigma,
      glassGradientColors: glassGradientColors ?? this.glassGradientColors,
      glassBorderColor: glassBorderColor ?? this.glassBorderColor,
      glassBorderWidth: glassBorderWidth ?? this.glassBorderWidth,
      glassHairlineBorderColor:
          glassHairlineBorderColor ?? this.glassHairlineBorderColor,
      glassShadows: glassShadows ?? this.glassShadows,
      nativeGlassTintColor: nativeGlassTintColor ?? this.nativeGlassTintColor,
      actionStripIconColor: actionStripIconColor ?? this.actionStripIconColor,
      actionStripLabelColor:
          actionStripLabelColor ?? this.actionStripLabelColor,
      actionStripDividerColor:
          actionStripDividerColor ?? this.actionStripDividerColor,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      sidebarBackgroundColor:
          sidebarBackgroundColor ?? this.sidebarBackgroundColor,
      sidebarDividerColor: sidebarDividerColor ?? this.sidebarDividerColor,
      sidebarSelectedColor: sidebarSelectedColor ?? this.sidebarSelectedColor,
      sidebarSelectedGradient:
          sidebarSelectedGradient ?? this.sidebarSelectedGradient,
      sidebarSelectedForegroundColor:
          sidebarSelectedForegroundColor ?? this.sidebarSelectedForegroundColor,
      sidebarSelectedIconColor:
          sidebarSelectedIconColor ?? this.sidebarSelectedIconColor,
      sidebarUnselectedIconColor:
          sidebarUnselectedIconColor ?? this.sidebarUnselectedIconColor,
      sidebarUnselectedTextColor:
          sidebarUnselectedTextColor ?? this.sidebarUnselectedTextColor,
      sidebarSectionHeaderColor:
          sidebarSectionHeaderColor ?? this.sidebarSectionHeaderColor,
      sidebarSelectedBorderColor:
          sidebarSelectedBorderColor ?? this.sidebarSelectedBorderColor,
      sidebarSelectedShadowColor:
          sidebarSelectedShadowColor ?? this.sidebarSelectedShadowColor,
      sidebarToggleButtonColors:
          sidebarToggleButtonColors ?? this.sidebarToggleButtonColors,
      sidebarToggleBorderColor:
          sidebarToggleBorderColor ?? this.sidebarToggleBorderColor,
      sidebarToggleIconColor:
          sidebarToggleIconColor ?? this.sidebarToggleIconColor,
      collapsedToolbarHeight:
          collapsedToolbarHeight ?? this.collapsedToolbarHeight,
      collapsedToolbarBackgroundColor:
          collapsedToolbarBackgroundColor ??
          this.collapsedToolbarBackgroundColor,
      collapsedToolbarDividerColor:
          collapsedToolbarDividerColor ?? this.collapsedToolbarDividerColor,
      collapsedToolbarTitleColor:
          collapsedToolbarTitleColor ?? this.collapsedToolbarTitleColor,
      scaffoldBackgroundColor:
          scaffoldBackgroundColor ?? this.scaffoldBackgroundColor,
      horizontalPillHeight: horizontalPillHeight ?? this.horizontalPillHeight,
      horizontalPillMaxWidth:
          horizontalPillMaxWidth ?? this.horizontalPillMaxWidth,
      horizontalPillCornerRadius:
          horizontalPillCornerRadius ?? this.horizontalPillCornerRadius,
      horizontalPillMargin: horizontalPillMargin ?? this.horizontalPillMargin,
      enableHaptics: enableHaptics ?? this.enableHaptics,
      onInteractionFeedback:
          onInteractionFeedback ?? this.onInteractionFeedback,
    );
  }

  @override
  LiquidAdaptiveNavTheme lerp(
    covariant ThemeExtension<LiquidAdaptiveNavTheme>? other,
    double t,
  ) {
    if (other is! LiquidAdaptiveNavTheme) return this;
    return LiquidAdaptiveNavTheme(
      fontFamily: t < 0.5 ? fontFamily : other.fontFamily,
      labelTextStyle: TextStyle.lerp(labelTextStyle, other.labelTextStyle, t),
      selectedLabelTextStyle: TextStyle.lerp(
        selectedLabelTextStyle,
        other.selectedLabelTextStyle,
        t,
      ),
      verticalLabelTextStyle: TextStyle.lerp(
        verticalLabelTextStyle,
        other.verticalLabelTextStyle,
        t,
      ),
      selectedVerticalLabelTextStyle: TextStyle.lerp(
        selectedVerticalLabelTextStyle,
        other.selectedVerticalLabelTextStyle,
        t,
      ),
      actionStripLabelTextStyle: TextStyle.lerp(
        actionStripLabelTextStyle,
        other.actionStripLabelTextStyle,
        t,
      ),
      sidebarItemTextStyle: TextStyle.lerp(
        sidebarItemTextStyle,
        other.sidebarItemTextStyle,
        t,
      ),
      selectedSidebarItemTextStyle: TextStyle.lerp(
        selectedSidebarItemTextStyle,
        other.selectedSidebarItemTextStyle,
        t,
      ),
      sidebarSectionHeaderTextStyle: TextStyle.lerp(
        sidebarSectionHeaderTextStyle,
        other.sidebarSectionHeaderTextStyle,
        t,
      ),
      sidebarTitleTextStyle: TextStyle.lerp(
        sidebarTitleTextStyle,
        other.sidebarTitleTextStyle,
        t,
      ),
      collapsedToolbarTitleTextStyle: TextStyle.lerp(
        collapsedToolbarTitleTextStyle,
        other.collapsedToolbarTitleTextStyle,
        t,
      ),
      selectedColor: Color.lerp(selectedColor, other.selectedColor, t),
      unselectedColor: Color.lerp(unselectedColor, other.unselectedColor, t),
      selectedIconColor: Color.lerp(
        selectedIconColor,
        other.selectedIconColor,
        t,
      ),
      unselectedIconColor: Color.lerp(
        unselectedIconColor,
        other.unselectedIconColor,
        t,
      ),
      selectedLabelColor: Color.lerp(
        selectedLabelColor,
        other.selectedLabelColor,
        t,
      ),
      unselectedLabelColor: Color.lerp(
        unselectedLabelColor,
        other.unselectedLabelColor,
        t,
      ),
      activeIndicatorColor: Color.lerp(
        activeIndicatorColor,
        other.activeIndicatorColor,
        t,
      ),
      activeIndicatorGradient: Gradient.lerp(
        activeIndicatorGradient,
        other.activeIndicatorGradient,
        t,
      ),
      activeIndicatorBorderRadius:
          lerpDouble(
            activeIndicatorBorderRadius,
            other.activeIndicatorBorderRadius,
            t,
          ) ??
          other.activeIndicatorBorderRadius,
      androidBarBackgroundColor: Color.lerp(
        androidBarBackgroundColor,
        other.androidBarBackgroundColor,
        t,
      ),
      androidIndicatorColor: Color.lerp(
        androidIndicatorColor,
        other.androidIndicatorColor,
        t,
      ),
      androidSelectedIconColor: Color.lerp(
        androidSelectedIconColor,
        other.androidSelectedIconColor,
        t,
      ),
      androidUnselectedIconColor: Color.lerp(
        androidUnselectedIconColor,
        other.androidUnselectedIconColor,
        t,
      ),
      androidSelectedLabelColor: Color.lerp(
        androidSelectedLabelColor,
        other.androidSelectedLabelColor,
        t,
      ),
      androidUnselectedLabelColor: Color.lerp(
        androidUnselectedLabelColor,
        other.androidUnselectedLabelColor,
        t,
      ),
      androidElevation:
          lerpDouble(androidElevation, other.androidElevation, t) ??
          other.androidElevation,
      enableNativeGlass: t < 0.5 ? enableNativeGlass : other.enableNativeGlass,
      blurSigma: lerpDouble(blurSigma, other.blurSigma, t) ?? other.blurSigma,
      glassGradientColors: _lerpColorList(
        glassGradientColors,
        other.glassGradientColors,
        t,
      ),
      glassBorderColor: Color.lerp(glassBorderColor, other.glassBorderColor, t),
      glassBorderWidth:
          lerpDouble(glassBorderWidth, other.glassBorderWidth, t) ??
          other.glassBorderWidth,
      glassHairlineBorderColor: Color.lerp(
        glassHairlineBorderColor,
        other.glassHairlineBorderColor,
        t,
      ),
      glassShadows: BoxShadow.lerpList(glassShadows, other.glassShadows, t),
      nativeGlassTintColor: Color.lerp(
        nativeGlassTintColor,
        other.nativeGlassTintColor,
        t,
      ),
      actionStripIconColor: Color.lerp(
        actionStripIconColor,
        other.actionStripIconColor,
        t,
      ),
      actionStripLabelColor: Color.lerp(
        actionStripLabelColor,
        other.actionStripLabelColor,
        t,
      ),
      actionStripDividerColor: Color.lerp(
        actionStripDividerColor,
        other.actionStripDividerColor,
        t,
      ),
      sidebarWidth:
          lerpDouble(sidebarWidth, other.sidebarWidth, t) ?? other.sidebarWidth,
      sidebarBackgroundColor: Color.lerp(
        sidebarBackgroundColor,
        other.sidebarBackgroundColor,
        t,
      ),
      sidebarDividerColor: Color.lerp(
        sidebarDividerColor,
        other.sidebarDividerColor,
        t,
      ),
      sidebarSelectedColor: Color.lerp(
        sidebarSelectedColor,
        other.sidebarSelectedColor,
        t,
      ),
      sidebarSelectedGradient: Gradient.lerp(
        sidebarSelectedGradient,
        other.sidebarSelectedGradient,
        t,
      ),
      sidebarSelectedForegroundColor: Color.lerp(
        sidebarSelectedForegroundColor,
        other.sidebarSelectedForegroundColor,
        t,
      ),
      sidebarSelectedIconColor: Color.lerp(
        sidebarSelectedIconColor,
        other.sidebarSelectedIconColor,
        t,
      ),
      sidebarUnselectedIconColor: Color.lerp(
        sidebarUnselectedIconColor,
        other.sidebarUnselectedIconColor,
        t,
      ),
      sidebarUnselectedTextColor: Color.lerp(
        sidebarUnselectedTextColor,
        other.sidebarUnselectedTextColor,
        t,
      ),
      sidebarSectionHeaderColor: Color.lerp(
        sidebarSectionHeaderColor,
        other.sidebarSectionHeaderColor,
        t,
      ),
      sidebarSelectedBorderColor: Color.lerp(
        sidebarSelectedBorderColor,
        other.sidebarSelectedBorderColor,
        t,
      ),
      sidebarSelectedShadowColor: Color.lerp(
        sidebarSelectedShadowColor,
        other.sidebarSelectedShadowColor,
        t,
      ),
      sidebarToggleButtonColors: _lerpColorList(
        sidebarToggleButtonColors,
        other.sidebarToggleButtonColors,
        t,
      ),
      sidebarToggleBorderColor: Color.lerp(
        sidebarToggleBorderColor,
        other.sidebarToggleBorderColor,
        t,
      ),
      sidebarToggleIconColor: Color.lerp(
        sidebarToggleIconColor,
        other.sidebarToggleIconColor,
        t,
      ),
      collapsedToolbarHeight:
          lerpDouble(collapsedToolbarHeight, other.collapsedToolbarHeight, t) ??
          other.collapsedToolbarHeight,
      collapsedToolbarBackgroundColor: Color.lerp(
        collapsedToolbarBackgroundColor,
        other.collapsedToolbarBackgroundColor,
        t,
      ),
      collapsedToolbarDividerColor: Color.lerp(
        collapsedToolbarDividerColor,
        other.collapsedToolbarDividerColor,
        t,
      ),
      collapsedToolbarTitleColor: Color.lerp(
        collapsedToolbarTitleColor,
        other.collapsedToolbarTitleColor,
        t,
      ),
      scaffoldBackgroundColor: Color.lerp(
        scaffoldBackgroundColor,
        other.scaffoldBackgroundColor,
        t,
      ),
      horizontalPillHeight:
          lerpDouble(horizontalPillHeight, other.horizontalPillHeight, t) ??
          other.horizontalPillHeight,
      horizontalPillMaxWidth:
          lerpDouble(horizontalPillMaxWidth, other.horizontalPillMaxWidth, t) ??
          other.horizontalPillMaxWidth,
      horizontalPillCornerRadius:
          lerpDouble(
            horizontalPillCornerRadius,
            other.horizontalPillCornerRadius,
            t,
          ) ??
          other.horizontalPillCornerRadius,
      horizontalPillMargin: EdgeInsets.lerp(
        horizontalPillMargin,
        other.horizontalPillMargin,
        t,
      ),
      enableHaptics: t < 0.5 ? enableHaptics : other.enableHaptics,
      onInteractionFeedback: t < 0.5
          ? onInteractionFeedback
          : other.onInteractionFeedback,
    );
  }

  static List<Color>? _lerpColorList(List<Color>? a, List<Color>? b, double t) {
    if (a == null && b == null) return null;
    if (a == null) return b;
    if (b == null) return a;
    if (a.length != b.length) return t < 0.5 ? a : b;
    return [
      for (int i = 0; i < a.length; i++)
        Color.lerp(a[i], b[i], t) ?? (t < 0.5 ? a[i] : b[i]),
    ];
  }
}

/// Optional inherited scope providing a [LiquidAdaptiveNavTheme] for subtrees
/// that do not rely on Material [ThemeData.extensions] (such as [CupertinoApp]).
class LiquidAdaptiveNavThemeScope extends InheritedWidget {
  final LiquidAdaptiveNavTheme theme;

  const LiquidAdaptiveNavThemeScope({
    super.key,
    required this.theme,
    required super.child,
  });

  static LiquidAdaptiveNavTheme? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<LiquidAdaptiveNavThemeScope>()
        ?.theme;
  }

  @override
  bool updateShouldNotify(covariant LiquidAdaptiveNavThemeScope oldWidget) {
    return oldWidget.theme != theme;
  }
}
