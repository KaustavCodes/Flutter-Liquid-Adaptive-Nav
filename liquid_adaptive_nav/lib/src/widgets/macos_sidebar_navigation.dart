import 'package:flutter/material.dart';

import '../models/nav_models.dart';
import '../theme/liquid_adaptive_nav_theme.dart';
import 'liquid_tactile_button.dart';

/// Custom crisp vector icon matching the macOS Finder/Notes sidebar toggle glyph.
class LiquidSidebarToggleIcon extends StatelessWidget {
  final double size;
  final Color color;

  const LiquidSidebarToggleIcon({
    super.key,
    this.size = 18.0,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.74,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(color: color, width: 1.3),
      ),
      child: Row(
        children: [
          Container(
            width: size * 0.34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.35),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(1.5),
                bottomLeft: Radius.circular(1.5),
              ),
              border: Border(right: BorderSide(color: color, width: 1.2)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sculpted macOS-style sidebar toggle button used in both
/// [MacOSSidebarNavigation] and [LiquidAdaptiveNavShell]'s collapsed toolbar.
class LiquidSidebarToggleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;
  final LiquidAdaptiveNavTheme resolvedTheme;
  final bool isDark;
  final EdgeInsetsGeometry padding;

  const LiquidSidebarToggleButton({
    super.key,
    required this.onPressed,
    required this.tooltip,
    required this.resolvedTheme,
    required this.isDark,
    this.padding = const EdgeInsets.symmetric(horizontal: 7, vertical: 5),
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors =
        resolvedTheme.sidebarToggleButtonColors ??
        (isDark
            ? const [Color(0xFF2E2E35), Color(0xFF232329)]
            : const [Colors.white, Color(0xFFE9E9EE)]);
    final borderColor =
        resolvedTheme.sidebarToggleBorderColor ??
        (isDark
            ? Colors.white.withValues(alpha: 0.14)
            : Colors.black.withValues(alpha: 0.12));
    final iconColor =
        resolvedTheme.sidebarToggleIconColor ??
        (isDark ? const Color(0xFFE4E4E7) : const Color(0xFF3C3C43));

    return LiquidTactileButton(
      tooltip: tooltip,
      borderRadius: BorderRadius.circular(7),
      pressedScale: 0.94,
      onPressed: () {
        resolvedTheme.triggerFeedback();
        onPressed();
      },
      child: Container(
        padding: padding,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(7),
          border: Border.all(color: borderColor, width: 0.8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 3,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: LiquidSidebarToggleIcon(size: 17, color: iconColor),
      ),
    );
  }
}

/// Generic collapsible macOS / desktop sidebar supporting sectioned destinations,
/// per-item action callbacks, custom brand header/footer, and full
/// [LiquidAdaptiveNavTheme] Light/Dark customization.
class MacOSSidebarNavigation extends StatelessWidget {
  final List<LiquidSidebarSection> sections;
  final String? selectedId;
  final ValueChanged<String>? onItemSelected;
  final bool isCollapsed;
  final VoidCallback? onToggleCollapse;
  final bool showCollapseButton;
  final String collapseTooltip;
  final String? title;
  final Widget? brandLeading;
  final WidgetBuilder? headerBuilder;
  final Widget? footer;
  final LiquidAdaptiveNavTheme? theme;
  final Brightness? brightness;

  const MacOSSidebarNavigation({
    super.key,
    required this.sections,
    this.selectedId,
    this.onItemSelected,
    this.isCollapsed = false,
    this.onToggleCollapse,
    this.showCollapseButton = true,
    this.collapseTooltip = 'Hide Sidebar',
    this.title,
    this.brandLeading,
    this.headerBuilder,
    this.footer,
    this.theme,
    this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBrightness = LiquidAdaptiveNavTheme.resolveBrightness(
      context,
      brightnessOverride: brightness,
    );
    final isDark = effectiveBrightness == Brightness.dark;
    final resolvedTheme = LiquidAdaptiveNavTheme.resolve(
      context,
      override: theme,
      brightnessOverride: effectiveBrightness,
    );

    final sidebarBg =
        resolvedTheme.sidebarBackgroundColor ??
        (isDark ? const Color(0xFF1E1E22) : const Color(0xFFF2F2F7));
    final dividerColor =
        resolvedTheme.sidebarDividerColor ??
        (isDark ? const Color(0xFF2C2C32) : const Color(0xFFDCDCE0));
    final width = resolvedTheme.sidebarWidth;

    return AnimatedContainer(
      key: const ValueKey('macos_sidebar_navigation'),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeInOutCubic,
      width: isCollapsed ? 0 : width,
      decoration: BoxDecoration(
        color: sidebarBg,
        border: Border(
          right: BorderSide(
            color: isCollapsed ? Colors.transparent : dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width,
          maxWidth: width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (headerBuilder != null)
                headerBuilder!(context)
              else
                _buildTopHeader(context, isDark, resolvedTheme),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    for (int s = 0; s < sections.length; s++) ...[
                      if (s > 0) const SizedBox(height: 18),
                      if (sections[s].title != null) ...[
                        _buildSectionHeader(sections[s].title!, resolvedTheme),
                        const SizedBox(height: 4),
                      ],
                      for (final item in sections[s].items)
                        _buildSidebarItem(
                          item: item,
                          isDark: isDark,
                          resolvedTheme: resolvedTheme,
                        ),
                    ],
                  ],
                ),
              ),
              if (footer != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                  child: footer!,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopHeader(
    BuildContext context,
    bool isDark,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    final hasBrand = brandLeading != null || (title != null && title!.isNotEmpty);
    if (!hasBrand && !(showCollapseButton && onToggleCollapse != null)) {
      return const SizedBox(height: 12);
    }

    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (hasBrand)
            Expanded(
              child: Row(
                children: [
                  if (brandLeading != null) ...[
                    brandLeading!,
                    if (title != null && title!.isNotEmpty)
                      const SizedBox(width: 8),
                  ],
                  if (title != null && title!.isNotEmpty)
                    Flexible(
                      child: Text(
                        title!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: resolvedTheme.resolveSidebarTitleStyle(
                          isDark: isDark,
                        ),
                      ),
                    ),
                ],
              ),
            )
          else
            const Spacer(),
          if (showCollapseButton && onToggleCollapse != null)
            LiquidSidebarToggleButton(
              key: const ValueKey('mac_hide_sidebar_button'),
              onPressed: onToggleCollapse!,
              tooltip: collapseTooltip,
              resolvedTheme: resolvedTheme,
              isDark: isDark,
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title,
    LiquidAdaptiveNavTheme resolvedTheme,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 4, top: 4),
      child: Text(
        title,
        style: resolvedTheme.resolveSidebarSectionHeaderStyle(),
      ),
    );
  }

  Widget _buildSidebarItem({
    required LiquidSidebarItem item,
    required bool isDark,
    required LiquidAdaptiveNavTheme resolvedTheme,
  }) {
    final isSelected = selectedId != null && selectedId == item.id;
    final selectedGradient = resolvedTheme.sidebarSelectedGradient;
    final selectedColor =
        resolvedTheme.sidebarSelectedColor ??
        resolvedTheme.selectedColor ??
        const Color(0xFF2563EB);
    final selectedBorderColor =
        resolvedTheme.sidebarSelectedBorderColor ??
        Colors.white.withValues(alpha: 0.22);
    final selectedShadowColor =
        resolvedTheme.sidebarSelectedShadowColor ??
        selectedColor.withValues(alpha: 0.28);
    final selectedIconColor =
        resolvedTheme.sidebarSelectedIconColor ??
        resolvedTheme.sidebarSelectedForegroundColor ??
        Colors.white;
    final unselectedIconColor =
        resolvedTheme.sidebarUnselectedIconColor ??
        resolvedTheme.selectedColor ??
        (isDark ? const Color(0xFF38BDF8) : const Color(0xFF007AFF));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: LiquidTactileButton(
        borderRadius: BorderRadius.circular(8),
        pressedScale: 0.98,
        onPressed: () {
          resolvedTheme.triggerFeedback();
          item.onTap?.call();
          if (item.selectsOnTap) {
            onItemSelected?.call(item.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected && selectedGradient == null ? selectedColor : null,
            gradient: isSelected ? selectedGradient : null,
            borderRadius: BorderRadius.circular(8),
            border: isSelected
                ? Border.all(color: selectedBorderColor, width: 0.7)
                : null,
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: selectedShadowColor,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Icon(
                item.iconForSelection(isSelected: isSelected),
                size: 18,
                color: isSelected ? selectedIconColor : unselectedIconColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: resolvedTheme.resolveSidebarItemStyle(
                    isSelected: isSelected,
                  ),
                ),
              ),
              if (item.trailing != null) ...[
                const SizedBox(width: 8),
                item.trailing!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
