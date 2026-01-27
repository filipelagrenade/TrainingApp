/// LiftIQ - Basic Widget Test
///
/// This test verifies that the app's core components can be imported
/// and basic widgets work correctly. Full app smoke tests are better
/// handled in integration tests due to complex routing and auth setup.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:liftiq/core/theme/app_theme.dart';

void main() {
  testWidgets('AppTheme provides valid light and dark themes',
      (WidgetTester tester) async {
    // Verify light theme is valid
    expect(AppTheme.light, isA<ThemeData>());
    expect(AppTheme.light.brightness, equals(Brightness.light));

    // Verify dark theme is valid
    expect(AppTheme.dark, isA<ThemeData>());
    expect(AppTheme.dark.brightness, equals(Brightness.dark));

    // Verify both use Material 3
    expect(AppTheme.light.useMaterial3, isTrue);
    expect(AppTheme.dark.useMaterial3, isTrue);
  });

  testWidgets('Basic MaterialApp with theme renders correctly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          home: const Scaffold(
            body: Center(
              child: Text('LiftIQ Test'),
            ),
          ),
        ),
      ),
    );

    expect(find.text('LiftIQ Test'), findsOneWidget);
  });
}
