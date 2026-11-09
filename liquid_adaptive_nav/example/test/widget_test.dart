import 'package:flutter_test/flutter_test.dart';
import 'package:liquid_adaptive_nav_example/main.dart';

void main() {
  testWidgets('Example app renders navigation shell cleanly', (tester) async {
    await tester.pumpWidget(const LiquidAdaptiveNavExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Home Tab'), findsOneWidget);
    expect(find.text('Theme, Colors & Font Playground'), findsOneWidget);
  });
}
