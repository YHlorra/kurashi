// FestivalDetailScreen 分组渲染单测（P8 daily grouping）
//
// 覆盖场景：
//   1. 中国节日（9 项）渲染 section header + 节日行
//   2. 西方节日（6 项）渲染 section header + 节日行
//   3. 无预设类型（生日）渲染空列表
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';
import 'package:kurashi/data/repositories/providers.dart';
import 'package:kurashi/feature/subscription/screens/festival_detail_screen.dart';

void main() {
  group('FestivalDetailScreen daily grouping', () {
    testWidgets('cnFestival (9 presets) renders section headers and rows',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider
                .overrideWithValue(FakeSubscriptionRepository()),
          ],
          child: const MaterialApp(
            home: FestivalDetailScreen(type: SubType.cnFestival),
          ),
        ),
      );
      // 等待 StreamBuilder 的 stream 发射数据
      await tester.pump();

      // 第一个预设 '元旦' 应在可视区域
      expect(find.text('元旦'), findsOneWidget);

      // 至少有一个 section header（日期由 lunarService 动态计算）
      // section header 文本格式为 "M月D日"，13px muted
      final sectionHeaders = find.byWidgetPredicate((widget) {
        if (widget is! Text) return false;
        final data = widget.data ?? '';
        return RegExp(r'^\d+月\d+日$').hasMatch(data) &&
            widget.style?.fontSize == 13 &&
            widget.style?.color == const Color(0xFF707070);
      });
      expect(sectionHeaders, findsAtLeast(1));
    });

    testWidgets('westernFestival (6 presets) renders section headers and rows',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider
                .overrideWithValue(FakeSubscriptionRepository()),
          ],
          child: const MaterialApp(
            home: FestivalDetailScreen(type: SubType.westernFestival),
          ),
        ),
      );
      await tester.pump();

      // 第一个预设 '情人节' 应在可视区域
      expect(find.text('情人节'), findsOneWidget);

      // 至少有一个 section header
      final sectionHeaders2 = find.byWidgetPredicate((widget) {
        if (widget is! Text) return false;
        final data = widget.data ?? '';
        return RegExp(r'^\d+月\d+日$').hasMatch(data) &&
            widget.style?.fontSize == 13 &&
            widget.style?.color == const Color(0xFF707070);
      });
      expect(sectionHeaders2, findsAtLeast(1));
    });

    testWidgets('birthday (no presets) renders empty list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            subscriptionRepositoryProvider
                .overrideWithValue(FakeSubscriptionRepository()),
          ],
          child: const MaterialApp(
            home: FestivalDetailScreen(type: SubType.birthday),
          ),
        ),
      );
      await tester.pump();

      // 无预设，不应有节日行
      expect(find.text('元旦'), findsNothing);
      expect(find.text('春节'), findsNothing);

      // 不应有 section header（M月D日 格式）
      final sectionHeaders3 = find.byWidgetPredicate((widget) {
        if (widget is! Text) return false;
        final data = widget.data ?? '';
        return RegExp(r'^\d+月\d+日$').hasMatch(data) &&
            widget.style?.fontSize == 13 &&
            widget.style?.color == const Color(0xFF707070);
      });
      expect(sectionHeaders3, findsNothing);
    });
  });
}
