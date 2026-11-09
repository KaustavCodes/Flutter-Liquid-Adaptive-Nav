import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../platform/platform_info.dart';
import '../theme/liquid_adaptive_nav_theme.dart';

/// Frosted / liquid-glass capsule surface used by [FloatingPillNavBar] and
/// [DuoSideActionStrip], and usable standalone anywhere in an app.
///
/// On iOS runtime with iOS 26+ (and [enableNativeGlass] enabled), layers a
/// passive non-interactive UIKit `UIGlassEffect` backdrop (`UiKitView`) behind
/// Flutter's interactive controls and semantics, gracefully falling back to
/// `UIBlurEffect` on pre-iOS 26 devices. On macOS, Android, web, and headless
/// widget tests, renders the deterministic pure-Flutter `BackdropFilter` capsule.
class LiquidGlassCapsule extends StatelessWidget {
  final double cornerRadius;
  final bool? isDark;
  final bool isCapsule;
  final EdgeInsetsGeometry padding;
  final double? blurSigma;
  final bool showLightOuterHairline;
  final double? lightTopAlpha;
  final double? lightBottomAlpha;
  final double? darkTopAlpha;
  final double? darkBottomAlpha;
  final List<Color>? gradientColors;
  final Color? borderColor;
  final double? borderWidth;
  final Color? hairlineBorderColor;
  final List<BoxShadow>? shadows;
  final Color? tintColor;
  final double? width;
  final double? height;
  final BoxConstraints? constraints;
  final bool? enableNativeGlass;
  final LiquidAdaptiveNavTheme? theme;
  final Widget child;

  const LiquidGlassCapsule({
    super.key,
    required this.cornerRadius,
    required this.child,
    this.isDark,
    this.isCapsule = true,
    this.padding = EdgeInsets.zero,
    this.blurSigma,
    this.showLightOuterHairline = false,
    this.lightTopAlpha,
    this.lightBottomAlpha,
    this.darkTopAlpha,
    this.darkBottomAlpha,
    this.gradientColors,
    this.borderColor,
    this.borderWidth,
    this.hairlineBorderColor,
    this.shadows,
    this.tintColor,
    this.width,
    this.height,
    this.constraints,
    this.enableNativeGlass,
    this.theme,
  });

  static const String viewType =
      'com.kauscoder.liquid_adaptive_nav/liquid_glass_capsule';

  /// Returns `true` only when running inside a real iOS binary/simulator with
  /// an iOS target theme. Headless tests running on macOS/Linux host safely
  /// resolve to `false` and exercise the pure-Flutter fallback.
  static bool shouldUseNativeGlass(
    BuildContext context, {
    bool enableNativeGlass = true,
  }) {
    if (!enableNativeGlass || kIsWeb || !isIOSHost) {
      return false;
    }
    return Theme.of(context).platform == TargetPlatform.iOS;
  }

