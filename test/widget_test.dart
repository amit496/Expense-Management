import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/theme/app_theme.dart';

void main() {
  testWidgets('app theme smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        home: const Scaffold(
          body: Center(child: Text('ExpenseTracker')),
        ),
      ),
    );

    expect(find.text('ExpenseTracker'), findsOneWidget);
  });
}
