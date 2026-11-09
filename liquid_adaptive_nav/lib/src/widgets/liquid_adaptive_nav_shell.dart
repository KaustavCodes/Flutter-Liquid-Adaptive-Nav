import 'package:display_posture_detector/display_posture_detector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/nav_models.dart';
import '../posture/responsive_posture_builder.dart';
import '../theme/liquid_adaptive_nav_theme.dart';
import 'duo_side_action_strip.dart';
import 'floating_pill_nav_bar.dart';
import 'macos_sidebar_navigation.dart';

typedef AdaptiveShellBodyBuilder = Widget Function(
  BuildContext context,
  AdaptiveLayoutMetrics metrics,
);

typedef AdaptiveShellUseSidebarPredicate = bool Function(
  BuildContext context,
  AdaptiveLayoutMetrics metrics,
  DuoSideStripSpec? duoSideStrip,
);

/// Top-level adaptive navigation shell coordinating:
/// - **Desktop / macOS / Landscape Tablet**: Collapsible [MacOSSidebarNavigation]
///   plus an animated top toolbar toggle bar when collapsed.
/// - **Foldable / iPhone Duo**: Docked vertical [FloatingPillNavBar] aligned
///   with the asymmetric hardware side strip, automatically expanding the
///   content subtree's `MediaQuery` safe insets clear of the strip.
/// - **Phone / Portrait Tablet**: Floating bottom Apple Liquid Glass pill or
///   Material 3 Android [NavigationBar] (controlled via [platformStyle]).
class LiquidAdaptiveNavShell extends StatefulWidget {
  final List<LiquidNavDestination> destinations;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;

  /// Dynamic builder receiving live [AdaptiveLayoutMetrics] (for foldable dual-pane
  /// / tablet / mobile layouts). Supply either [bodyBuilder] or [pages].
  final AdaptiveShellBodyBuilder? bodyBuilder;

  /// Optional list of destination pages indexed by [selectedIndex] when
  /// [bodyBuilder] is not supplied.
  final List<Widget>? pages;

  // Sidebar customization
  final List<LiquidSidebarSection>? sidebarSections;
  final String? selectedSidebarId;
  final ValueChanged<String>? onSidebarItemSelected;
  final Widget? sidebarBrandLeading;
  final String? sidebarTitle;
  final WidgetBuilder? sidebarHeaderBuilder;
  final Widget? sidebarFooter;
  final bool initialSidebarCollapsed;
  final ValueChanged<bool>? onSidebarCollapsedChanged;
  final String Function(BuildContext context, int selectedIndex)?
  toolbarTitleBuilder;
  final List<Widget>? toolbarActions;

  // Adaptive layout / platform options
  final FloatingNavPlatformStyle platformStyle;
  final PostureBreakpoints? breakpoints;
  final PostureEvent? overridePosture;
  final AdaptiveShellUseSidebarPredicate? useSidebarPredicate;

  // Theming (Light / Dark + Font + Colors)
  final LiquidAdaptiveNavTheme? theme;
  final LiquidAdaptiveNavTheme? lightTheme;
  final LiquidAdaptiveNavTheme? darkTheme;
  final Brightness? brightness;
  final Color? scaffoldBackgroundColor;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? activeIndicatorColor;
  final String? fontFamily;
  final bool? enableNativeGlass;
  final bool? enableHaptics;

  const LiquidAdaptiveNavShell({
    super.key,
    required this.destinations,
    required this.selectedIndex,
    required this.onDestinationSelected,
    this.bodyBuilder,
    this.pages,
    this.sidebarSections,
    this.selectedSidebarId,
    this.onSidebarItemSelected,
    this.sidebarBrandLeading,
    this.sidebarTitle,
    this.sidebarHeaderBuilder,
    this.sidebarFooter,
    this.initialSidebarCollapsed = false,
    this.onSidebarCollapsedChanged,
    this.toolbarTitleBuilder,
    this.toolbarActions,
    this.platformStyle = FloatingNavPlatformStyle.adaptive,
    this.breakpoints,
    this.overridePosture,
    this.useSidebarPredicate,
    this.theme,
    this.lightTheme,
    this.darkTheme,
    this.brightness,
    this.scaffoldBackgroundColor,
    this.selectedColor,
    this.unselectedColor,
    this.activeIndicatorColor,
    this.fontFamily,
    this.enableNativeGlass,
    this.enableHaptics,
  }) : assert(destinations.length > 0, 'destinations must not be empty.'),
       assert(
         bodyBuilder != null || pages != null,
         'Provide either bodyBuilder or pages.',
       );

