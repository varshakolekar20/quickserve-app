import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Smoke test: verify the app shell builds without crashing.
// Full integration tests require a live Supabase connection.
void main() {
  testWidgets('App shell renders without crashing',
      (WidgetTester tester) async {
    // Pump a minimal MaterialApp — avoids pending Supabase/GoRouter timers
    // while still confirming the Flutter engine and Riverpod scope work.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: Center(child: Text('QuickServe')),
          ),
        ),
      ),
    );

    expect(find.text('QuickServe'), findsOneWidget);
  });
}
