import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_adaptive_nav/liquid_adaptive_nav.dart';

const _sampleDestinations = <LiquidNavDestination>[
  LiquidNavDestination(
    id: 'home',
    label: 'Home',
    icon: CupertinoIcons.house,
    selectedIcon: CupertinoIcons.house_fill,
    materialIcon: Icons.home_outlined,
    materialSelectedIcon: Icons.home,
  ),
  LiquidNavDestination(
    id: 'search',
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

void main() {
  group('LiquidAdaptiveNavTheme', () {
    test(
      'light and dark presets provide distinct defaults and lerp smoothly',
      () {
        final light = LiquidAdaptiveNavTheme.light(
          fontFamily: 'Georgia',
          selectedColor: const Color(0xFFEA580C),
        );
        final dark = LiquidAdaptiveNavTheme.dark(
          fontFamily: 'Courier',
          selectedColor: const Color(0xFF38BDF8),
        );

        expect(light.selectedColor, const Color(0xFFEA580C));
        expect(light.selectedIconColor, const Color(0xFFEA580C));
        expect(light.fontFamily, 'Georgia');
        expect(
          light.resolveHorizontalLabelStyle(isSelected: true).fontFamily,
          'Georgia',
        );
        expect(
          light.resolveHorizontalLabelStyle(isSelected: true).color,
          const Color(0xFFEA580C),
        );

        final mid = light.lerp(dark, 0.5);
        expect(
          mid.selectedColor,
          Color.lerp(const Color(0xFFEA580C), const Color(0xFF38BDF8), 0.5),
        );
        expect(mid.fontFamily, 'Courier');
      },
    );

    test('equal presets compare equal and copy cleanly', () {
      final first = LiquidAdaptiveNavTheme.light(
        fontFamily: 'Georgia',
        selectedColor: const Color(0xFFEA580C),
      );
      final second = LiquidAdaptiveNavTheme.light(
        fontFamily: 'Georgia',
        selectedColor: const Color(0xFFEA580C),
      );

      expect(first, second);
      expect(first.hashCode, second.hashCode);
      expect(first, first.copyWith());
      expect(first, isNot(LiquidAdaptiveNavTheme.dark()));
      expect(
        first.horizontalContentBottomInset(EdgeInsets.zero),
        first.horizontalPillHeight + 24,
      );
    });

    test('fromColorScheme and withOverrides cascade colors & font cleanly', () {
      final scheme = ColorScheme.fromSeed(
        seedColor: Colors.teal,
        brightness: Brightness.dark,
      );
      final derived =
          LiquidAdaptiveNavTheme.fromColorScheme(
            scheme,
            fontFamily: 'Avenir Next',
          ).withOverrides(
            selectedColor: Colors.amber,
            unselectedColor: Colors.grey,
          );

      expect(derived.fontFamily, 'Avenir Next');
      expect(derived.selectedIconColor, Colors.amber);
      expect(derived.selectedLabelColor, Colors.amber);
      expect(derived.unselectedIconColor, Colors.grey);
      expect(derived.unselectedLabelColor, Colors.grey);
      expect(derived.scaffoldBackgroundColor, scheme.surface);
    });

    testWidgets('resolves automatically inside CupertinoApp + ThemeScope', (
      tester,
    ) async {
      late LiquidAdaptiveNavTheme resolvedDark;

      await tester.pumpWidget(
        CupertinoApp(
          theme: const CupertinoThemeData(brightness: Brightness.dark),
          home: LiquidAdaptiveNavThemeScope(
            theme: LiquidAdaptiveNavTheme.dark(
              fontFamily: 'Courier',
              selectedColor: Colors.pinkAccent,
            ),
            child: Builder(
              builder: (context) {
                resolvedDark = LiquidAdaptiveNavTheme.resolve(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );

      expect(resolvedDark.fontFamily, 'Courier');
      expect(resolvedDark.selectedColor, Colors.pinkAccent);
    });
  });

  group('FloatingPillNavBar', () {
    testWidgets(
      'renders iOS horizontal frosted pill with arbitrary count & custom colors/font',
      (tester) async {
        int tappedIndex = -1;
        const customSelected = Color(0xFFFF6B00);
        const customUnselected = Color(0xFF6B7280);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Scaffold(
              body: Stack(
                children: [
                  FloatingPillNavBar(
                    destinations: const [
                      LiquidNavDestination(
                        label: 'One',
                        icon: CupertinoIcons.circle,
                        selectedIcon: CupertinoIcons.circle_fill,
                      ),
                      LiquidNavDestination(
                        label: 'Two',
                        icon: CupertinoIcons.square,
                        selectedIcon: CupertinoIcons.square_fill,
                      ),
                      LiquidNavDestination(
                        label: 'Three',
                        icon: CupertinoIcons.star,
                        selectedIcon: CupertinoIcons.star_fill,
                      ),
                    ],
                    selectedIndex: 1,
                    onDestinationSelected: (idx) => tappedIndex = idx,
                    selectedColor: customSelected,
                    unselectedColor: customUnselected,
                    fontFamily: 'Courier',
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('floating_pill_nav_horizontal')),
          findsOneWidget,
        );

        final selectedText = tester.widget<Text>(find.text('Two'));
        expect(selectedText.style?.color, customSelected);
        expect(selectedText.style?.fontFamily, 'Courier');

        final unselectedText = tester.widget<Text>(find.text('One'));
        expect(unselectedText.style?.color, customUnselected);
        expect(unselectedText.style?.fontFamily, 'Courier');

        await tester.tap(find.text('Three'));
        expect(tappedIndex, 2);
      },
    );

    testWidgets(
      'renders Android Material 3 NavigationBar in adaptive mode & glass in appleGlass mode',
      (tester) async {
        int selected = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              bottomNavigationBar: FloatingPillNavBar(
                destinations: _sampleDestinations,
                selectedIndex: selected,
                onDestinationSelected: (i) => selected = i,
                selectedColor: Colors.deepPurple,
                fontFamily: 'Georgia',
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('floating_pill_nav_android')),
          findsOneWidget,
        );
        expect(find.byType(NavigationBar), findsOneWidget);

        await tester.tap(find.text('Library'));
        expect(selected, 2);

        // Explicit appleGlass style forces frosted pill even on Android
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: Scaffold(
              body: Stack(
                children: [
                  FloatingPillNavBar(
                    destinations: _sampleDestinations,
                    selectedIndex: selected,
                    onDestinationSelected: (i) => selected = i,
                    platformStyle: FloatingNavPlatformStyle.appleGlass,
                  ),
                ],
              ),
            ),
          ),
        );

        expect(
          find.byKey(const ValueKey('floating_pill_nav_horizontal')),
          findsOneWidget,
        );
        expect(find.byType(NavigationBar), findsNothing);
      },
    );

    testWidgets('slides the active indicator from the leading edge in RTL', (
      tester,
    ) async {
      Future<void> pumpPill(TextDirection direction, int selected) {
        return tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: Directionality(
              textDirection: direction,
              child: Scaffold(
                body: Stack(
                  children: [
                    FloatingPillNavBar(
                      destinations: const [
                        LiquidNavDestination(
                          label: 'One',
                          icon: CupertinoIcons.circle,
                        ),
                        LiquidNavDestination(
                          label: 'Two',
                          icon: CupertinoIcons.square,
                        ),
                      ],
                      selectedIndex: selected,
                      onDestinationSelected: (_) {},
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      await pumpPill(TextDirection.ltr, 0);
      final ltr = tester.widget<AnimatedPositioned>(
        find.byKey(const ValueKey('floating_pill_active_indicator')),
      );
      expect(ltr.left, isNotNull);
      expect(ltr.right, isNull);

      await pumpPill(TextDirection.rtl, 0);
      final rtlFirst = tester.widget<AnimatedPositioned>(
        find.byKey(const ValueKey('floating_pill_active_indicator')),
      );
      expect(rtlFirst.left, isNull);
      expect(rtlFirst.right, ltr.left);

      await pumpPill(TextDirection.rtl, 1);
      final rtlSecond = tester.widget<AnimatedPositioned>(
        find.byKey(const ValueKey('floating_pill_active_indicator')),
      );
      expect(rtlSecond.right, greaterThan(rtlFirst.right!));
    });

    testWidgets(
      'paints a Flutter tint overlay for opaque and translucent colors',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: LiquidGlassCapsule(
              cornerRadius: 24,
              tintColor: Color(0xFFFF3B30),
              child: Text('Tinted'),
            ),
          ),
        );

        final opaque = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('liquid_glass_tint_overlay')),
        );
        expect(opaque.color.a, closeTo(0.22, 0.001));

        await tester.pumpWidget(
          const MaterialApp(
            home: LiquidGlassCapsule(
              cornerRadius: 24,
              tintColor: Color(0x66FF3B30),
              child: Text('Tinted'),
            ),
          ),
        );

        final translucent = tester.widget<ColoredBox>(
          find.byKey(const ValueKey('liquid_glass_tint_overlay')),
        );
        expect(translucent.color.a, closeTo(0x66 / 255, 0.01));
      },
    );
  });

  group('Duo Side Strip & AdaptiveLayoutMetrics', () {
    test('ignores symmetric notched iPhone landscape viewPadding', () {
      const metrics = AdaptiveLayoutMetrics(
        posture: PostureEvent(
          foldState: FoldState.normal,
          isSeparating: false,
          orientation: PostureOrientation.landscape,
          sidePanel: PostureRect(left: 790, top: 0, width: 62, height: 393),
        ),
        sizeClass: WindowSizeClass.medium,
        viewportSize: Size(852, 393),
        orientation: Orientation.landscape,
      );

      final strip = metrics.resolveDuoSideStrip(
        platform: TargetPlatform.iOS,
        viewPadding: const EdgeInsets.only(left: 59, right: 59, bottom: 21),
      );
      expect(strip, isNull);
    });

    test(
      'resolves asymmetric iPhone Duo strip & camera occlusion clearances',
      () {
        const metrics = AdaptiveLayoutMetrics(
          posture: PostureEvent(
            foldState: FoldState.flat,
            isSeparating: false,
            orientation: PostureOrientation.landscape,
            sidePanel: PostureRect(left: 867, top: 0, width: 84, height: 669),
            occlusionAreas: [
              PostureRect(left: 867, top: 0, width: 84, height: 112),
              PostureRect(left: 867, top: 589, width: 84, height: 80),
            ],
          ),
          sizeClass: WindowSizeClass.medium,
          viewportSize: Size(951, 669),
          orientation: Orientation.landscape,
        );

        final strip = metrics.resolveDuoSideStrip(
          platform: TargetPlatform.iOS,
          viewPadding: const EdgeInsets.only(right: 84),
        );
        expect(strip, isNotNull);
        expect(strip!.edge, DuoSideStripEdge.right);
        expect(strip.width, 84);
        expect(strip.occlusionPadding.top, closeTo(120, 0.01));
        expect(strip.occlusionPadding.bottom, closeTo(88, 0.01));

        // Android & macOS never resolve an iOS hardware side strip
        expect(
          metrics.resolveDuoSideStrip(
            platform: TargetPlatform.android,
            viewPadding: const EdgeInsets.only(right: 84),
          ),
          isNull,
        );
        expect(
          metrics.resolveDuoSideStrip(
            platform: TargetPlatform.macOS,
            viewPadding: const EdgeInsets.only(right: 84),
          ),
          isNull,
        );
      },
    );

    test('hinge gaps stay zero until a hinge has thickness on that axis', () {
      const flat = AdaptiveLayoutMetrics(
        posture: PostureEvent(
          foldState: FoldState.normal,
          isSeparating: false,
          orientation: PostureOrientation.portrait,
        ),
        sizeClass: WindowSizeClass.compact,
        viewportSize: Size(390, 844),
        orientation: Orientation.portrait,
      );
      expect(flat.horizontalHingeGap, 0);
      expect(flat.verticalHingeGap, 0);
      expect(flat.isTableTopSplit, isFalse);

      const tabletop = AdaptiveLayoutMetrics(
        posture: PostureEvent(
          foldState: FoldState.halfOpened,
          isSeparating: false,
          orientation: PostureOrientation.landscape,
          hingeBounds: PostureRect(left: 0, top: 400, width: 800, height: 16),
          displayAreas: [
            PostureRect(left: 0, top: 0, width: 800, height: 400),
            PostureRect(left: 0, top: 416, width: 800, height: 400),
          ],
        ),
        sizeClass: WindowSizeClass.medium,
        viewportSize: Size(800, 816),
        orientation: Orientation.landscape,
      );
      expect(tabletop.isTableTopSplit, isTrue);
      expect(tabletop.verticalHingeGap, 16);
      expect(tabletop.horizontalHingeGap, 48);
    });

    testWidgets('DuoSideActionStrip renders actions and triggers callbacks', (
      tester,
    ) async {
      bool backed = false;
      bool deleted = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(platform: TargetPlatform.iOS),
          home: Scaffold(
            body: Stack(
              children: [
                DuoSideActionStrip.positioned(
                  strip: const DuoSideStripSpec(
                    edge: DuoSideStripEdge.right,
                    width: 84,
                  ),
                  forceDarkGlass: true,
                  actions: [
                    DuoSideActionItem(
                      icon: CupertinoIcons.back,
                      label: 'Back',
                      onPressed: () => backed = true,
                    ),
                    DuoSideActionItem(
                      icon: CupertinoIcons.trash,
                      label: 'Delete',
                      color: Colors.redAccent,
                      onPressed: () => deleted = true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey('duo_side_action_pill')),
        findsOneWidget,
      );

      await tester.tap(find.text('Back'));
      expect(backed, isTrue);

      await tester.tap(find.text('Delete'));
      expect(deleted, isTrue);
    });
  });

  group('LiquidAdaptiveNavShell & MacOSSidebarNavigation', () {
    testWidgets(
      'switches cleanly between collapsible desktop sidebar and mobile floating pill',
      (tester) async {
        int currentIndex = 0;

        // Desktop width -> collapsible MacOSSidebarNavigation
        tester.view.physicalSize = const Size(1180, 760);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.macOS),
            home: StatefulBuilder(
              builder: (context, setState) {
                return LiquidAdaptiveNavShell(
                  destinations: _sampleDestinations,
                  selectedIndex: currentIndex,
                  onDestinationSelected: (i) =>
                      setState(() => currentIndex = i),
                  sidebarTitle: 'TestApp',
                  pages: [
                    for (final d in _sampleDestinations)
                      Center(child: Text('Page: ${d.label}')),
                  ],
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('macos_sidebar_navigation')),
          findsOneWidget,
        );
        expect(find.text('TestApp'), findsOneWidget);
        expect(find.text('Page: Home'), findsOneWidget);

        await tester.tap(find.text('Settings'));
        await tester.pumpAndSettle();
        expect(find.text('Page: Settings'), findsOneWidget);

        final semantics = tester.ensureSemantics();
        String semanticsTree() {
          SemanticsNode? root;
          void visit(PipelineOwner owner) {
            root ??= owner.semanticsOwner?.rootSemanticsNode;
            if (root == null) owner.visitChildren(visit);
          }

          visit(tester.binding.rootPipelineOwner);
          return root?.toStringDeep() ?? '';
        }
        expect(semanticsTree(), contains('Hide Sidebar'));
        expect(semanticsTree(), contains('Home'));

        // Collapse sidebar -> collapsed toolbar should appear with Show button.
        // Collapsed rows stay out of the semantics tree.
        await tester.tap(find.byKey(const ValueKey('mac_hide_sidebar_button')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('mac_collapsed_toolbar')),
          findsOneWidget,
        );
        final collapsedTree = semanticsTree();
        semantics.dispose();
        expect(collapsedTree, isNot(contains('Hide Sidebar')));
        expect(collapsedTree, isNot(contains('Home')));

        // Expand back
        await tester.tap(find.byKey(const ValueKey('mac_show_sidebar_button')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('mac_expanded_no_toolbar')),
          findsOneWidget,
        );

        // Shrink to compact iPhone width -> switches to bottom floating pill
        tester.view.physicalSize = const Size(390, 844);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('floating_pill_nav_horizontal')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('macos_sidebar_navigation')),
          findsNothing,
        );
      },
    );

    testWidgets(
      'docks vertical side-strip pill & expands content MediaQuery padding on Duo iOS',
      (tester) async {
        tester.view.physicalSize = const Size(414, 896);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        EdgeInsets? reportedPadding;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(414, 896),
                viewPadding: EdgeInsets.only(right: 84),
                padding: EdgeInsets.only(right: 84),
              ),
              child: LiquidAdaptiveNavShell(
                destinations: _sampleDestinations,
                selectedIndex: 0,
                onDestinationSelected: (_) {},
                bodyBuilder: (context, metrics) {
                  reportedPadding = MediaQuery.paddingOf(context);
                  return const SizedBox.expand();
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('floating_pill_nav_vertical')),
          findsOneWidget,
        );
        expect(reportedPadding?.right, greaterThanOrEqualTo(84.0));
      },
    );

    testWidgets(
      'reserves bottom MediaQuery padding above the horizontal glass pill',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: LiquidAdaptiveNavShell(
              destinations: _sampleDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              bodyBuilder: (context, metrics) {
                return SafeArea(
                  child: const Align(
                    alignment: Alignment.bottomCenter,
                    child: Text('clearance', key: ValueKey('pill_clearance')),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        final clearance = tester.getRect(
          find.byKey(const ValueKey('pill_clearance')),
        );
        final pill = tester.getRect(
          find.byKey(const ValueKey('floating_pill_nav_horizontal')),
        );
        expect(clearance.bottom, lessThanOrEqualTo(pill.top + 1));
      },
    );

    testWidgets(
      'uses a Material rail on wide Android and keeps the sidebar for apple glass',
      (tester) async {
        tester.view.physicalSize = const Size(1280, 900);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: LiquidAdaptiveNavShell(
              destinations: _sampleDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              pages: [
                for (final destination in _sampleDestinations)
                  Text('Page: ${destination.label}'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byKey(const ValueKey('material_nav_rail')), findsOneWidget);
        expect(
          find.byKey(const ValueKey('macos_sidebar_navigation')),
          findsNothing,
        );
        expect(find.byType(NavigationBar), findsNothing);

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: LiquidAdaptiveNavShell(
              platformStyle: FloatingNavPlatformStyle.appleGlass,
              destinations: _sampleDestinations,
              selectedIndex: 0,
              onDestinationSelected: (_) {},
              pages: [
                for (final destination in _sampleDestinations)
                  Text('Page: ${destination.label}'),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('macos_sidebar_navigation')),
          findsOneWidget,
        );
        expect(find.byKey(const ValueKey('material_nav_rail')), findsNothing);
      },
    );

    testWidgets(
      'LiquidDuoPageContainer docks DuoSideActionStrip when asymmetric strip exists',
      (tester) async {
        bool tappedAction = false;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: MediaQuery(
              data: const MediaQueryData(
                size: Size(414, 896),
                viewPadding: EdgeInsets.only(right: 84),
              ),
              child: Scaffold(
                body: LiquidDuoPageContainer(
                  duoActionsBuilder: (context, metrics, strip) => [
                    DuoSideActionItem(
                      icon: CupertinoIcons.checkmark,
                      label: 'Done',
                      onPressed: () => tappedAction = true,
                    ),
                  ],
                  builder: (context, metrics, duoStrip) {
                    return Text(duoStrip?.edge.name ?? 'none');
                  },
                ),
              ),
            ),
          ),
        );

        expect(find.text('right'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('duo_side_action_pill')),
          findsOneWidget,
        );

        await tester.tap(find.text('Done'));
        expect(tappedAction, isTrue);
      },
    );
  });
}