  @override
  Widget build(BuildContext context) {
    final brightnessOverride = isDark == null
        ? null
        : (isDark! ? Brightness.dark : Brightness.light);
    final resolvedTheme = LiquidAdaptiveNavTheme.resolve(
      context,
      override: theme,
      brightnessOverride: brightnessOverride,
    );
    final effectiveDark =
        isDark ??
        LiquidAdaptiveNavTheme.resolveBrightness(context) == Brightness.dark;
    final effectiveNative =
        enableNativeGlass ?? resolvedTheme.enableNativeGlass;
    final effectiveTint = tintColor ?? resolvedTheme.nativeGlassTintColor;

    if (shouldUseNativeGlass(context, enableNativeGlass: effectiveNative)) {
      return SizedBox(
        width: width,
        height: height,
        child: ConstrainedBox(
          constraints: constraints ?? const BoxConstraints(),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Do NOT wrap UiKitView in ClipRRect or Opacity: UIVisualEffectView
              // loses vibrancy when an ancestor applies a CALayer mask.
              Positioned.fill(
                child: IgnorePointer(
                  child: ExcludeSemantics(
                    child: _NativeLiquidGlassSurface(
                      cornerRadius: cornerRadius,
                      isDark: effectiveDark,
                      isCapsule: isCapsule,
                      tintColor: effectiveTint,
                    ),
                  ),
                ),
              ),
              Padding(padding: padding, child: child),
            ],
          ),
        ),
      );
    }

    final effectiveBlur = blurSigma ?? resolvedTheme.blurSigma;

    final List<Color> resolvedGradientColors;
    if (gradientColors != null && gradientColors!.length >= 2) {
      resolvedGradientColors = gradientColors!;
    } else if (effectiveDark &&
        (darkTopAlpha != null || darkBottomAlpha != null)) {
      resolvedGradientColors = [
        const Color(0xFF2C2C35).withValues(alpha: darkTopAlpha ?? 0.40),
        const Color(0xFF181820).withValues(alpha: darkBottomAlpha ?? 0.23),
      ];
    } else if (!effectiveDark &&
        (lightTopAlpha != null || lightBottomAlpha != null)) {
      resolvedGradientColors = [
        Colors.white.withValues(alpha: lightTopAlpha ?? 0.75),
        const Color(0xFFF0F0F5).withValues(alpha: lightBottomAlpha ?? 0.47),
      ];
    } else if (resolvedTheme.glassGradientColors != null &&
        resolvedTheme.glassGradientColors!.length >= 2) {
      resolvedGradientColors = resolvedTheme.glassGradientColors!;
    } else {
      resolvedGradientColors = effectiveDark
          ? [
              const Color(0xFF2C2C35).withValues(alpha: 0.40),
              const Color(0xFF181820).withValues(alpha: 0.23),
            ]
          : [
              Colors.white.withValues(alpha: 0.75),
              const Color(0xFFF0F0F5).withValues(alpha: 0.47),
            ];
    }

    final effectiveBorderColor =
        borderColor ??
        resolvedTheme.glassBorderColor ??
        (effectiveDark
            ? Colors.white.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.80));
    final effectiveBorderWidth = borderWidth ?? resolvedTheme.glassBorderWidth;
    final effectiveHairlineColor =
        hairlineBorderColor ??
        resolvedTheme.glassHairlineBorderColor ??
        Colors.black.withValues(alpha: 0.06);

    final effectiveShadows =
        shadows ??
        resolvedTheme.glassShadows ??
        [
          BoxShadow(
            color: Colors.black.withValues(alpha: effectiveDark ? 0.48 : 0.14),
            blurRadius: effectiveBlur >= 30.0 ? 28 : 22,
            offset: Offset(0, effectiveBlur >= 30.0 ? 10 : 8),
            spreadRadius: -2,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: effectiveDark ? 0.25 : 0.08),
            blurRadius: effectiveBlur >= 30.0 ? 10 : 8,
            offset: Offset(0, effectiveBlur >= 30.0 ? 4 : 3),
          ),
        ];

    return Container(
      width: width,
      height: height,
      constraints: constraints,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(cornerRadius),
        border: (!effectiveDark && showLightOuterHairline)
            ? Border.all(color: effectiveHairlineColor, width: 0.6)
            : null,
        boxShadow: effectiveShadows,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(cornerRadius),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: effectiveBlur,
            sigmaY: effectiveBlur,
          ),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: resolvedGradientColors,
              ),
              color: effectiveTint?.withValues(
                alpha: (effectiveTint.a * 0.22).clamp(0.0, 1.0),
              ),
              borderRadius: BorderRadius.circular(cornerRadius),
              border: Border.all(
                color: effectiveBorderColor,
                width: effectiveBorderWidth,
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _NativeLiquidGlassSurface extends StatefulWidget {
  final double cornerRadius;
  final bool isDark;
  final bool isCapsule;
  final Color? tintColor;

  const _NativeLiquidGlassSurface({
    required this.cornerRadius,
    required this.isDark,
    required this.isCapsule,
    this.tintColor,
  });

  @override
  State<_NativeLiquidGlassSurface> createState() =>
      _NativeLiquidGlassSurfaceState();
}

class _NativeLiquidGlassSurfaceState extends State<_NativeLiquidGlassSurface> {
  late final bool _initialIsDark;
  late final double _initialCornerRadius;
  late final bool _initialIsCapsule;
  late final Color? _initialTintColor;

  MethodChannel? _channel;
  bool? _lastSentIsDark;
  double? _lastSentCornerRadius;
  bool? _lastSentIsCapsule;
  int? _lastSentTintArgb;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _initialIsDark = widget.isDark;
    _initialCornerRadius = widget.cornerRadius;
    _initialIsCapsule = widget.isCapsule;
    _initialTintColor = widget.tintColor;
  }

  @override
  void didUpdateWidget(covariant _NativeLiquidGlassSurface oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAppearance();
  }

  @override
  void dispose() {
    _disposed = true;
    _channel = null;
    super.dispose();
  }

  void _handlePlatformViewCreated(int id) {
    if (_disposed) return;
    _channel = MethodChannel('${LiquidGlassCapsule.viewType}_$id');
    _lastSentIsDark = _initialIsDark;
    _lastSentCornerRadius = _initialCornerRadius;
    _lastSentIsCapsule = _initialIsCapsule;
    _lastSentTintArgb = _initialTintColor?.toARGB32();
    _syncAppearance();
  }

  Future<void> _syncAppearance() async {
    final channel = _channel;
    if (channel == null || _disposed) return;

    final cornerChanged =
        ((_lastSentCornerRadius ?? -1.0) - widget.cornerRadius).abs() > 0.1;
    final nextTintArgb = widget.tintColor?.toARGB32();
    if (_lastSentIsDark == widget.isDark &&
        !cornerChanged &&
        _lastSentIsCapsule == widget.isCapsule &&
        _lastSentTintArgb == nextTintArgb) {
      return;
    }

    _lastSentIsDark = widget.isDark;
    _lastSentCornerRadius = widget.cornerRadius;
    _lastSentIsCapsule = widget.isCapsule;
    _lastSentTintArgb = nextTintArgb;

    try {
      await channel.invokeMethod<void>('updateStyle', <String, Object?>{
        'isDark': widget.isDark,
        'cornerRadius': widget.cornerRadius,
        'isCapsule': widget.isCapsule,
        'tintColor': nextTintArgb,
      });
    } catch (_) {
      // Fail gracefully if platform channel tears down during route disposal.
    }
  }

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: LiquidGlassCapsule.viewType,
      layoutDirection: Directionality.maybeOf(context) ?? TextDirection.ltr,
      creationParams: <String, Object?>{
        'isDark': _initialIsDark,
        'cornerRadius': _initialCornerRadius,
        'isCapsule': _initialIsCapsule,
        if (_initialTintColor != null)
          'tintColor': _initialTintColor.toARGB32(),
      },
      creationParamsCodec: const StandardMessageCodec(),
      hitTestBehavior: PlatformViewHitTestBehavior.transparent,
      gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
      onPlatformViewCreated: _handlePlatformViewCreated,
    );
  }
}
