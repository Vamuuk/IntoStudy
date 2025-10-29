// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:into_study/main.dart';

void main() {
  testWidgets('IntoStudy app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IntoStudyApp());

    // Verify that app loads correctly
    expect(find.text('IntoStudy'), findsOneWidget);
    expect(find.text('Dashboard'), findsOneWidget);
    
    // Verify navigation items exist
    expect(find.text('Notes'), findsOneWidget);
    expect(find.text('Q&A'), findsOneWidget);
  });
  
  testWidgets('Navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const IntoStudyApp());

    // Initially on Dashboard
    expect(find.text('Welcome back, ACHO!'), findsOneWidget);

    // Tap on Notes navigation item
    await tester.tap(find.text('Notes'));
    await tester.pumpAndSettle();

    // Verify we're on Notes screen
    expect(find.text('Shared Notes'), findsOneWidget);

    // Tap on Q&A navigation item
    await tester.tap(find.text('Q&A'));
    await tester.pumpAndSettle();

    // Verify we're on Q&A screen
    expect(find.text('Q&A Forum'), findsOneWidget);
  });
}