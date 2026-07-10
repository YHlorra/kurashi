import 'dart:convert';
import 'dart:io';

import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/app_settings.dart';
import '../../models/fridge_change_log.dart';
import '../../models/fridge_item.dart';
import '../fridge_repository.dart';

/// 冰箱仓库的 Isar 实现（阶段 2.1 替换 FakeFridgeRepository；阶段 2.x 增加变更日志）。
///
/// 4 个 mutation（addItem / updateItem / removeItem / restoreItem）都包在
/// `isar.write((isar) => ...)` 中，与 FridgeChangeLog 写入原子。
/// 异常由 Isar 自动回滚（write txn 失败不会留下半成品）。
class IsarFridgeRepository implements FridgeRepository {
  final Isar isar;

  IsarFridgeRepository(this.isar);

  // ── Stream ───────────────────────────────────────────────────────────

  @override
  Stream<List<FridgeItem>> watchAll() {
    return isar.fridgeItems
        .watchLazy(fireImmediately: true)
        .map((_) => isar.fridgeItems.where().findAll());
  }

  @override
  Stream<List<FridgeChangeLog>> watchChangeLog() {
    return isar.fridgeChangeLogs
        .watchLazy(fireImmediately: true)
        .map((_) {
      // 倒序：Dart 层排序（未建 timestamp 索引；行数小，性能可接受）。
      // 二次按 id 降序做 stable tie-break——毫秒级 DateTime.now() 撞档时
      // 保证晚入库的排在前面。
      final all = isar.fridgeChangeLogs.where().findAll();
      all.sort((a, b) {
        final c = b.timestamp.compareTo(a.timestamp);
        if (c != 0) return c;
        return b.id.compareTo(a.id);
      });
      return all;
    });
  }

  @override
  Stream<AppSettings> watchSettings() {
    final defaultSettings = AppSettings(
      fridgeLogRetentionDays: 0,
      fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
    );
    return isar.appSettings
        .watchLazy(fireImmediately: true)
        .map((_) => isar.appSettings.get(0) ?? defaultSettings);
  }

  // ── Mutations（事务 + 日志）────────────────────────────────────────

  @override
  Future<int> addItem(FridgeItem item) async {
    return isar.write((isar) {
      final newId =
          item.id == 0 ? isar.fridgeItems.autoIncrement() : item.id;
      final saved = item.copyWith(id: newId);
      isar.fridgeItems.put(saved);
      // ponytail: 显式 autoIncrement + put。
      // isar_plus 1.3.7 的 put 对 id=0 没有保证 auto-increment（社区 fork
      // 语义模糊），实测会把 4 条日志都覆盖到 id=0 上，结果只剩最后一条。
      // 与 FridgeItem 同步路径，预先 autoIncrement 再 put。
      isar.fridgeChangeLogs.put(FridgeChangeLog(
        id: isar.fridgeChangeLogs.autoIncrement(),
        itemId: newId,
        itemName: saved.name,
        timestamp: DateTime.now(),
        action: FridgeAction.add,
        beforeQty: '0',
        afterQty: saved.quantity,
        beforeExpiry: saved.addedDate,
        afterExpiry: saved.expiryDate,
      ));
      return newId;
    });
  }

  @override
  Future<void> updateItem(FridgeItem item) async {
    // Isar put 为 upsert；现有 updateItem 无「old 不存在则跳过」语义，
    // 这里加 if (old == null) return 是为了不让日志凭空冒出 -1 引用。
    // diff gate：业务字段无变化则跳过整个 writeTxn（不写 Isar、不写日志）。
    isar.write((isar) {
      final old = isar.fridgeItems.get(item.id);
      if (old == null) return;
      if (!old.hasBusinessChange(item)) return;
      isar.fridgeItems.put(item);
      isar.fridgeChangeLogs.put(FridgeChangeLog(
        id: isar.fridgeChangeLogs.autoIncrement(),
        itemId: item.id,
        itemName: item.name,
        timestamp: DateTime.now(),
        action: FridgeAction.update,
        beforeQty: old.quantity,
        afterQty: item.quantity,
        beforeExpiry: old.expiryDate,
        afterExpiry: item.expiryDate,
      ));
    });
  }

  @override
  Future<void> removeItem(int id) async {
    isar.write((isar) {
      final old = isar.fridgeItems.get(id);
      if (old == null) return;
      isar.fridgeItems.delete(id);
      // 硬删后写日志：日志保留，UI 可正常展示「茄子 半袋 → 0」历史
      isar.fridgeChangeLogs.put(FridgeChangeLog(
        id: isar.fridgeChangeLogs.autoIncrement(),
        itemId: id,
        itemName: old.name,
        timestamp: DateTime.now(),
        action: FridgeAction.delete,
        beforeQty: old.quantity,
        afterQty: '0',
        beforeExpiry: old.expiryDate,
        afterExpiry: old.expiryDate,
      ));
    });
  }

  @override
  Future<void> restoreItem(FridgeItem item) async {
    // restoreItem 由 UI 端（toast 撤销）调用，item 已带 id，直接 upsert。
    // 日志：beforeQty="0"（撤之前曾出库）afterQty=item.quantity。
    isar.write((isar) {
      isar.fridgeItems.put(item);
      isar.fridgeChangeLogs.put(FridgeChangeLog(
        id: isar.fridgeChangeLogs.autoIncrement(),
        itemId: item.id,
        itemName: item.name,
        timestamp: DateTime.now(),
        action: FridgeAction.restore,
        beforeQty: '0',
        afterQty: item.quantity,
        beforeExpiry: item.addedDate,
        afterExpiry: item.expiryDate,
      ));
    });
  }

