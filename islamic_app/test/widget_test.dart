// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:islamic_companion/main.dart';
import 'package:islamic_companion/services/storage_service.dart';

void main() {
  testWidgets('renders the home screen', (WidgetTester tester) async {
    await StorageService.init();
    await StorageService.saveLocation(21.4225, 39.8262);
    await tester.pumpWidget(const IslamicCompanionApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.mosque), findsOneWidget);
    expect(find.text('الفجر'), findsOneWidget);
    expect(find.text('الظهر'), findsOneWidget);
    expect(find.text('العصر'), findsOneWidget);
    expect(find.text('المغرب'), findsOneWidget);
    expect(find.text('العشاء'), findsOneWidget);
  });
}
