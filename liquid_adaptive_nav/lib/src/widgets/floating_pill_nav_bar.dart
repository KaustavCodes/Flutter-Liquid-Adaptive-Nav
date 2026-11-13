import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/nav_models.dart';
import '../posture/responsive_posture_builder.dart';
import '../theme/liquid_adaptive_nav_theme.dart';
import 'duo_side_action_strip.dart';
import 'liquid_glass_capsule.dart';
import 'liquid_tactile_button.dart';

/// Floating frosted/liquid-glass pill navigation bar with adaptive platform
/// support:
/// - **iOS / macOS / Apple glass**: Horizontal floating frosted/liquid-glass pill
///   with a single sliding active capsule indicator.
/// - **Foldable / iPhone Duo (`axis == Axis.vertical`)**: Vertical glass capsule
///   docked cleanly inside the asymmetric reserved hardware strip, avoiding status
///   and camera occlusions.
/// - **Android (when [platformStyle] is [FloatingNavPlatformStyle.adaptive] or
///   [FloatingNavPlatformStyle.material])**: Material 3 [NavigationBar] honoring
///   [LiquidAdaptiveNavTheme] fonts and light/dark colors.
class FloatingPillNavBar extends StatelessWidget {
  final List<LiquidNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final Axis axis;
  final DuoSideStripEdge sideStripEdge;
  final double sideStripWidth;
  final EdgeInsets sideStripOcclusionPadding;
  final FloatingNavPlatformStyle platformStyle;
  final LiquidAdaptiveNavTheme? theme;
  final Brightness? brightness;

  // Quick inline styling overrides (optional, layered above resolved theme)
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? activeIndicatorColor;
  final Gradient? activeIndicatorGradient;
  final String? fontFamily;
  final TextStyle? labelTextStyle;
  final TextStyle? selectedLabelTextStyle;
  final bool? enableNativeGlass;
  final bool? enableHaptics;
  final double? blurSigma;

  FloatingPillNavBar({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.axis = Axis.horizontal,
    this.sideStripEdge = DuoSideStripEdge.right,
    this.sideStripWidth = 84.0,
    this.sideStripOcclusionPadding = EdgeInsets.zero,
    this.platformStyle = FloatingNavPlatformStyle.adaptive,
    this.theme,
    this.brightness,
    this.selectedColor,
    this.unselectedColor,
    this.activeIndicatorColor,
    this.activeIndicatorGradient,
    this.fontFamily,
    this.labelTextStyle,
    this.selectedLabelTextStyle,
    this.enableNativeGlass,
    this.enableHaptics,
    this.blurSigma,
  }) : assert(
         destinations.isNotEmpty,
         'FloatingPillNavBar requires at least one destination.',
       );

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = LiquidAdaptiveNavTheme.resolveBrightness(
      context,
      brightnessOverride: brightness,
    );
    final isDark = effectiveBrightness == Brightness.dark;
    final resolvedTheme =
        LiquidAdaptiveNavTheme.resolve(
          context,
          override: theme,
          brightnessOverride: effectiveBrightness,
        ).withOverrides(
          fontFamily: fontFamily,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          activeIndicatorColor: activeIndicatorColor,
          activeIndicatorGradient: activeIndicatorGradient,
          labelTextStyle: labelTextStyle,
          selectedLabelTextStyle: selectedLabelTextStyle,
          enableNativeGlass: enableNativeGlass,
          enableHaptics: enableHaptics,
          blurSigma: blurSigma,
        );

    final platform = Theme.of(context).platform;
    final isAndroid = platform == TargetPlatform.android;

    final useMaterialNavBar =
        axis == Axis.horizontal &&
        (platformStyle == FloatingNavPlatformStyle.material ||
            (platformStyle == FloatingNavPlatformStyle.adaptive && isAndroid));

    if (useMaterialNavBar) {
      return _buildAndroidNavigationBar(context, isDark, resolvedTheme);
    }

    if (axis == Axis.vertical) {
      return _buildVerticalSidePill(context, isDark, resolvedTheme);
    }

