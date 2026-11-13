import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:liquid_adaptive_nav/liquid_adaptive_nav.dart';

void main() {
  runApp(const LiquidAdaptiveNavExampleApp());
}

class LiquidAdaptiveNavExampleApp extends StatefulWidget {
  const LiquidAdaptiveNavExampleApp({super.key});

  @override
  State<LiquidAdaptiveNavExampleApp> createState() =>
      _LiquidAdaptiveNavExampleAppState();
}

enum _DemoThemePreset {
  oceanBlue('Ocean Blue', Color(0xFF007AFF), Color(0xFF38BDF8)),
  sunsetOrange('Sunset', Color(0xFFEA580C), Color(0xFFFB923C)),
  emeraldMint('Emerald', Color(0xFF059669), Color(0xFF34D399)),
  royalViolet('Violet', Color(0xFF7C3AED), Color(0xFFA78BFA));

  final String label;
  final Color lightSelected;
  final Color darkSelected;

  const _DemoThemePreset(this.label, this.lightSelected, this.darkSelected);
}

enum _DemoFontChoice {
  system('System', null),
  rounded('Rounded / Avenir', 'Avenir Next'),
  serif('Editorial Serif', 'Georgia'),
  mono('Monospace', 'Courier');

  final String label;
  final String? family;

  const _DemoFontChoice(this.label, this.family);
}

enum _PreviewPlatform {
  host('Host'),
  iOS('iOS'),
  android('Android'),
  macOS('macOS');

  final String label;

  const _PreviewPlatform(this.label);

  TargetPlatform? get platform => switch (this) {
    _PreviewPlatform.host => null,
    _PreviewPlatform.iOS => TargetPlatform.iOS,
    _PreviewPlatform.android => TargetPlatform.android,
    _PreviewPlatform.macOS => TargetPlatform.macOS,
  };
}

