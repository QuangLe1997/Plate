import 'package:flutter_test/flutter_test.dart';

import 'package:platesnap/app/app.dart';

void main() {
  testWidgets('PlateSnap app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PlateSnapApp());

    // Verify that app starts (splash screen shows app name)
    await tester.pump(const Duration(seconds: 1));

    // App should be running without errors
    expect(find.byType(PlateSnapApp), findsOneWidget);
  });
}
