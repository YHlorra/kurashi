import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_icon_park/flutter_icon_park.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:kurashi/core/designsystem/app_icons.dart';

/// Icon size contract tests.
///
/// Verifies that every AppIcons entry renders a SvgPicture at the expected
/// size. IconPark wraps SvgPicture.string() with width/height set from our
/// `size:` parameter — we detect SvgPicture and read its dimensions.
void main() {
  // ─── Direct AppIcons size tests ──────────────────────────────────────

  group('AppIcons size contract', () {
    // Each entry: (builder, expectedSize)
    final cases = <(Widget Function(), double)>[
      // Navigation (24 default)
      (() => AppIcons.todo(), 24),
      (() => AppIcons.subscription(), 24),
      (() => AppIcons.fridge(), 24),
      // FAB add (24 default, strokeWidth 2.5)
      (() => AppIcons.add(), 24),
      // Common actions
      (() => AppIcons.more(), 24),
      (() => AppIcons.close(), 18),
      (() => AppIcons.setting(), 22),
      (() => AppIcons.share(), 22),
      (() => AppIcons.history(), 22),
      (() => AppIcons.edit(), 16),
      (() => AppIcons.delete(), 16),
      (() => AppIcons.restore(), 16),
      (() => AppIcons.right(), 16),
      (() => AppIcons.check(), 14),
      // Subscription category tiles (24)
      (() => AppIcons.cnFestival(), 24),
      (() => AppIcons.westernFestival(), 24),
      (() => AppIcons.home(), 24),
      (() => AppIcons.pet(), 24),
      (() => AppIcons.document(), 24),
      (() => AppIcons.health(), 24),
      (() => AppIcons.vehicle(), 24),
      (() => AppIcons.birthday(), 24),
      (() => AppIcons.bill(), 24),
      (() => AppIcons.custom(), 24),
      // Todo types (24 default, but used at 20 in context)
      (() => AppIcons.todoType(), 24),
      (() => AppIcons.habit(), 24),
      (() => AppIcons.event(), 24),
      // History action meta (16)
      (() => AppIcons.actionAdd(), 16),
      (() => AppIcons.actionEdit(), 16),
      (() => AppIcons.actionDelete(), 16),
      (() => AppIcons.actionRestore(), 16),
    ];

    for (final (builder, expectedSize) in cases) {
      testWidgets('icon renders at size=$expectedSize', (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: builder(),
            ),
          ),
        );

        final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(svg.width, expectedSize,
            reason: 'width should be $expectedSize');
        expect(svg.height, expectedSize,
            reason: 'height should be $expectedSize');
      });
    }
  });

  group('AppIcons custom size override', () {
    testWidgets('todo(size: 32) renders at 32', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppIcons.todo(size: 32)),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 32);
      expect(svg.height, 32);
    });

    testWidgets('add(size: 28) renders at 28', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppIcons.add(size: 28)),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 28);
      expect(svg.height, 28);
    });

    testWidgets('check(size: 14) renders at 14', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: AppIcons.check(size: 14)),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 14);
      expect(svg.height, 14);
    });
  });

  group('AppIcons color passthrough', () {
    testWidgets('IconTheme color does not break rendering', (WidgetTester tester) async {
      // IconPark reads IconTheme.color and bakes it into the SVG stroke attributes.
      // Verify the icon still renders at the correct size when wrapped in IconTheme.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: IconTheme(
              data: const IconThemeData(color: Color(0xFFFF0000)),
              child: AppIcons.todo(),
            ),
          ),
        ),
      );

      final svg = tester.widget<SvgPicture>(find.byType(SvgPicture));
      expect(svg.width, 24);
      expect(svg.height, 24);
    });
  });

  group('AppIcons package structure', () {
    test('outline() method exists and produces SvgPicture', () {
      // Verify icon names actually exist in the package.
      expect(() => IconPark.checkOne.outline(size: 24), returnsNormally);
      expect(() => IconPark.bill.outline(size: 24), returnsNormally);
      expect(() => IconPark.box.outline(size: 24), returnsNormally);
      expect(() => IconPark.dog.outline(size: 24), returnsNormally);
      expect(() => IconPark.time.outline(size: 24), returnsNormally);
    });
  });
}