class _LiquidAdaptiveNavExampleAppState
    extends State<LiquidAdaptiveNavExampleApp> {
  ThemeMode _themeMode = ThemeMode.system;
  _DemoThemePreset _preset = _DemoThemePreset.oceanBlue;
  _DemoFontChoice _fontChoice = _DemoFontChoice.system;
  FloatingNavPlatformStyle _platformStyle = FloatingNavPlatformStyle.adaptive;
  bool _enableNativeGlass = true;
  bool _tintNativeGlass = false;
  bool _simulateDuoStrip = false;
  bool _useRtl = false;
  _PreviewPlatform _previewPlatform = _PreviewPlatform.host;
  double _blurSigma = 28.0;
  double _labelSizeOffset = 0.0;

  LiquidAdaptiveNavTheme _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final selected = isDark ? _preset.darkSelected : _preset.lightSelected;
    final unselected = isDark
        ? const Color(0xFF9CA3AF)
        : const Color(0xFF3A3A3C);
    final base = isDark
        ? LiquidAdaptiveNavTheme.dark(
            fontFamily: _fontChoice.family,
            selectedColor: selected,
            unselectedColor: unselected,
            activeIndicatorColor: selected.withValues(alpha: 0.20),
            enableNativeGlass: _enableNativeGlass,
            blurSigma: _blurSigma,
            nativeGlassTintColor: _tintNativeGlass
                ? selected.withValues(alpha: 0.35)
                : null,
          )
        : LiquidAdaptiveNavTheme.light(
            fontFamily: _fontChoice.family,
            selectedColor: selected,
            unselectedColor: unselected,
            activeIndicatorColor: selected.withValues(alpha: 0.14),
            enableNativeGlass: _enableNativeGlass,
            blurSigma: _blurSigma,
            nativeGlassTintColor: _tintNativeGlass
                ? selected.withValues(alpha: 0.35)
                : null,
          );

    return base.copyWith(
      labelTextStyle: TextStyle(fontSize: 11 + _labelSizeOffset),
      selectedLabelTextStyle: TextStyle(
        fontSize: 11 + _labelSizeOffset,
        fontWeight: FontWeight.w700,
      ),
      sidebarItemTextStyle: TextStyle(fontSize: 13.5 + _labelSizeOffset),
      selectedSidebarItemTextStyle: TextStyle(
        fontSize: 13.5 + _labelSizeOffset,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lightNavTheme = _buildTheme(Brightness.light);
    final darkNavTheme = _buildTheme(Brightness.dark);

    final simulatedPosture = _simulateDuoStrip
        ? const PostureEvent(
            foldState: FoldState.flat,
            isSeparating: false,
            orientation: PostureOrientation.portrait,
            deviceType: DeviceType.iphone,
            sidePanel: PostureRect(left: 330, top: 0, width: 84, height: 896),
            occlusionAreas: [
              PostureRect(left: 330, top: 0, width: 84, height: 132),
            ],
          )
        : null;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'liquid_adaptive_nav Demo',
      themeMode: _themeMode,
      builder: (context, child) {
        final preview = _previewPlatform.platform;
        Widget result = child ?? const SizedBox.shrink();
        if (preview != null) {
          result = Theme(
            data: Theme.of(context).copyWith(platform: preview),
            child: result,
          );
        }
        return Directionality(
          textDirection: _useRtl ? TextDirection.rtl : TextDirection.ltr,
          child: result,
        );
      },
      theme: ThemeData(
        brightness: Brightness.light,
        colorSchemeSeed: _preset.lightSelected,
        useMaterial3: true,
        extensions: [lightNavTheme],
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorSchemeSeed: _preset.darkSelected,
        useMaterial3: true,
        extensions: [darkNavTheme],
      ),
      home: Builder(
        builder: (context) {
          return ResponsivePostureOverride(
            posture: simulatedPosture,
            child: _DemoHomeShell(
              themeMode: _themeMode,
              preset: _preset,
              fontChoice: _fontChoice,
              platformStyle: _platformStyle,
              enableNativeGlass: _enableNativeGlass,
              tintNativeGlass: _tintNativeGlass,
              simulateDuoStrip: _simulateDuoStrip,
              useRtl: _useRtl,
              previewPlatform: _previewPlatform,
              blurSigma: _blurSigma,
              labelSizeOffset: _labelSizeOffset,
              onThemeModeChanged: (m) => setState(() => _themeMode = m),
              onPresetChanged: (p) => setState(() => _preset = p),
              onFontChanged: (f) => setState(() => _fontChoice = f),
              onPlatformStyleChanged: (s) => setState(() => _platformStyle = s),
              onNativeGlassChanged: (v) =>
                  setState(() => _enableNativeGlass = v),
              onTintGlassChanged: (v) => setState(() => _tintNativeGlass = v),
              onSimulateDuoChanged: (v) => setState(() {
                _simulateDuoStrip = v;
                if (v) _previewPlatform = _PreviewPlatform.iOS;
              }),
              onUseRtlChanged: (v) => setState(() => _useRtl = v),
              onPreviewPlatformChanged: (p) =>
                  setState(() => _previewPlatform = p),
              onBlurChanged: (v) => setState(() => _blurSigma = v),
              onLabelSizeOffsetChanged: (v) =>
                  setState(() => _labelSizeOffset = v),
            ),
          );
        },
      ),
    );
  }
}

class _DemoHomeShell extends StatefulWidget {
  final ThemeMode themeMode;
  final _DemoThemePreset preset;
  final _DemoFontChoice fontChoice;
  final FloatingNavPlatformStyle platformStyle;
  final bool enableNativeGlass;
  final bool tintNativeGlass;
  final bool simulateDuoStrip;
  final bool useRtl;
  final _PreviewPlatform previewPlatform;
  final double blurSigma;
  final double labelSizeOffset;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<_DemoThemePreset> onPresetChanged;
  final ValueChanged<_DemoFontChoice> onFontChanged;
  final ValueChanged<FloatingNavPlatformStyle> onPlatformStyleChanged;
  final ValueChanged<bool> onNativeGlassChanged;
  final ValueChanged<bool> onTintGlassChanged;
  final ValueChanged<bool> onSimulateDuoChanged;
  final ValueChanged<bool> onUseRtlChanged;
  final ValueChanged<_PreviewPlatform> onPreviewPlatformChanged;
  final ValueChanged<double> onBlurChanged;
  final ValueChanged<double> onLabelSizeOffsetChanged;