    return _buildHorizontalGlassPill(context, isDark, resolvedTheme);
  }

  Widget _buildHorizontalGlassPill(
    BuildContext context,
    bool isDark,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    final activeIndex = selectedIndex.clamp(0, destinations.length - 1);
    final margin = resolvedTheme.resolveHorizontalPillMargin(
      MediaQuery.of(context).padding,
    );
    final isRtl = Directionality.of(context) == TextDirection.rtl;

    final activeFill =
        resolvedTheme.activeIndicatorColor ??
        (isDark ? const Color(0x333B82F6) : const Color(0xFFE8EEF5));

    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: margin,
        child: LiquidGlassCapsule(
          key: const ValueKey('floating_pill_nav_horizontal'),
          height: resolvedTheme.horizontalPillHeight,
          constraints: BoxConstraints(
            maxWidth: resolvedTheme.horizontalPillMaxWidth,
          ),
          cornerRadius: resolvedTheme.horizontalPillCornerRadius,
          isDark: isDark,
          blurSigma: math.max(resolvedTheme.blurSigma, 30.0),
          lightTopAlpha: resolvedTheme.glassGradientColors != null
              ? null
              : 0.70,
          lightBottomAlpha: resolvedTheme.glassGradientColors != null
              ? null
              : 0.45,
          darkTopAlpha: resolvedTheme.glassGradientColors != null ? null : 0.40,
          darkBottomAlpha: resolvedTheme.glassGradientColors != null
              ? null
              : 0.23,
          enableNativeGlass: resolvedTheme.enableNativeGlass,
          theme: resolvedTheme,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / destinations.length;

              final indicatorInset = activeIndex * itemWidth + 2;
              return Stack(
                children: [
                  AnimatedPositioned(
                    key: const ValueKey('floating_pill_active_indicator'),
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    left: isRtl ? null : indicatorInset,
                    right: isRtl ? indicatorInset : null,
                    top: 2,
                    bottom: 2,
                    width: math.max(0.0, itemWidth - 4),
                    child: Container(
                      decoration: BoxDecoration(
                        color: resolvedTheme.activeIndicatorGradient == null
                            ? activeFill
                            : null,
                        gradient: resolvedTheme.activeIndicatorGradient,
                        borderRadius: BorderRadius.circular(
                          resolvedTheme.activeIndicatorBorderRadius,
                        ),
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      for (int i = 0; i < destinations.length; i++)
                        _buildHorizontalPillItem(
                          index: i,
                          destination: destinations[i],
                          isSelected: i == activeIndex,
                          isDark: isDark,
                          resolvedTheme: resolvedTheme,
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalPillItem({
    required int index,
    required LiquidNavDestination destination,
    required bool isSelected,
    required bool isDark,
    required LiquidAdaptiveNavTheme resolvedTheme,
  }) {
    final activeIconColor =
        resolvedTheme.selectedIconColor ??
        resolvedTheme.selectedColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF007AFF));
    final inactiveIconColor =
        resolvedTheme.unselectedIconColor ??
        resolvedTheme.unselectedColor ??
        (isDark ? const Color(0xFF8E8E93) : const Color(0xFF1C1C1E));

    return Expanded(
      child: LiquidTactileButton(
        tooltip: destination.tooltip,
        borderRadius: BorderRadius.circular(
          resolvedTheme.activeIndicatorBorderRadius,
        ),
        pressedScale: 0.94,
        onPressed: () {
          resolvedTheme.triggerFeedback();
          onDestinationSelected(index);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                destination.iconForSelection(isSelected: isSelected),
                size: 24,
                color: isSelected ? activeIconColor : inactiveIconColor,
              ),
              const SizedBox(height: 2),
              Text(
                destination.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: resolvedTheme.resolveHorizontalLabelStyle(
                  isSelected: isSelected,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerticalSidePill(
    BuildContext context,
    bool isDark,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    final activeIndex = selectedIndex.clamp(0, destinations.length - 1);
    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewportSize = MediaQuery.sizeOf(context);

    final activeFill =
        resolvedTheme.activeIndicatorColor ??
        (isDark ? const Color(0x333B82F6) : const Color(0xFFE8EEF5));

    return Align(
      alignment: sideStripEdge == DuoSideStripEdge.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : viewportSize.height;
          final targetPillHeight = (destinations.length * 48.0 + 8.0).clamp(
            96.0,
            280.0,
          );
          final layout = DuoSideStripLayout.compute(
            rawStripWidth: sideStripWidth,
            viewportSize: viewportSize,
            containerHeight: containerHeight,
            viewPadding: viewPadding,
            minContentHeight: math.min(148.0, targetPillHeight),
            occlusionPadding: sideStripOcclusionPadding,
          );
          final pillHeight = math.min(
            targetPillHeight,
            layout.maxAvailableHeight,
          );
          final cornerRadius = layout.pillWidth / 2;

          return SizedBox(
            width: layout.stripWidth,
            height: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                top: layout.topGap,
                bottom: layout.bottomGap,
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: LiquidGlassCapsule(
                  key: const ValueKey('floating_pill_nav_vertical'),
                  width: layout.pillWidth,
                  height: pillHeight,
                  cornerRadius: cornerRadius,
                  isDark: isDark,
                  blurSigma: resolvedTheme.blurSigma,
                  showLightOuterHairline: true,
                  lightTopAlpha: resolvedTheme.glassGradientColors != null
                      ? null
                      : 0.75,
                  lightBottomAlpha: resolvedTheme.glassGradientColors != null
                      ? null
                      : 0.47,
                  darkTopAlpha: resolvedTheme.glassGradientColors != null
                      ? null
                      : 0.40,
                  darkBottomAlpha: resolvedTheme.glassGradientColors != null
                      ? null
                      : 0.23,
                  enableNativeGlass: resolvedTheme.enableNativeGlass,
                  theme: resolvedTheme,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final innerHeight = innerConstraints.maxHeight;
                      final itemHeight = innerHeight / destinations.length;
                      final showLabel = itemHeight >= 38.0;

                      return Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            left: 2,
                            right: 2,
                            top: activeIndex * itemHeight + 2,
                            height: math.max(0.0, itemHeight - 4),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    resolvedTheme.activeIndicatorGradient ==
                                        null
                                    ? activeFill
                                    : null,
                                gradient: resolvedTheme.activeIndicatorGradient,
                                borderRadius: BorderRadius.circular(
                                  math.max(4.0, cornerRadius - 4),
                                ),
                              ),
                            ),
                          ),
                          Column(
                            children: [
                              for (int i = 0; i < destinations.length; i++)
                                _buildVerticalPillItem(
                                  index: i,
                                  destination: destinations[i],
                                  isSelected: i == activeIndex,
                                  isDark: isDark,
                                  showLabel: showLabel,
                                  itemHeight: itemHeight,
                                  cornerRadius: math.max(4.0, cornerRadius - 4),
                                  resolvedTheme: resolvedTheme,
                                ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVerticalPillItem({
    required int index,
    required LiquidNavDestination destination,
    required bool isSelected,
    required bool isDark,
    required bool showLabel,
    required double itemHeight,
    required double cornerRadius,
    required LiquidAdaptiveNavTheme resolvedTheme,
  }) {
    final activeIconColor =
        resolvedTheme.selectedIconColor ??
        resolvedTheme.selectedColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF007AFF));
    final inactiveIconColor =
        resolvedTheme.unselectedIconColor ??
        resolvedTheme.unselectedColor ??
        (isDark ? const Color(0xFF8E8E93) : const Color(0xFF1C1C1E));
    final iconSize = itemHeight >= 46.0 ? 19.0 : (showLabel ? 17.5 : 17.0);

    return Expanded(
      child: LiquidTactileButton(
        tooltip: destination.tooltip ?? (showLabel ? null : destination.label),
        borderRadius: BorderRadius.circular(cornerRadius),
        pressedScale: 0.94,
        onPressed: () {
          resolvedTheme.triggerFeedback();
          onDestinationSelected(index);
        },
        child: SizedBox.expand(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: showLabel
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          destination.iconForSelection(isSelected: isSelected),
                          size: iconSize,
                          color: isSelected
                              ? activeIconColor
                              : inactiveIconColor,
                        ),
                        const SizedBox(height: 1.5),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            destination.label,
                            maxLines: 1,
                            style: resolvedTheme.resolveVerticalLabelStyle(
                              isSelected: isSelected,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Icon(
                      destination.iconForSelection(isSelected: isSelected),
                      size: iconSize,
                      color: isSelected ? activeIconColor : inactiveIconColor,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAndroidNavigationBar(
    BuildContext context,
    bool isDark,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    final activeIndex = selectedIndex.clamp(0, destinations.length - 1);
    final selectedIconColor =
        resolvedTheme.androidSelectedIconColor ??
        resolvedTheme.selectedIconColor ??
        resolvedTheme.selectedColor ??
        Theme.of(context).colorScheme.primary;
    final unselectedIconColor =
        resolvedTheme.androidUnselectedIconColor ??
        resolvedTheme.unselectedIconColor ??
        resolvedTheme.unselectedColor ??
        Theme.of(context).colorScheme.onSurfaceVariant;
    final selectedLabelColor =
        resolvedTheme.androidSelectedLabelColor ??
        resolvedTheme.selectedLabelColor ??
        resolvedTheme.selectedColor ??
        selectedIconColor;
    final unselectedLabelColor =
        resolvedTheme.androidUnselectedLabelColor ??
        resolvedTheme.unselectedLabelColor ??
        resolvedTheme.unselectedColor ??
        unselectedIconColor;
    final indicatorColor =
        resolvedTheme.androidIndicatorColor ??
        resolvedTheme.activeIndicatorColor ??
        selectedIconColor.withValues(alpha: 0.22);
    final bgColor =
        resolvedTheme.androidBarBackgroundColor ??
        (isDark
            ? const Color(0xFF1E1E22)
            : Theme.of(context).colorScheme.surface);

    return NavigationBarTheme(
      data: NavigationBarThemeData(
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return resolvedTheme
              .resolveHorizontalLabelStyle(isSelected: isSelected)
              .copyWith(
                fontSize: 12,
                color: isSelected ? selectedLabelColor : unselectedLabelColor,
              );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? selectedIconColor : unselectedIconColor,
          );
        }),
      ),
      child: NavigationBar(
        key: const ValueKey('floating_pill_nav_android'),
        selectedIndex: activeIndex,
        onDestinationSelected: (index) {
          resolvedTheme.triggerFeedback();
          onDestinationSelected(index);
        },
        elevation: resolvedTheme.androidElevation,
        backgroundColor: bgColor,
        indicatorColor: indicatorColor,
        destinations: [
          for (final dest in destinations)
            NavigationDestination(
              icon: Icon(
                dest.materialIconForSelection(isSelected: false),
                color: unselectedIconColor,
              ),
              selectedIcon: Icon(
                dest.materialIconForSelection(isSelected: true),
                color: selectedIconColor,
              ),
              label: dest.label,
              tooltip: dest.tooltip,
            ),
        ],
      ),
    );
  }
}
