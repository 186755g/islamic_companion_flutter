import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';

import 'package:islamic_companion/data/azkar_data.dart';
import 'package:islamic_companion/providers/azkar_provider.dart';
import 'package:islamic_companion/screens/azkar_screen.dart';
import 'package:islamic_companion/services/storage_service.dart';

void main() {
  testWidgets('azkar navigation stays responsive and preserves count updates',
      (WidgetTester tester) async {
    final storageDirectory = await tester.runAsync(
      () => Directory.systemTemp.createTemp('azkar-screen-test-'),
    );
    await tester.runAsync(() async {
      Hive.init(storageDirectory!.path);
      await Hive.openBox(StorageService.azkarBox);
    });
    addTearDown(() async {
      await tester.runAsync(() async {
        await Hive.close();
        await storageDirectory!.delete(recursive: true);
      });
    });

    final provider = AzkarProvider();
    final total = AzkarData.morningAzkar().length;
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AzkarProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: AzkarScreen()),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));

    final firstCard = find
        .ancestor(
          of: find.textContaining('آية الكرسي - البقرة 255. من قالها حين يصبح'),
          matching: find.byType(Card),
        )
        .first;
    final listView = find
        .ancestor(
          of: firstCard,
          matching: find.byType(ListView),
        )
        .first;
    final counter = find
        .ancestor(
          of: find.descendant(
            of: firstCard,
            matching: find.text('متبقي'),
          ),
          matching: find.byType(InkWell),
        )
        .first;
    await tester.drag(listView, const Offset(0, -600));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.tap(counter);
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 400));

    expect(provider.morning.first.currentCount, 1);
    expect(StorageService.getZikrCount('m1'), 1);
    expect(find.byIcon(Icons.check_rounded), findsOneWidget);

    final nextButton = find
        .descendant(
          of: firstCard,
          matching: find.text('التالي'),
        )
        .first;
    final scrollController =
        tester.widget<ListView>(listView).controller! as ScrollController;
    final offsetBeforeNext = scrollController.offset;
    final nextAction = tester
        .widget<FilledButton>(
          find
              .ancestor(
                of: nextButton,
                matching: find.byType(FilledButton),
              )
              .first,
        )
        .onPressed!;
    nextAction();
    nextAction();
    await tester.pump(const Duration(milliseconds: 400));

    final offsetAfterNext = scrollController.offset;
    expect(offsetAfterNext, greaterThan(offsetBeforeNext));
    expect(tester.takeException(), isNull);

    await tester.drag(
      listView,
      const Offset(0, 400),
    );
    await tester.pump(const Duration(milliseconds: 400));
    expect(scrollController.offset, lessThan(offsetAfterNext));
    expect(tester.takeException(), isNull);
  });
}