  const _DemoHomeShell({
    required this.themeMode,
    required this.preset,
    required this.fontChoice,
    required this.platformStyle,
    required this.enableNativeGlass,
    required this.tintNativeGlass,
    required this.simulateDuoStrip,
    required this.useRtl,
    required this.previewPlatform,
    required this.blurSigma,
    required this.labelSizeOffset,
    required this.onThemeModeChanged,
    required this.onPresetChanged,
    required this.onFontChanged,
    required this.onPlatformStyleChanged,
    required this.onNativeGlassChanged,
    required this.onTintGlassChanged,
    required this.onSimulateDuoChanged,
    required this.onUseRtlChanged,
    required this.onPreviewPlatformChanged,
    required this.onBlurChanged,
    required this.onLabelSizeOffsetChanged,
  });

  @override
  State<_DemoHomeShell> createState() => _DemoHomeShellState();
}

class _DemoHomeShellState extends State<_DemoHomeShell> {
  int _selectedIndex = 0;
  String _selectedSidebarId = 'home';

  static const _destinations = <LiquidNavDestination>[
    LiquidNavDestination(
      id: 'home',
      label: 'Home',
      icon: CupertinoIcons.house,
      selectedIcon: CupertinoIcons.house_fill,
      materialIcon: Icons.home_outlined,
      materialSelectedIcon: Icons.home,
    ),
    LiquidNavDestination(
      id: 'explore',
      label: 'Explore',
      icon: CupertinoIcons.compass,
      selectedIcon: CupertinoIcons.compass_fill,
      materialIcon: Icons.explore_outlined,
      materialSelectedIcon: Icons.explore,
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
  ];

  void _openDetailScreen(BuildContext context, AdaptiveLayoutMetrics metrics) {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => const _DemoDetailPage()));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeAccent = isDark
        ? widget.preset.darkSelected
        : widget.preset.lightSelected;

