import 'package:flutter/material.dart';

/// Returns `true` when [Theme.of(context).platform] targets Apple hardware
/// (`iOS` or `macOS`).
bool isAppleTargetPlatform(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;
}

/// Platform-adaptive tactile wrapper used inside pills, strips, and sidebars:
/// - Apple (`iOS` & `macOS`): Cupertino press opacity + micro scale-down + hover rim.
/// - Android / other platforms: Material [InkWell] ripple feedback.
class LiquidTactileButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final BorderRadius borderRadius;
  final double pressedScale;
  final double pressedOpacity;
  final String? tooltip;
  final Color? hoverColor;

  const LiquidTactileButton({
    super.key,
    required this.child,
    required this.onPressed,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.82,
    this.tooltip,
    this.hoverColor,
  });

  @override
  State<LiquidTactileButton> createState() => _LiquidTactileButtonState();
}

class _LiquidTactileButtonState extends State<LiquidTactileButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final apple = isAppleTargetPlatform(context);
    final enabled = widget.onPressed != null;
    final effectiveHoverColor =
        widget.hoverColor ?? Colors.white.withValues(alpha: 0.06);

    Widget interactive;
    if (apple) {
      interactive = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _isPressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _isPressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _isPressed = false) : null,
        onTap: widget.onPressed,
        child: AnimatedScale(
          scale: _isPressed ? widget.pressedScale : 1.0,
          duration: const Duration(milliseconds: 95),
          curve: Curves.easeOutCubic,
          child: AnimatedOpacity(
            opacity: !enabled
                ? 0.55
                : (_isPressed ? widget.pressedOpacity : 1.0),
            duration: const Duration(milliseconds: 95),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 140),
              decoration: BoxDecoration(
                borderRadius: widget.borderRadius,
                color: _isHovered && enabled
                    ? effectiveHoverColor
                    : Colors.transparent,
              ),
              foregroundDecoration: _isHovered && enabled
                  ? BoxDecoration(
                      borderRadius: widget.borderRadius,
                      color: effectiveHoverColor,
                    )
                  : null,
              child: widget.child,
            ),
          ),
        ),
      );
    } else {
      interactive = Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: widget.borderRadius,
          onTap: widget.onPressed,
          child: widget.child,
        ),
      );
    }

    interactive = Semantics(
      button: true,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: interactive,
      ),
    );

    if (widget.tooltip != null && widget.tooltip!.isNotEmpty) {
      return Tooltip(message: widget.tooltip!, child: interactive);
    }
    return interactive;
  }
}
