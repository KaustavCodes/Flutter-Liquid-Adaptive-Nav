import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/nav_models.dart';
import '../posture/responsive_posture_builder.dart';
import '../theme/liquid_adaptive_nav_theme.dart';
import 'liquid_glass_capsule.dart';
import 'liquid_tactile_button.dart';

/// Shared geometry for docked iPhone Duo frosted-glass side-strip capsules.
class DuoSideStripLayout {
  final double stripWidth;
  final double pillWidth;
  final double topGap;
  final double bottomGap;
  final double maxAvailableHeight;

  const DuoSideStripLayout({
    required this.stripWidth,
    required this.pillWidth,
    required this.topGap,
    required this.bottomGap,
    required this.maxAvailableHeight,
  });

  static DuoSideStripLayout compute({
    required double rawStripWidth,
    required Size viewportSize,
    required double containerHeight,
    required EdgeInsets viewPadding,
    required double minContentHeight,
    EdgeInsets occlusionPadding = EdgeInsets.zero,
  }) {
    final stripWidth = rawStripWidth.clamp(56.0, 120.0);
    final pillWidth = stripWidth >= 74.0
        ? 54.0
        : (stripWidth - 10.0).clamp(44.0, 54.0);

    final isPortrait = viewportSize.height > viewportSize.width;

    final fallbackTopGap = math.max(
      viewPadding.top + 12.0,
      containerHeight >= 480.0 ? 150.0 : 36.0,
    );
    final fallbackBottomGap = math.max(
      viewPadding.bottom + 12.0,
      containerHeight >= 350.0
          ? 84.0
          : (containerHeight >= 280.0 ? 60.0 : 12.0),
    );

    final desiredTopGap = isPortrait
        ? math.max(fallbackTopGap, occlusionPadding.top)
        : (occlusionPadding.top > 0
              ? math.max(viewPadding.top + 12.0, occlusionPadding.top)
              : math.max(viewPadding.top + 12.0, 24.0));

    final desiredBottomGap = isPortrait
        ? (occlusionPadding.bottom > 0
              ? math.max(viewPadding.bottom + 4.0, occlusionPadding.bottom)
              : math.max(viewPadding.bottom + 4.0, 22.0))
        : (occlusionPadding.bottom > 0
              ? math.max(viewPadding.bottom + 12.0, occlusionPadding.bottom)
              : (occlusionPadding.top > 0
                    ? math.max(viewPadding.bottom + 12.0, 22.0)
                    : fallbackBottomGap));

    final maxTotalGap = math.max(0.0, containerHeight - minContentHeight);
    var topGap = desiredTopGap;
    var bottomGap = desiredBottomGap;
    if (topGap + bottomGap > maxTotalGap && (topGap + bottomGap) > 0) {
      final ratio = maxTotalGap / (topGap + bottomGap);
      topGap *= ratio;
      bottomGap *= ratio;
    }

    final availableHeight = math.max(0.0, containerHeight - topGap - bottomGap);

    return DuoSideStripLayout(
      stripWidth: stripWidth,
      pillWidth: pillWidth,
      topGap: topGap,
      bottomGap: bottomGap,
      maxAvailableHeight: availableHeight,
    );
  }
}

/// Compact frosted/liquid-glass vertical action capsule rendered inside an
/// asymmetric iOS / iPhone Duo reserved side strip for pushed screens
/// (e.g., Back, Close, Delete, Stop, Edit).
class DuoSideActionStrip extends StatelessWidget {
  final DuoSideStripEdge edge;
  final double stripWidth;
  final List<DuoSideActionItem> actions;
  final bool forceDarkGlass;
  final EdgeInsets occlusionPadding;
  final LiquidAdaptiveNavTheme? theme;
  final Brightness? brightness;
  final Color? iconColor;
  final Color? labelColor;
  final Color? dividerColor;
  final TextStyle? labelTextStyle;
  final String? fontFamily;
  final bool? enableNativeGlass;
  final bool? enableHaptics;

  const DuoSideActionStrip({
    super.key,
    required this.edge,
    required this.stripWidth,
    required this.actions,
    this.forceDarkGlass = false,
    this.occlusionPadding = EdgeInsets.zero,
    this.theme,
    this.brightness,
    this.iconColor,
    this.labelColor,
    this.dividerColor,
    this.labelTextStyle,
    this.fontFamily,
    this.enableNativeGlass,
    this.enableHaptics,
  });

