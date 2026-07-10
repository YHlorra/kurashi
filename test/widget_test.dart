// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kurashi/app.dart';
import 'package:kurashi/data/repositories/providers.dart';
import 'package:kurashi/data/repositories/fake/fake_todo_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_habit_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';
import 'package:kurashi/data/repositories/fake/fake_fridge_repository.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          todoRepositoryProvider.overrideWithValue(FakeTodoRepository()),
          habitRepositoryProvider.overrideWithValue(FakeHabitRepository()),
          subscriptionRepositoryProvider.overrideWithValue(FakeSubscriptionRepository()),
          fridgeRepositoryProvider.overrideWithValue(FakeFridgeRepository()),
        ],
        child: const KurashiApp(),
      ),
    );

    // 验证应用启动成功
    expect(find.text('Todo'), findsOneWidget);
  });
}