  @override
  State<LiquidAdaptiveNavShell> createState() => _LiquidAdaptiveNavShellState();
}

class _LiquidAdaptiveNavShellState extends State<LiquidAdaptiveNavShell> {
  late bool _isSidebarCollapsed;

  @override
  void initState() {
    super.initState();
    _isSidebarCollapsed = widget.initialSidebarCollapsed;
  }

  String _effectiveDestinationId(int index) {
    final dest = widget.destinations[index];
    return dest.id ?? 'dest_$index';
  }

  List<LiquidSidebarSection> _resolveSidebarSections() {
    if (widget.sidebarSections != null) return widget.sidebarSections!;
    return [
      LiquidSidebarSection(
        items: [
          for (int i = 0; i < widget.destinations.length; i++)
            LiquidSidebarItem(
              id: _effectiveDestinationId(i),
              title: widget.destinations[i].label,
              icon: widget.destinations[i].icon,
              selectedIcon: widget.destinations[i].selectedIcon,
            ),
        ],
      ),
    ];
  }

  void _handleSidebarSelected(String id) {
    if (widget.onSidebarItemSelected != null) {
      widget.onSidebarItemSelected!(id);
      return;
    }
    for (int i = 0; i < widget.destinations.length; i++) {
      if (_effectiveDestinationId(i) == id) {
        widget.onDestinationSelected(i);
        return;
      }
    }
  }

  void _setSidebarCollapsed(bool collapsed) {
    setState(() {
      _isSidebarCollapsed = collapsed;
    });
    widget.onSidebarCollapsedChanged?.call(collapsed);
  }

  Widget _buildBody(BuildContext context, AdaptiveLayoutMetrics metrics) {
    if (widget.bodyBuilder != null) {
      return widget.bodyBuilder!(context, metrics);
    }
    final activeIndex = widget.selectedIndex.clamp(0, widget.pages!.length - 1);
    return IndexedStack(index: activeIndex, children: widget.pages!);
  }

