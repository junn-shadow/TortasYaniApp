import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/main.dart';
import 'package:recipe_book/screens/splash_screen.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the splash screen is displayed.
    expect(find.byType(SplashScreen), findsOneWidget);

    // Pump pending timers and animations so they settle.
    await tester.pump(const Duration(seconds: 4));
  });
}