  // ── 历史/导出 ───────────────────────────────────────────────────────

  @override
  Future<void> deleteChangeLogEntry(int id) async {
    isar.write((isar) {
      isar.fridgeChangeLogs.delete(id);
    });
  }

  @override
  Future<int> clearChangeLogOlderThan(DateTime cutoff) async {
    return isar.write((isar) {
      final old = isar.fridgeChangeLogs
          .where()
          .timestampLessThan(cutoff)
          .findAll();
      for (final e in old) {
        isar.fridgeChangeLogs.delete(e.id);
      }
      return old.length;
    });
  }

  @override
  Future<String> exportChangeLogJson({
    required ReportScope scope,
    required List<FridgeChangeLog> entries,
  }) async {
    String dateOnly(DateTime d) =>
        DateTime(d.year, d.month, d.day).toIso8601String();

    final json = {
      'exportedAt': DateTime.now().toIso8601String(),
      'appName': 'kurashi',
      'scope': scope.name,
      'count': entries.length,
      'entries': [
        for (final e in entries)
          {
            'id': e.id,
            'itemId': e.itemId,
            'itemName': e.itemName,
            'timestamp': e.timestamp.toIso8601String(),
            'action': e.action.name,
            'beforeQty': e.beforeQty,
            'afterQty': e.afterQty,
            'beforeExpiry': dateOnly(e.beforeExpiry),
            'afterExpiry': dateOnly(e.afterExpiry),
          },
      ],
    };
    const encoder = JsonEncoder.withIndent('  ');
    final content = encoder.convert(json);
    final dir = await getTemporaryDirectory();
    final stamp =
        DateTime.now().toIso8601String().replaceAll(RegExp(r'[^0-9]'), '');
    final file = File('${dir.path}/fridge_log_${scope.name}_$stamp.json');
    await file.writeAsString(content);
    return file.path;
  }

  // ── 应用设置 ────────────────────────────────────────────────────────

  @override
  Future<AppSettings> getSettings() async {
    return isar.write((isar) {
      final s = isar.appSettings.get(0);
      if (s != null) return s;
      // 首次启动 seed 默认值：永久保留 + epoch 0
      final fresh = AppSettings(
        fridgeLogRetentionDays: 0,
        fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
      );
      isar.appSettings.put(fresh);
      return fresh;
    });
  }

  @override
  Future<void> updateSettings(AppSettings settings) async {
    isar.write((isar) {
      isar.appSettings.put(settings);
    });
  }

  @override
  Future<void> runRetentionSweep(DateTime now) async {
    try {
      final s = await getSettings();
      if (s.fridgeLogRetentionDays == 0) return; // 永久
      final cutoff =
          now.subtract(Duration(days: s.fridgeLogRetentionDays));
      final rolled = _hasBucketRolled(
        s.fridgeLogLastCleanupAt,
        now,
        s.fridgeLogRetentionDays,
      );
      if (!rolled) return;
      final n = await clearChangeLogOlderThan(cutoff);
      await updateSettings(s.copyWith(fridgeLogLastCleanupAt: now));
      // ignore: avoid_print
      print('[retention] swept $n fridge log entries older than $cutoff');
    } catch (e) {
      // 清理失败不应阻塞 app 启动
      // ignore: avoid_print
      print('[retention] sweep failed: $e');
    }
  }

  /// 判定跨桶（月/季度）—— 30 天策略看跨月，90 天策略看跨季度。
  static bool _hasBucketRolled(DateTime last, DateTime now, int days) {
    if (last.year == 0) return true; // epoch 0 = 从未清理过，首次跑
    if (days >= 90) {
      final lastQ = (last.month - 1) ~/ 3;
      final nowQ = (now.month - 1) ~/ 3;
      return lastQ != nowQ || last.year != now.year;
    }
    return last.month != now.month || last.year != now.year;
  }

  // ── 补货系统 ──────────────────────────────────────────────────────────

  @override
  Future<void> markAsFinished(int id) async {
    isar.write((isar) {
      final item = isar.fridgeItems.get(id);
      if (item == null) return;
      isar.fridgeItems.put(item.copyWith(remainingPercent: 0));
    });
  }

  @override
  Future<void> updateStockPercent(int id, int percent) async {
    isar.write((isar) {
      final item = isar.fridgeItems.get(id);
      if (item == null) return;
      final clamped = percent.clamp(0, 100);
      isar.fridgeItems.put(item.copyWith(remainingPercent: clamped));
    });
  }

  @override
  Future<List<RestockCandidate>> getRestockCandidates() async {
    return isar.write((isar) {
      final all = isar.fridgeItems.where().findAll();
      final restocked = all.where((i) => i.restockEnabled && i.remainingPercent <= i.restockThresholdPercent).toList();
      restocked.sort((a, b) => a.expiryDate.compareTo(b.expiryDate));
      final groups = <String, List<FridgeItem>>{};
      for (final item in restocked) {
        groups.putIfAbsent(item.name, () => []).add(item);
      }
      return groups.entries.map((e) {
        final batches = e.value;
        final earliest = batches.map((b) => b.expiryDate).reduce((a, b) => a.isBefore(b) ? a : b);
        return RestockCandidate(
          name: e.key,
          restockQty: batches.first.restockQty.isNotEmpty ? batches.first.restockQty : batches.first.quantity,
          batches: batches,
          earliestExpiry: earliest,
        );
      }).toList();
    });
  }
}
