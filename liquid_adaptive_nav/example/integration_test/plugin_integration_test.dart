import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:liquid_adaptive_nav_example/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Boots example app integration flow', (tester) async {
    await tester.pumpWidget(const LiquidAdaptiveNavExampleApp());
    await tester.pumpAndSettle();

    expect(find.text('Home Tab'), findsOneWidget);
  });
}
