import 'dart:math' as math;

import 'package:display_posture_detector/display_posture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../platform/platform_info.dart';

typedef ResponsivePostureWidgetBuilder = Widget Function(
  BuildContext context,
  PostureEvent posture,
  WindowSizeClass sizeClass,
  AdaptiveLayoutMetrics metrics,
);

/// Hardware edge where an asymmetric iOS side strip (e.g. iPhone Duo) resides.
enum DuoSideStripEdge { left, right }

/// Geometry for an asymmetric iOS vertical reserved side strip (e.g. iPhone Duo camera/dock strip).
class DuoSideStripSpec {
  final DuoSideStripEdge edge;
  final double width;
  final EdgeInsets occlusionPadding;
  final List<Rect> occlusionRects;

  const DuoSideStripSpec({
    required this.edge,
    required this.width,
    this.occlusionPadding = EdgeInsets.zero,
    this.occlusionRects = const [],
  });

  /// Wraps [child] with an expanded [MediaQuery] so its `padding` and
  /// `viewPadding` reserve [width] along [edge] for the docked strip.
  Widget wrapContentWithSafeInsets(
    BuildContext context, {
    required Widget child,
  }) {
    final rawMq = MediaQuery.of(context);
    return MediaQuery(
      data: rawMq.copyWith(
        padding: rawMq.padding.copyWith(
          left: edge == DuoSideStripEdge.left
              ? math.max(rawMq.padding.left, width)
              : rawMq.padding.left,
          right: edge == DuoSideStripEdge.right
              ? math.max(rawMq.padding.right, width)
              : rawMq.padding.right,
        ),
        viewPadding: rawMq.viewPadding.copyWith(
          left: edge == DuoSideStripEdge.left
              ? math.max(rawMq.viewPadding.left, width)
              : rawMq.viewPadding.left,
          right: edge == DuoSideStripEdge.right
              ? math.max(rawMq.viewPadding.right, width)
              : rawMq.viewPadding.right,
        ),
      ),
      child: child,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DuoSideStripSpec &&
          runtimeType == other.runtimeType &&
          edge == other.edge &&
          width == other.width &&
          occlusionPadding == other.occlusionPadding &&
          listEquals(occlusionRects, other.occlusionRects);

  @override
  int get hashCode => Object.hash(
    edge,
    width,
    occlusionPadding,
    Object.hashAll(occlusionRects),
  );

  @override
  String toString() =>
      'DuoSideStripSpec(edge: $edge, width: $width, occlusionPadding: $occlusionPadding, occlusions: ${occlusionRects.length})';
}

/// Resolved posture + window geometry helpers used across Phone, Foldable (Book/TableTop),
/// Tablet/iPad, and Desktop macOS windows.
class AdaptiveLayoutMetrics {
  final PostureEvent posture;
  final WindowSizeClass sizeClass;
  final Size viewportSize;
  final Orientation orientation;
  final Size? windowSize;

  const AdaptiveLayoutMetrics({
    required this.posture,
    required this.sizeClass,
    required this.viewportSize,
    required this.orientation,
    this.windowSize,
  });

  Size get effectiveWindowSize => windowSize ?? viewportSize;

  /// Foldable bent horizontally along landscape/portrait screen with top & bottom panes.
  bool get isTableTopSplit =>
      posture.isTableTop &&
      posture.hasHinge &&
      (posture.hingeBounds?.height ?? 0) >= 0;

  /// Foldable opened vertically like a book with distinct left & right regions.
  bool get isBookSplit =>
      posture.isBookPosture &&
      posture.hasHinge &&
      posture.displayAreas.length >= 2;

  /// True when side-by-side 2-pane content should be shown (foldable book, tablet landscape, desktop).
  bool get isDualPane {
    if (isTableTopSplit) return false;
    if (isBookSplit) return true;
    if (viewportSize.width >= 820.0) return true;
    final windowLandscape =
        effectiveWindowSize.width > effectiveWindowSize.height;
    return viewportSize.width >= 720.0 &&
        (orientation == Orientation.landscape ||
            (windowLandscape && effectiveWindowSize.width >= 900.0));
  }

  /// Width of the left display area when hardware dual-screen/foldable hinge is active.
  double? get hingeLeftPaneWidth {
    if (!isBookSplit || posture.displayAreas.length < 2) return null;
    final raw = posture.displayAreas[0].width;
    if (raw <= 0 || raw >= viewportSize.width) return null;
    return raw;
  }

  /// Vertical height of top display area when foldable tabletop hinge is active.
  double? get hingeTopPaneHeight {
    if (!isTableTopSplit) return null;
    final top = posture.hingeBounds?.top;
    if (top != null && top > 120 && top < viewportSize.height - 120) {
      return top;
    }
    if (posture.displayAreas.length >= 2) {
      final h = posture.displayAreas[0].height;
      if (h > 120 && h < viewportSize.height - 120) return h;
    }
    return viewportSize.height * 0.5;
  }

  /// Hinge gap width (horizontal split) or height (vertical tabletop split).
  double get horizontalHingeGap => posture.hasHinge
      ? (posture.hingeBounds?.width ?? 24.0).clamp(12.0, 48.0)
      : 24.0;

  double get verticalHingeGap => posture.hasHinge
      ? (posture.hingeBounds?.height ?? 20.0).clamp(12.0, 48.0)
      : 20.0;

  /// Resolves an asymmetric iOS hardware side strip (e.g. iPhone Duo camera/dock band).
  ///
  /// Returns `null` on macOS, Android, web, and symmetric regular iPhone landscape
  /// (where both left and right safe-area insets are > 20pt due to notch/Dynamic Island).
  DuoSideStripSpec? resolveDuoSideStrip({
    required TargetPlatform platform,
    required EdgeInsets viewPadding,
  }) {
    if (kIsWeb || platform != TargetPlatform.iOS) return null;
    if (viewportSize.width <= 0) return null;

    // Regular notched / Dynamic Island iPhone in landscape has symmetric horizontal
    // safe-area insets (> 20pt on both edges). Reject it explicitly even if native
    // sidePanel bounds were populated from a single-edge check.
    final hasSymmetricHorizontalInsets =
        viewPadding.left > 20.0 && viewPadding.right > 20.0;
    if (hasSymmetricHorizontalInsets) return null;

    final maxReasonableStripWidth = viewportSize.width * 0.35;
    final windowSize = effectiveWindowSize;

    DuoSideStripSpec buildSpec(DuoSideStripEdge edge, double width) {
      final stripHeight = windowSize.height > 0
          ? windowSize.height
          : viewportSize.height;
      final stripRect = PostureRect(
        left: edge == DuoSideStripEdge.right
            ? math.max(0.0, windowSize.width - width)
            : 0.0,
        top: 0.0,
        width: width,
        height: stripHeight,
      );
      final overlapping = posture.occlusionsIn(stripRect);
      if (overlapping.isEmpty) {
        return DuoSideStripSpec(edge: edge, width: width);
      }

      final midY = stripRect.top + stripRect.height * 0.5;
      double topClearance = 0.0;
      double bottomClearance = 0.0;
      final rects = <Rect>[];
      for (final occ in overlapping) {
        rects.add(occ.toRect());
        if (occ.height >= stripRect.height * 0.8) continue;
        final occCenterY = occ.top + occ.height * 0.5;
        if (occCenterY < midY) {
          final clearance = (occ.bottom - stripRect.top) + 8.0;
          if (clearance > topClearance) topClearance = clearance;
        } else {
          final clearance = (stripRect.bottom - occ.top) + 8.0;
          if (clearance > bottomClearance) bottomClearance = clearance;
        }
      }

      return DuoSideStripSpec(
        edge: edge,
        width: width,
        occlusionPadding: EdgeInsets.only(
          top: topClearance,
          bottom: bottomClearance,
        ),
        occlusionRects: List<Rect>.unmodifiable(rects),
      );
    }

    // Priority 1: Asymmetric UIKit safe-area inset on one horizontal edge.
    if (viewPadding.right > 20.0 &&
        viewPadding.left <= 20.0 &&
        viewPadding.right < maxReasonableStripWidth) {
      return buildSpec(DuoSideStripEdge.right, viewPadding.right);
    }
    if (viewPadding.left > 20.0 &&
        viewPadding.right <= 20.0 &&
        viewPadding.left < maxReasonableStripWidth) {
      return buildSpec(DuoSideStripEdge.left, viewPadding.left);
    }

    // Priority 2: Explicit or hardware-emitted PostureEvent.sidePanel when horizontal
    // insets are symmetric zero (e.g. widget test overrides or non-inset leading panes).
    final panel = posture.sidePanel;
    if (panel != null &&
        viewPadding.left <= 20.0 &&
        viewPadding.right <= 20.0 &&
        panel.width > 20.0 &&
        panel.width < maxReasonableStripWidth) {
      final centerX = panel.left + panel.width * 0.5;
      final edge = centerX >= viewportSize.width * 0.5
          ? DuoSideStripEdge.right
          : DuoSideStripEdge.left;
      return buildSpec(edge, panel.width);
    }

    return null;
  }

  /// Convenience wrapper using the inherited [ThemeData.platform] and [MediaQuery.viewPaddingOf].
  DuoSideStripSpec? duoSideStripFor(BuildContext context) {
    return resolveDuoSideStrip(
      platform: Theme.of(context).platform,
      viewPadding: MediaQuery.viewPaddingOf(context),
    );
  }

  /// Returns a derived [AdaptiveLayoutMetrics] scoped to an inner viewport
  /// (e.g. inside a [SafeArea]) while preserving hardware posture & full window size.
  AdaptiveLayoutMetrics withViewportSize(
    Size innerViewportSize, {
    PostureBreakpoints? breakpoints,
    Orientation? orientationOverride,
  }) {
    final bp = breakpoints ?? DisplayPostureDetector.breakpoints;
    return AdaptiveLayoutMetrics(
      posture: posture,
      sizeClass: bp.classify(innerViewportSize.width),
      viewportSize: innerViewportSize,
      orientation: orientationOverride ?? orientation,
      windowSize: effectiveWindowSize,
    );
  }
}

/// Inherited override scope so UI previews and widget tests can inject
/// simulated foldable [PostureEvent] states into any subtree using
/// [ResponsivePostureBuilder].
class ResponsivePostureOverride extends InheritedWidget {
  final PostureEvent? posture;

  const ResponsivePostureOverride({
    super.key,
    required this.posture,
    required super.child,
  });

  static PostureEvent? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ResponsivePostureOverride>()
        ?.posture;
  }

  @override
  bool updateShouldNotify(covariant ResponsivePostureOverride oldWidget) {
    return oldWidget.posture != posture;
  }
}

/// Platform-safe wrapper around [AdaptivePostureBuilder].
/// Uses [AdaptivePostureBuilder] natively on iOS & Android and falls back to
/// responsive window-size classification on macOS/Windows/Linux/Web without
/// invoking mobile-only Method/Event channels.
class ResponsivePostureBuilder extends StatelessWidget {
  final ResponsivePostureWidgetBuilder builder;
  final PostureBreakpoints? breakpoints;
  final PostureEvent? overridePosture;

