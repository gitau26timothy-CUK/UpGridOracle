// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:upgridoracle/main.dart';

void main() {
  testWidgets('UpGridOracle launches smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const UpGridApp());

    // Verify splash screen shows.
    expect(find.text('UpGridOracle'), findsOneWidget);
    expect(find.text('Hyper-Local Smart Grid Pricing'), findsOneWidget);
    expect(find.text('Get Started'), findsOneWidget);
  });
}