    return LiquidAdaptiveNavShell(
      destinations: _destinations,
      selectedIndex: _selectedIndex,
      onDestinationSelected: (idx) {
        setState(() {
          _selectedIndex = idx;
          _selectedSidebarId = _destinations[idx].id ?? 'dest_$idx';
        });
      },
      platformStyle: widget.platformStyle,
      sidebarTitle: 'LiquidNav',
      sidebarBrandLeading: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [activeAccent, activeAccent.withValues(alpha: 0.7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(7),
        ),
        child: const Icon(
          CupertinoIcons.sparkles,
          size: 14,
          color: Colors.white,
        ),
      ),
      sidebarSections: [
        LiquidSidebarSection(
          title: 'Workspace',
          items: [
            LiquidSidebarItem(
              id: 'home',
              title: 'Home',
              icon: CupertinoIcons.house,
              selectedIcon: CupertinoIcons.house_fill,
            ),
            LiquidSidebarItem(
              id: 'explore',
              title: 'Explore',
              icon: CupertinoIcons.compass,
              selectedIcon: CupertinoIcons.compass_fill,
            ),
            LiquidSidebarItem(
              id: 'library',
              title: 'Library',
              icon: CupertinoIcons.book,
              selectedIcon: CupertinoIcons.book_fill,
            ),
          ],
        ),
        LiquidSidebarSection(
          title: 'Quick Actions',
          items: [
            LiquidSidebarItem(
              id: 'detail_modal',
              title: 'Open Detail Page',
              icon: CupertinoIcons.arrow_up_right_square,
              selectsOnTap: false,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const _DemoDetailPage(),
                ),
              ),
            ),
            LiquidSidebarItem(
              id: 'settings',
              title: 'Theme Settings',
              icon: CupertinoIcons.gear_alt,
              selectedIcon: CupertinoIcons.gear_alt_fill,
            ),
          ],
        ),
      ],
      selectedSidebarId: _selectedSidebarId,
      onSidebarItemSelected: (id) {
        setState(() {
          _selectedSidebarId = id;
          final idx = _destinations.indexWhere((d) => d.id == id);
          if (idx >= 0) _selectedIndex = idx;
        });
      },
      toolbarActions: [
        IconButton(
          tooltip: 'Toggle Light/Dark',
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          onPressed: () => widget.onThemeModeChanged(
            isDark ? ThemeMode.light : ThemeMode.dark,
          ),
        ),
      ],
      bodyBuilder: (context, metrics) {
        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                sliver: SliverList.list(
                  children: [
                    _HeaderCard(
                      destination: _destinations[_selectedIndex],
                      metrics: metrics,
                      accentColor: activeAccent,
                      onOpenDetail: () => _openDetailScreen(context, metrics),
                    ),
                    const SizedBox(height: 16),
                    _AppearanceControlsCard(
                      themeMode: widget.themeMode,
                      preset: widget.preset,
                      fontChoice: widget.fontChoice,
                      platformStyle: widget.platformStyle,
                      enableNativeGlass: widget.enableNativeGlass,
                      tintNativeGlass: widget.tintNativeGlass,
                      simulateDuoStrip: widget.simulateDuoStrip,
                      useRtl: widget.useRtl,
                      previewPlatform: widget.previewPlatform,
                      blurSigma: widget.blurSigma,
                      labelSizeOffset: widget.labelSizeOffset,
                      onThemeModeChanged: widget.onThemeModeChanged,
                      onPresetChanged: widget.onPresetChanged,
                      onFontChanged: widget.onFontChanged,
                      onPlatformStyleChanged: widget.onPlatformStyleChanged,
                      onNativeGlassChanged: widget.onNativeGlassChanged,
                      onTintGlassChanged: widget.onTintGlassChanged,
                      onSimulateDuoChanged: widget.onSimulateDuoChanged,
                      onUseRtlChanged: widget.onUseRtlChanged,
                      onPreviewPlatformChanged: widget.onPreviewPlatformChanged,
                      onBlurChanged: widget.onBlurChanged,
                      onLabelSizeOffsetChanged: widget.onLabelSizeOffsetChanged,
                    ),
                    const SizedBox(height: 16),
                    _StandaloneCapsulePreview(
                      accentColor: activeAccent,
                      isDark: isDark,
                      fontFamily: widget.fontChoice.family,
                      blurSigma: widget.blurSigma,
                      enableNativeGlass: widget.enableNativeGlass,
                      tintNativeGlass: widget.tintNativeGlass,
                    ),
                    const SizedBox(height: 16),
                    const _BottomClearanceCard(),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final LiquidNavDestination destination;
  final AdaptiveLayoutMetrics metrics;
  final Color accentColor;
  final VoidCallback onOpenDetail;

  const _HeaderCard({
    required this.destination,
    required this.metrics,
    required this.accentColor,
    required this.onOpenDetail,
  });

  @override
  Widget build(BuildContext context) {
    final duoStrip = metrics.duoSideStripFor(context);
    final cs = Theme.of(context).colorScheme;

    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: accentColor.withValues(alpha: 0.16),
                  child: Icon(
                    destination.iconForSelection(isSelected: true),
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${destination.label} Tab',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        'SizeClass: ${metrics.sizeClass.name} • '
                        '${metrics.viewportSize.width.toStringAsFixed(0)}×'
                        '${metrics.viewportSize.height.toStringAsFixed(0)} dp'
                        '${duoStrip != null ? ' • Duo Strip (${duoStrip.edge.name} ${duoStrip.width.toStringAsFixed(0)}dp)' : ''}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${Theme.of(context).platform.name} • '
                        '${Directionality.of(context).name} • '
                        'bottom inset ${MediaQuery.paddingOf(context).bottom.toStringAsFixed(0)} • '
                        'hinge ${metrics.horizontalHingeGap.toStringAsFixed(0)}×${metrics.verticalHingeGap.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            FilledButton.tonalIcon(
              onPressed: onOpenDetail,
              icon: const Icon(CupertinoIcons.rectangle_stack),
              label: const Text('Push Detail Route (DuoSideActionStrip)'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppearanceControlsCard extends StatelessWidget {
  final ThemeMode themeMode;
  final _DemoThemePreset preset;
  final _DemoFontChoice fontChoice;
  final FloatingNavPlatformStyle platformStyle;
  final bool enableNativeGlass;
  final bool tintNativeGlass;
  final bool simulateDuoStrip;
  final bool useRtl;
  final _PreviewPlatform previewPlatform;
  final double blurSigma;
  final double labelSizeOffset;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ValueChanged<_DemoThemePreset> onPresetChanged;
  final ValueChanged<_DemoFontChoice> onFontChanged;
  final ValueChanged<FloatingNavPlatformStyle> onPlatformStyleChanged;
  final ValueChanged<bool> onNativeGlassChanged;
  final ValueChanged<bool> onTintGlassChanged;
  final ValueChanged<bool> onSimulateDuoChanged;
  final ValueChanged<bool> onUseRtlChanged;
  final ValueChanged<_PreviewPlatform> onPreviewPlatformChanged;
  final ValueChanged<double> onBlurChanged;
  final ValueChanged<double> onLabelSizeOffsetChanged;

  const _AppearanceControlsCard({
    required this.themeMode,
    required this.preset,
    required this.fontChoice,
    required this.platformStyle,
    required this.enableNativeGlass,
    required this.tintNativeGlass,
    required this.simulateDuoStrip,
    required this.useRtl,
    required this.previewPlatform,
    required this.blurSigma,
    required this.labelSizeOffset,
    required this.onThemeModeChanged,
    required this.onPresetChanged,
    required this.onFontChanged,
    required this.onPlatformStyleChanged,
    required this.onNativeGlassChanged,
    required this.onTintGlassChanged,
    required this.onSimulateDuoChanged,
    required this.onUseRtlChanged,
    required this.onPreviewPlatformChanged,
    required this.onBlurChanged,
    required this.onLabelSizeOffsetChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Theme, Colors & Font Playground',
              style: Theme.of(context).textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),
            Text(
              'Appearance Mode',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.system, label: Text('System')),
                ButtonSegment(value: ThemeMode.light, label: Text('Light')),
                ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
              ],
              selected: {themeMode},
              onSelectionChanged: (s) => onThemeModeChanged(s.first),
            ),
            const SizedBox(height: 14),
            Text(
              'Selected Color',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _DemoThemePreset.values)
                  ChoiceChip(
                    avatar: CircleAvatar(
                      backgroundColor: item.lightSelected,
                      radius: 8,
                    ),
                    label: Text(item.label),
                    selected: preset == item,
                    onSelected: (_) => onPresetChanged(item),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Label Font Family',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final font in _DemoFontChoice.values)
                  ChoiceChip(
                    label: Text(
                      font.label,
                      style: TextStyle(fontFamily: font.family),
                    ),
                    selected: fontChoice == font,
                    onSelected: (_) => onFontChanged(font),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              'Preview platform',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Host follows this device. iOS shows the glass pill, Duo strip, or sidebar. Android shows a NavigationBar, or a NavigationRail when the window is wide.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final item in _PreviewPlatform.values)
                  ChoiceChip(
                    label: Text(item.label),
                    selected: previewPlatform == item,
                    onSelected: (_) => onPreviewPlatformChanged(item),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            Text('Bar style', style: Theme.of(context).textTheme.labelMedium),
            const SizedBox(height: 6),
            SegmentedButton<FloatingNavPlatformStyle>(
              segments: const [
                ButtonSegment(
                  value: FloatingNavPlatformStyle.adaptive,
                  label: Text('Adaptive'),
                ),
                ButtonSegment(
                  value: FloatingNavPlatformStyle.appleGlass,
                  label: Text('Glass'),
                ),
                ButtonSegment(
                  value: FloatingNavPlatformStyle.material,
                  label: Text('Material'),
                ),
              ],
              selected: {platformStyle},
              onSelectionChanged: (s) => onPlatformStyleChanged(s.first),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Expanded(child: Text('Blur Sigma (Fallback Glass)')),
                Text(blurSigma.toStringAsFixed(0)),
              ],
            ),
            Slider(value: blurSigma, min: 8, max: 44, onChanged: onBlurChanged),
            Row(
              children: [
                const Expanded(child: Text('Label Font Size Offset')),
                Text(
                  '${labelSizeOffset >= 0 ? '+' : ''}${labelSizeOffset.toStringAsFixed(1)}',
                ),
              ],
            ),
            Slider(
              value: labelSizeOffset,
              min: -1.5,
              max: 3.0,
              divisions: 9,
              onChanged: onLabelSizeOffsetChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Use Native iOS 26+ UIGlassEffect'),
              value: enableNativeGlass,
              onChanged: onNativeGlassChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Tint glass capsule'),
              subtitle: const Text(
                'Colors the native iOS glass and the Flutter blur fallback.',
              ),
              value: tintNativeGlass,
              onChanged: onTintGlassChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Right-to-left layout'),
              subtitle: const Text(
                'The pill indicator should follow the first destination.',
              ),
              value: useRtl,
              onChanged: onUseRtlChanged,
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Simulate iPhone Duo side strip'),
              subtitle: const Text(
                'Switches the preview platform to iOS and docks a vertical pill.',
              ),
              value: simulateDuoStrip,
              onChanged: onSimulateDuoChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomClearanceCard extends StatelessWidget {
  const _BottomClearanceCard();

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cs = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: cs.primaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Text(
          'End of page. This card should sit fully above the floating pill. '
          'Bottom MediaQuery padding is ${bottom.toStringAsFixed(0)} dp.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: cs.onPrimaryContainer,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _StandaloneCapsulePreview extends StatelessWidget {
  final Color accentColor;
  final bool isDark;
  final String? fontFamily;
  final double blurSigma;
  final bool enableNativeGlass;
  final bool tintNativeGlass;

  const _StandaloneCapsulePreview({
    required this.accentColor,
    required this.isDark,
    required this.fontFamily,
    required this.blurSigma,
    required this.enableNativeGlass,
    required this.tintNativeGlass,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1F2937), accentColor.withValues(alpha: 0.45)]
              : [accentColor.withValues(alpha: 0.28), const Color(0xFFFDE68A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: LiquidGlassCapsule(
          cornerRadius: 28,
          isDark: isDark,
          blurSigma: blurSigma,
          enableNativeGlass: enableNativeGlass,
          tintColor: tintNativeGlass
              ? accentColor.withValues(alpha: 0.45)
              : null,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(CupertinoIcons.wand_stars, color: accentColor),
              const SizedBox(width: 10),
              Text(
                'Standalone LiquidGlassCapsule',
                style: TextStyle(
                  fontFamily: fontFamily,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : const Color(0xFF1C1C1E),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DemoDetailPage extends StatelessWidget {
  const _DemoDetailPage();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Screen')),
      body: LiquidDuoPageContainer(
        duoActionsBuilder: (context, metrics, strip) => [
          DuoSideActionItem(
            icon: CupertinoIcons.back,
            label: 'Back',
            onPressed: () => Navigator.of(context).maybePop(),
          ),
          DuoSideActionItem(
            icon: CupertinoIcons.star,
            label: 'Star',
            color: isDark ? Colors.amberAccent : Colors.orange,
            onPressed: () {},
          ),
          DuoSideActionItem(
            icon: CupertinoIcons.share,
            label: 'Share',
            onPressed: () {},
          ),
        ],
        builder: (context, metrics, duoStrip) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(CupertinoIcons.layers_alt, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    duoStrip != null
                        ? 'Pushed screen automatically reserves ${duoStrip.width.toStringAsFixed(0)}dp along ${duoStrip.edge.name} edge and docks DuoSideActionStrip.'
                        : 'On compact iPhone / macOS / Android this renders standard SafeArea content.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
