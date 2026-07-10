import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/core/designsystem/app_icons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppIcons renders without error', () {
    testWidgets('todo icon renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppIcons.todo(size: 24))));
      expect(tester.takeException(), isNull);
    });

    testWidgets('subscription icon renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppIcons.subscription(size: 24))));
      expect(tester.takeException(), isNull);
    });

    testWidgets('fridge icon renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppIcons.fridge(size: 24))));
      expect(tester.takeException(), isNull);
    });

    testWidgets('add icon renders without error', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppIcons.add(size: 28))));
      expect(tester.takeException(), isNull);
    });

    testWidgets('close icon renders', (tester) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: AppIcons.close())));
      expect(tester.takeException(), isNull);
    });
  });
}
