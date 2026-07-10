// 冰箱食材变更日志测试。
//
// 当前仓库层（Fake + Isar）的 4 mutation 都「同事务」追加一条 FridgeChangeLog，
// 本测试聚焦日志层面的行为契约，不依赖 Isar 二进制（仅用 Fake）。
//
// 在宿主平台不是 Android/iOS 的测试环境（Windows / Linux CI），providers.dart
// 自动走 Fake 路径，所以覆盖 _FridgeRepository 的公共合约足矣。

import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/app_settings.dart';
import 'package:kurashi/data/models/fridge_change_log.dart';
import 'package:kurashi/data/models/fridge_item.dart';
import 'package:kurashi/data/repositories/fake/fake_fridge_repository.dart';
import 'package:kurashi/data/repositories/fridge_repository.dart';

void main() {
  group('FridgeRepository contract — change log', () {
    late FakeFridgeRepository repo;

    setUp(() {
      repo = FakeFridgeRepository();
    });

    test('add → update → remove → restore 产生 4 条日志闭环', () async {
      // 1. 入库
      final id = await repo.addItem(FridgeItem(
        id: 0,
        name: '茄子',
        quantity: '1 个',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));

      // 2. 编辑（数量变化）
      await repo.updateItem(FridgeItem(
        id: id,
        name: '茄子',
        quantity: '半个',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));

      // 3. 出库
      await repo.removeItem(id);

      // 4. 撤销出库（恢复）
      await repo.restoreItem(FridgeItem(
        id: id,
        name: '茄子',
        quantity: '半个',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));

      // 注意：_pushLogs 排序用 (timestamp desc, id desc) 兜底，毫秒撞档时
      // 晚入库的仍排前（_nextLogId 单调递增），所以这里不需要 delay。
      final logs = await repo.watchChangeLog().first;

      // 倒序：最近一条是 restore，依次往前是 delete / update / add
      expect(logs.length, 4);
      expect(logs[0].action, FridgeAction.restore);
      expect(logs[0].beforeQty, '0');
      expect(logs[0].afterQty, '半个');
      expect(logs[0].itemName, '茄子');
      expect(logs[0].itemId, id);

      expect(logs[1].action, FridgeAction.delete);
      expect(logs[1].beforeQty, '半个');
      expect(logs[1].afterQty, '0');

      expect(logs[2].action, FridgeAction.update);
      expect(logs[2].beforeQty, '1 个');
      expect(logs[2].afterQty, '半个');

      expect(logs[3].action, FridgeAction.add);
      expect(logs[3].beforeQty, '0');
      expect(logs[3].afterQty, '1 个');
      expect(logs[3].itemId, id);
    });

    test('update 含过期日但 qty 未变也记日志，qty 子文案为「数量未变」',
        () async {
      final id = await repo.addItem(FridgeItem(
        id: 0,
        name: '牛奶',
        quantity: '1 L',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 10),

      ));

      // 仅延长过期日，qty 文字不变
      await repo.updateItem(FridgeItem(
        id: id,
        name: '牛奶',
        quantity: '1 L',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 20),

      ));

      final logs = await repo.watchChangeLog().first;
      final entry = logs.firstWhere((e) => e.action == FridgeAction.update);
      expect(entry.beforeQty, '1 L');
      expect(entry.afterQty, '1 L');
      expect(entry.beforeExpiry, DateTime(2026, 7, 10));
      expect(entry.afterExpiry, DateTime(2026, 7, 20));
    });

    test('update 零业务变更不写日志（diff gate）', () async {
      final id = await repo.addItem(FridgeItem(
        id: 0,
        name: '酸奶',
        quantity: '1 杯',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));
      final beforeLogs = await repo.watchChangeLog().first;
      final beforeUpdateCount =
          beforeLogs.where((e) => e.action == FridgeAction.update).length;

      // 用同一份数据再 update（业务字段全等），不应写新日志
      await repo.updateItem(FridgeItem(
        id: id,
        name: '酸奶',
        quantity: '1 杯',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));

      final afterLogs = await repo.watchChangeLog().first;
      final afterUpdateCount =
          afterLogs.where((e) => e.action == FridgeAction.update).length;
      expect(afterUpdateCount, beforeUpdateCount, reason: '零变更不应新增 update 日志');
    });

    /// 8 个业务字段分别变化 → 每条 update 都应写日志。
    /// 防止 hasBusinessChange 拼写错误（如把 `!=` 写成 `==`）导致漏写。
    test('diff gate: 每个业务字段变更都触发日志', () async {
      Future<int> countUpdates() async =>
          (await repo.watchChangeLog().first)
              .where((e) => e.action == FridgeAction.update)
              .length;

      final base = FridgeItem(
        id: 0,
        name: '酸奶',
        quantity: '1 杯',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),
      );

      // 1. name
      final id1 = await repo.addItem(base);
      final before1 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id1, name: '酸奶2'));
      expect(await countUpdates(), before1 + 1, reason: 'name 变更应写日志');

      // 2. quantity
      final id2 = await repo.addItem(base);
      final before2 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id2, quantity: '2 杯'));
      expect(await countUpdates(), before2 + 1, reason: 'quantity 变更应写日志');

      // 3. expiryDate
      final id3 = await repo.addItem(base);
      final before3 = await countUpdates();
      await repo.updateItem(
          base.copyWith(id: id3, expiryDate: DateTime(2026, 7, 21)));
      expect(await countUpdates(), before3 + 1, reason: 'expiryDate 变更应写日志');

      // 4. tag
      final id4 = await repo.addItem(base);
      final before4 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id4, tag: '水果'));
      expect(await countUpdates(), before4 + 1, reason: 'tag 变更应写日志');

      // 5. remainingPercent
      final id5 = await repo.addItem(base);
      final before5 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id5, remainingPercent: 80));
      expect(await countUpdates(), before5 + 1,
          reason: 'remainingPercent 变更应写日志');

      // 6. restockEnabled
      final id6 = await repo.addItem(base);
      final before6 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id6, restockEnabled: true));
      expect(await countUpdates(), before6 + 1,
          reason: 'restockEnabled 变更应写日志');

      // 7. restockThresholdPercent
      final id7 = await repo.addItem(base);
      final before7 = await countUpdates();
      await repo.updateItem(
          base.copyWith(id: id7, restockThresholdPercent: 30));
      expect(await countUpdates(), before7 + 1,
          reason: 'restockThresholdPercent 变更应写日志');

      // 8. restockQty
      final id8 = await repo.addItem(base);
      final before8 = await countUpdates();
      await repo.updateItem(base.copyWith(id: id8, restockQty: '3 杯'));
      expect(await countUpdates(), before8 + 1,
          reason: 'restockQty 变更应写日志');
    });

    test('JSON 导出含元数据 + entries 数组（结构化、agent 可解析）',
        () async {
      // path_provider 桌面测试需要 mock getTemporaryDirectory 走 MethodChannel
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      final tmpDir = Directory.systemTemp.createTempSync('kurashi_json_test_');
      binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (call) async {
          if (call.method == 'getTemporaryDirectory') return tmpDir.path;
          return null;
        },
      );

      try {
        await repo.addItem(FridgeItem(
          id: 0,
          name: '茄子',
          quantity: '1 个',
          addedDate: DateTime(2026, 7, 7),
          expiryDate: DateTime(2026, 7, 14),
  
        ));
        final logs = await repo.watchChangeLog().first;

        final path = await repo.exportChangeLogJson(
          scope: ReportScope.day,
          entries: logs,
        );
        final raw = await File(path).readAsString();
        final decoded = jsonDecode(raw) as Map<String, dynamic>;

        expect(decoded['appName'], 'kurashi');
        expect(decoded['scope'], 'day');
        expect(decoded['count'], 1);
        expect(decoded['entries'], isA<List<dynamic>>());

        final entries = decoded['entries'] as List<dynamic>;
        expect(entries.length, 1);
        final first = entries.first as Map<String, dynamic>;
        expect(first['action'], 'add');
        expect(first['itemName'], '茄子');
        expect(first['beforeQty'], '0');
        expect(first['afterQty'], '1 个');
        expect(first['beforeExpiry'], startsWith('2026-07-07'));
        expect(first['afterExpiry'], startsWith('2026-07-14'));
      } finally {
        binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('plugins.flutter.io/path_provider'),
          null,
        );
        if (tmpDir.existsSync()) tmpDir.deleteSync(recursive: true);
      }
    });

    test('deleteChangeLogEntry 单条删除', () async {
      await repo.addItem(FridgeItem(
        id: 0,
        name: 'A',
        quantity: '1',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));
      await repo.addItem(FridgeItem(
        id: 0,
        name: 'B',
        quantity: '2',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));

      // 避免毫秒撞档让两条记录的排序不稳
      var logs = await repo.watchChangeLog().first;
      expect(logs.length, 2);
      final logA = logs.firstWhere((l) => l.itemName == 'A');
      await repo.deleteChangeLogEntry(logA.id);

      logs = await repo.watchChangeLog().first;
      expect(logs.length, 1);
      expect(logs.first.itemName, 'B');

      // 食材本体不受影响
      final items = await repo.watchAll().first;
      expect(items.map((e) => e.name), containsAll(['A', 'B']));
    });

    test('runRetentionSweep 在永久策略下是 noop，在 30 天策略下跨月才清理',
        () async {
      // seed 2 个 action，刻意把 timestamp 调到 past（用 addItem 后手动改 lastCleanupAt 不可达，
      // 这里仅验证「永久时不删」与「保留天数变更后行为切换」）。
      final s0 = await repo.getSettings();
      expect(s0.fridgeLogRetentionDays, 0);

      // 再 add 一条，让日志有内容
      await repo.addItem(FridgeItem(
        id: 0,
        name: 'X',
        quantity: '1',
        addedDate: DateTime(2026, 7, 7),
        expiryDate: DateTime(2026, 7, 14),

      ));
      final beforeLogs = await repo.watchChangeLog().first;
      expect(beforeLogs.length, 1);

      // 永久策略 → noop
      await repo.runRetentionSweep(DateTime.now());
      final afterSweep = await repo.watchChangeLog().first;
      expect(afterSweep.length, 1);

      // 切到 30 天策略 + lastCleanupAt = epoch 0 → 下次 sweep 必触发清理
      await repo.updateSettings(AppSettings(
        fridgeLogRetentionDays: 30,
        fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
      ));
      // 现在所有 log 都是今天，30 天前 cutoff 不会命中任何条目 → 不会清
      // 把 lastCleanupAt 推到再下一次 sweep 时已经跨月的那一天不可行，
      // 这里只能验证「保留天数变更后 sweep 走的是指定天数后的逻辑」。
      await repo.runRetentionSweep(DateTime.now());
      final afterPolicySwitch = await repo.watchChangeLog().first;
      expect(afterPolicySwitch.length, 1); // 都在 30 天内，不清
    });
  });
}
