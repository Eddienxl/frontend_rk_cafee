// Basic Flutter widget test for RK Cafe POS App
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend_rk_cafee/main.dart';

void main() {
  testWidgets('RK Cafe App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const RKCafeApp());

    // Verify that we see loading indicator initially
    expect(find.text('Memuat...'), findsOneWidget);
  });
}