  /// Returns a [Positioned] docked directly along [strip]'s
  /// [DuoSideStripSpec.edge] inside a [Stack].
  static Widget positioned({
    Key? key,
    required DuoSideStripSpec strip,
    required List<DuoSideActionItem> actions,
    bool forceDarkGlass = false,
    LiquidAdaptiveNavTheme? theme,
    Brightness? brightness,
    Color? iconColor,
    Color? labelColor,
    Color? dividerColor,
    TextStyle? labelTextStyle,
    String? fontFamily,
    bool? enableNativeGlass,
    bool? enableHaptics,
  }) {
    return Positioned(
      key: key,
      top: 0,
      bottom: 0,
      left: strip.edge == DuoSideStripEdge.left ? 0 : null,
      right: strip.edge == DuoSideStripEdge.right ? 0 : null,
      width: strip.width,
      child: DuoSideActionStrip(
        edge: strip.edge,
        stripWidth: strip.width,
        actions: actions,
        forceDarkGlass: forceDarkGlass,
        occlusionPadding: strip.occlusionPadding,
        theme: theme,
        brightness: brightness,
        iconColor: iconColor,
        labelColor: labelColor,
        dividerColor: dividerColor,
        labelTextStyle: labelTextStyle,
        fontFamily: fontFamily,
        enableNativeGlass: enableNativeGlass,
        enableHaptics: enableHaptics,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (actions.isEmpty) return const SizedBox.shrink();

    final effectiveBrightness = forceDarkGlass
        ? Brightness.dark
        : LiquidAdaptiveNavTheme.resolveBrightness(
            context,
            brightnessOverride: brightness,
          );
    final useDarkGlass = effectiveBrightness == Brightness.dark;

    final resolvedTheme =
        LiquidAdaptiveNavTheme.resolve(
          context,
          override: theme,
          brightnessOverride: effectiveBrightness,
        ).withOverrides(
          fontFamily: fontFamily,
          actionStripIconColor: iconColor,
          actionStripLabelColor: labelColor,
          actionStripDividerColor: dividerColor,
          actionStripLabelTextStyle: labelTextStyle,
          enableNativeGlass: enableNativeGlass,
          enableHaptics: enableHaptics,
        );

    final viewPadding = MediaQuery.viewPaddingOf(context);
    final viewportSize = MediaQuery.sizeOf(context);

    final defaultIconColor =
        resolvedTheme.actionStripIconColor ??
        (useDarkGlass ? Colors.white : const Color(0xFF1C1C1E));
    final defaultDividerColor =
        resolvedTheme.actionStripDividerColor ??
        (useDarkGlass
            ? Colors.white.withValues(alpha: 0.12)
            : Colors.black.withValues(alpha: 0.08));

    return Align(
      alignment: edge == DuoSideStripEdge.right
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final containerHeight = constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : viewportSize.height;
          final targetPillHeight = actions.length == 1
              ? 58.0
              : (actions.length * 50.0 + 10.0);

          final layout = DuoSideStripLayout.compute(
            rawStripWidth: stripWidth,
            viewportSize: viewportSize,
            containerHeight: containerHeight,
            viewPadding: viewPadding,
            minContentHeight: math.min(targetPillHeight, 88.0),
            occlusionPadding: occlusionPadding,
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
                  key: const ValueKey('duo_side_action_pill'),
                  width: layout.pillWidth,
                  height: pillHeight,
                  cornerRadius: cornerRadius,
                  isDark: useDarkGlass,
                  blurSigma: resolvedTheme.blurSigma,
                  showLightOuterHairline: true,
                  lightTopAlpha: 0.78,
                  lightBottomAlpha: 0.50,
                  darkTopAlpha: 0.45,
                  darkBottomAlpha: 0.28,
                  enableNativeGlass: resolvedTheme.enableNativeGlass,
                  theme: resolvedTheme,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 5,
                  ),
                  child: LayoutBuilder(
                    builder: (context, innerConstraints) {
                      final itemHeight =
                          innerConstraints.maxHeight / actions.length;
                      final showLabel = itemHeight >= 38.0;
                      final iconSize = itemHeight >= 44.0 ? 19.0 : 16.5;

                      return Column(
                        children: [
                          for (int i = 0; i < actions.length; i++) ...[
                            if (i > 0)
                              Container(
                                height: 0.6,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                color: defaultDividerColor,
                              ),
                            Expanded(
                              child: LiquidTactileButton(
                                tooltip:
                                    actions[i].tooltip ??
                                    (showLabel ? null : actions[i].label),
                                borderRadius: BorderRadius.circular(
                                  cornerRadius - 4,
                                ),
                                pressedScale: 0.92,
                                onPressed: actions[i].enabled
                                    ? () {
                                        resolvedTheme.triggerFeedback();
                                        actions[i].onPressed();
                                      }
                                    : null,
                                child: SizedBox.expand(
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ),
                                      child: showLabel
                                          ? Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  actions[i].icon,
                                                  size: iconSize,
                                                  color:
                                                      actions[i].color ??
                                                      defaultIconColor,
                                                ),
                                                const SizedBox(height: 1.5),
                                                FittedBox(
                                                  fit: BoxFit.scaleDown,
                                                  child: Text(
                                                    actions[i].label,
                                                    maxLines: 1,
                                                    style: resolvedTheme
                                                        .resolveActionStripLabelStyle(
                                                          itemColor:
                                                              actions[i].color,
                                                        ),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Icon(
                                              actions[i].icon,
                                              size: iconSize,
                                              color:
                                                  actions[i].color ??
                                                  defaultIconColor,
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
}