  const ResponsivePostureBuilder({
    super.key,
    required this.builder,
    this.breakpoints,
    this.overridePosture,
  });

  @override
  Widget build(BuildContext context) {
    final activeBreakpoints = breakpoints ?? DisplayPostureDetector.breakpoints;
    final effectiveOverride =
        overridePosture ?? ResponsivePostureOverride.maybeOf(context);

    if (effectiveOverride != null || !isMobileNativeHost) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final mqSize = MediaQuery.sizeOf(context);
          final width =
              constraints.hasBoundedWidth && constraints.maxWidth.isFinite
              ? constraints.maxWidth
              : mqSize.width;
          final height =
              constraints.hasBoundedHeight && constraints.maxHeight.isFinite
              ? constraints.maxHeight
              : mqSize.height;
          final size = Size(width, height);
          final orientation = width >= height
              ? Orientation.landscape
              : Orientation.portrait;
          final posture =
              effectiveOverride ??
              PostureEvent(
                foldState: FoldState.normal,
                isSeparating: false,
                orientation: orientation == Orientation.landscape
                    ? PostureOrientation.landscape
                    : PostureOrientation.portrait,
              );
          final sizeClass = activeBreakpoints.classify(width);
          return builder(
            context,
            posture,
            sizeClass,
            AdaptiveLayoutMetrics(
              posture: posture,
              sizeClass: sizeClass,
              viewportSize: size,
              orientation: orientation,
              windowSize: mqSize,
            ),
          );
        },
      );
    }

    return AdaptivePostureBuilder(
      breakpoints: activeBreakpoints,
      builder: (context, posture, sizeClass) {
        return LayoutBuilder(
          builder: (context, constraints) {
            final mqSize = MediaQuery.sizeOf(context);
            final width =
                constraints.hasBoundedWidth && constraints.maxWidth.isFinite
                ? constraints.maxWidth
                : mqSize.width;
            final height =
                constraints.hasBoundedHeight && constraints.maxHeight.isFinite
                ? constraints.maxHeight
                : mqSize.height;
            final orientation = MediaQuery.of(context).orientation;
            return builder(
              context,
              posture,
              sizeClass,
              AdaptiveLayoutMetrics(
                posture: posture,
                sizeClass: sizeClass,
                viewportSize: Size(width, height),
                orientation: orientation,
                windowSize: mqSize,
              ),
            );
          },
        );
      },
    );
  }
}