  Widget _buildCollapsedSidebarToolbar(
    BuildContext context,
    bool isDark,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    final toolbarBg =
        resolvedTheme.collapsedToolbarBackgroundColor ??
        (isDark ? const Color(0xFF18181B) : const Color(0xFFF6F6F9));
    final hairline =
        resolvedTheme.collapsedToolbarDividerColor ??
        (isDark ? const Color(0xFF27272D) : const Color(0xFFE2E2E8));
    final activeIndex = widget.selectedIndex.clamp(
      0,
      widget.destinations.length - 1,
    );
    final title =
        widget.toolbarTitleBuilder?.call(context, activeIndex) ??
        widget.destinations[activeIndex].label;

    return Container(
      key: const ValueKey('mac_collapsed_toolbar'),
      height: resolvedTheme.collapsedToolbarHeight,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: toolbarBg,
        border: Border(bottom: BorderSide(color: hairline, width: 1.0)),
      ),
      child: Row(
        children: [
          LiquidSidebarToggleButton(
            key: const ValueKey('mac_show_sidebar_button'),
            tooltip: 'Show Sidebar',
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            resolvedTheme: resolvedTheme,
            isDark: isDark,
            onPressed: () => _setSidebarCollapsed(false),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: resolvedTheme.resolveCollapsedToolbarTitleStyle(
                isDark: isDark,
              ),
            ),
          ),
          if (widget.toolbarActions != null) ...widget.toolbarActions!,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = LiquidAdaptiveNavTheme.resolveBrightness(
      context,
      brightnessOverride: widget.brightness,
    );
    final isDark = effectiveBrightness == Brightness.dark;
    final resolvedTheme =
        LiquidAdaptiveNavTheme.resolve(
          context,
          override: widget.theme,
          lightTheme: widget.lightTheme,
          darkTheme: widget.darkTheme,
          brightnessOverride: effectiveBrightness,
        ).withOverrides(
          fontFamily: widget.fontFamily,
          selectedColor: widget.selectedColor,
          unselectedColor: widget.unselectedColor,
          activeIndicatorColor: widget.activeIndicatorColor,
          scaffoldBackgroundColor: widget.scaffoldBackgroundColor,
          enableNativeGlass: widget.enableNativeGlass,
          enableHaptics: widget.enableHaptics,
        );

    final platform = Theme.of(context).platform;
    final isMacOS = !kIsWeb && platform == TargetPlatform.macOS;
    final isAndroid =
        widget.platformStyle == FloatingNavPlatformStyle.material ||
        (widget.platformStyle == FloatingNavPlatformStyle.adaptive &&
            platform == TargetPlatform.android);
    final bg =
        resolvedTheme.scaffoldBackgroundColor ??
        (isDark ? const Color(0xFF121214) : const Color(0xFFF8F8FA));

    return ResponsivePostureBuilder(
      breakpoints: widget.breakpoints,
      overridePosture: widget.overridePosture,
      builder: (context, posture, sizeClass, metrics) {
        final width = metrics.viewportSize.width;
        final duoSideStrip = metrics.duoSideStripFor(context);
        final isSidebarLayout =
            widget.useSidebarPredicate?.call(context, metrics, duoSideStrip) ??
            (duoSideStrip == null &&
                !posture.hasHinge &&
                (DisplayPostureDetector.isDesktopWidth(width) ||
                    (isMacOS && width >= 760.0) ||
                    (DisplayPostureDetector.isMediumWidth(width) &&
                        metrics.orientation == Orientation.landscape &&
                        width >= 900.0)));

        if (isSidebarLayout) {
          final activeIndex = widget.selectedIndex.clamp(
            0,
            widget.destinations.length - 1,
          );
          final effectiveSidebarId =
              widget.selectedSidebarId ?? _effectiveDestinationId(activeIndex);

          return Scaffold(
            backgroundColor: bg,
            body: Row(
              children: [
                MacOSSidebarNavigation(
                  sections: _resolveSidebarSections(),
                  selectedId: effectiveSidebarId,
                  onItemSelected: _handleSidebarSelected,
                  isCollapsed: _isSidebarCollapsed,
                  onToggleCollapse: () =>
                      _setSidebarCollapsed(!_isSidebarCollapsed),
                  title: widget.sidebarTitle,
                  brandLeading: widget.sidebarBrandLeading,
                  headerBuilder: widget.sidebarHeaderBuilder,
                  footer: widget.sidebarFooter,
                  theme: resolvedTheme,
                  brightness: effectiveBrightness,
                ),
                Expanded(
                  child: Column(
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, anim) => SizeTransition(
                          sizeFactor: anim,
                          alignment: Alignment.topCenter,
                          child: FadeTransition(opacity: anim, child: child),
                        ),
                        child: _isSidebarCollapsed
                            ? SafeArea(
                                bottom: false,
                                child: _buildCollapsedSidebarToolbar(
                                  context,
                                  isDark,
                                  resolvedTheme,
                                ),
                              )
                            : const SizedBox.shrink(
                                key: ValueKey('mac_expanded_no_toolbar'),
                              ),
                      ),
                      Expanded(
                        child: MediaQuery.removePadding(
                          context: context,
                          removeTop: _isSidebarCollapsed,
                          child: _buildBody(context, metrics),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        Widget contentChild = _buildBody(context, metrics);
        if (duoSideStrip != null) {
          contentChild = duoSideStrip.wrapContentWithSafeInsets(
            context,
            child: contentChild,
          );
        }

        return Scaffold(
          backgroundColor: bg,
          body: Stack(
            children: [
              Positioned.fill(child: contentChild),
              if (!isAndroid && duoSideStrip != null)
                Positioned(
                  top: 0,
                  bottom: 0,
                  left: duoSideStrip.edge == DuoSideStripEdge.left ? 0 : null,
                  right: duoSideStrip.edge == DuoSideStripEdge.right ? 0 : null,
                  width: duoSideStrip.width,
                  child: FloatingPillNavBar(
                    axis: Axis.vertical,
                    sideStripEdge: duoSideStrip.edge,
                    sideStripWidth: duoSideStrip.width,
                    sideStripOcclusionPadding: duoSideStrip.occlusionPadding,
                    platformStyle: widget.platformStyle,
                    destinations: widget.destinations,
                    selectedIndex: widget.selectedIndex,
                    onDestinationSelected: widget.onDestinationSelected,
                    theme: resolvedTheme,
                    brightness: effectiveBrightness,
                  ),
                )
              else if (!isAndroid)
                FloatingPillNavBar(
                  platformStyle: widget.platformStyle,
                  destinations: widget.destinations,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                  theme: resolvedTheme,
                  brightness: effectiveBrightness,
                ),
            ],
          ),
          bottomNavigationBar: isAndroid
              ? FloatingPillNavBar(
                  platformStyle: widget.platformStyle,
                  destinations: widget.destinations,
                  selectedIndex: widget.selectedIndex,
                  onDestinationSelected: widget.onDestinationSelected,
                  theme: resolvedTheme,
                  brightness: effectiveBrightness,
                )
              : null,
        );
      },
    );
  }
}

/// Convenience posture-aware container for pushed routes / detail screens that
/// automatically pads content clear of an asymmetric iOS / iPhone Duo side strip
/// and docks optional [duoActionsBuilder] actions inside [DuoSideActionStrip].
class LiquidDuoPageContainer extends StatelessWidget {
  final Widget Function(
    BuildContext context,
    AdaptiveLayoutMetrics metrics,
    DuoSideStripSpec? duoSideStrip,
  )
  builder;
  final List<DuoSideActionItem> Function(
    BuildContext context,
    AdaptiveLayoutMetrics metrics,
    DuoSideStripSpec duoSideStrip,
  )?
  duoActionsBuilder;
  final bool forceDarkGlass;
  final LiquidAdaptiveNavTheme? theme;
  final Brightness? brightness;
  final PostureBreakpoints? breakpoints;
  final PostureEvent? overridePosture;

  const LiquidDuoPageContainer({
    super.key,
    required this.builder,
    this.duoActionsBuilder,
    this.forceDarkGlass = false,
    this.theme,
    this.brightness,
    this.breakpoints,
    this.overridePosture,
  });

  @override
  Widget build(BuildContext context) {
    return ResponsivePostureBuilder(
      breakpoints: breakpoints,
      overridePosture: overridePosture,
      builder: (context, posture, sizeClass, metrics) {
        final duoSideStrip = metrics.duoSideStripFor(context);
        Widget content = builder(context, metrics, duoSideStrip);
        if (duoSideStrip != null) {
          content = duoSideStrip.wrapContentWithSafeInsets(
            context,
            child: content,
          );
        }

        final actions = (duoSideStrip != null && duoActionsBuilder != null)
            ? duoActionsBuilder!(context, metrics, duoSideStrip)
            : const <DuoSideActionItem>[];

        if (duoSideStrip == null || actions.isEmpty) {
          return content;
        }

        return Stack(
          children: [
            Positioned.fill(child: content),
            DuoSideActionStrip.positioned(
              strip: duoSideStrip,
              actions: actions,
              forceDarkGlass: forceDarkGlass,
              theme: theme,
              brightness: brightness,
            ),
          ],
        );
      },
    );
  }
}
