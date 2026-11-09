import 'package:flutter/material.dart';

/// Controls how [FloatingPillNavBar] and [LiquidAdaptiveNavShell] style
/// compact/mobile navigation bars.
enum FloatingNavPlatformStyle {
  /// Renders Apple frosted/liquid-glass pills on iOS/macOS/desktop/web and a
  /// Material 3 [NavigationBar] on Android.
  adaptive,

  /// Always renders the frosted/liquid-glass pill navigation bar on every
  /// platform, including Android.
  appleGlass,

  /// Always renders the Material 3 [NavigationBar] on horizontal layouts
  /// (and falls back to vertical pill only when docked in an asymmetric Duo strip).
  material,
}

/// Destination entry for [FloatingPillNavBar] and [LiquidAdaptiveNavShell].
class LiquidNavDestination {
  /// Optional identifier if the app maps sidebar or route IDs to destinations.
  final String? id;

  /// Short label displayed beneath the icon (or in tooltip when space is tight).
  final String label;

  /// Default icon used on Apple glass pills (and fallback on Material).
  final IconData icon;

  /// Optional filled/selected icon variant used when active.
  final IconData? selectedIcon;

  /// Optional Material icon override used when rendering Android [NavigationBar].
  final IconData? materialIcon;

  /// Optional Material selected icon override used when rendering Android [NavigationBar].
  final IconData? materialSelectedIcon;

  /// Optional semantic label or accessibility tooltip.
  final String? tooltip;

  const LiquidNavDestination({
    this.id,
    required this.label,
    required this.icon,
    this.selectedIcon,
    this.materialIcon,
    this.materialSelectedIcon,
    this.tooltip,
  });

  /// Effective icon shown in Apple glass pill / desktop items.
  IconData iconForSelection({required bool isSelected}) =>
      isSelected ? (selectedIcon ?? icon) : icon;

  /// Effective icon shown in Material [NavigationBar].
  IconData materialIconForSelection({required bool isSelected}) => isSelected
      ? (materialSelectedIcon ?? selectedIcon ?? materialIcon ?? icon)
      : (materialIcon ?? icon);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LiquidNavDestination &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          label == other.label &&
          icon == other.icon &&
          selectedIcon == other.selectedIcon &&
          materialIcon == other.materialIcon &&
          materialSelectedIcon == other.materialSelectedIcon &&
          tooltip == other.tooltip;

  @override
  int get hashCode => Object.hash(
    id,
    label,
    icon,
    selectedIcon,
    materialIcon,
    materialSelectedIcon,
    tooltip,
  );
}

/// Item descriptor inside a [LiquidSidebarSection] of [MacOSSidebarNavigation].
class LiquidSidebarItem {
  /// Unique destination or action identifier.
  final String id;

  /// Display title shown in the sidebar row.
  final String title;

  /// Default icon when unselected.
  final IconData icon;

  /// Optional filled/active icon when selected.
  final IconData? selectedIcon;

  /// Optional per-item tap handler (useful for modal/action rows like Folders).
  /// When non-null, tapping invokes [onTap] in addition to/instead of selection
  /// depending on [selectsOnTap].
  final VoidCallback? onTap;

  /// Whether tapping also notifies `onItemSelected(item.id)`.
  final bool selectsOnTap;

  /// Optional badge/trailing widget on the right of the row.
  final Widget? trailing;

  const LiquidSidebarItem({
    required this.id,
    required this.title,
    required this.icon,
    this.selectedIcon,
    this.onTap,
    this.selectsOnTap = true,
    this.trailing,
  });

  IconData iconForSelection({required bool isSelected}) =>
      isSelected ? (selectedIcon ?? icon) : icon;
}

/// Logical group of items inside [MacOSSidebarNavigation].
class LiquidSidebarSection {
  /// Optional uppercase/muted section header above [items].
  final String? title;

  /// Navigation/action rows belonging to this section.
  final List<LiquidSidebarItem> items;

  const LiquidSidebarSection({this.title, required this.items});
}

/// Action descriptor for a frosted-glass button inside [DuoSideActionStrip].
class DuoSideActionItem {
  final IconData icon;
  final String label;
  final Color? color;
  final String? tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  const DuoSideActionItem({
    required this.icon,
    required this.label,
    this.color,
    this.tooltip,
    this.enabled = true,
    required this.onPressed,
  });
}
