import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../models/app_settings.dart';
import '../../models/fridge_change_log.dart';
import '../../models/fridge_item.dart';
import '../fridge_repository.dart';

/// 冰箱仓库的内存实现（阶段 1 mock；阶段 2.1 后桌面/Web 仍用作降级）。
///
/// 行为与 IsarFridgeRepository 一致：4 mutation 同时写 _items 与 _logs 两个列表，
/// 让 UI 在 Fake 模式也能完整跑通历史屏。
class FakeFridgeRepository implements FridgeRepository {
  final _controller = StreamController<List<FridgeItem>>.broadcast();
  final _logController = StreamController<List<FridgeChangeLog>>.broadcast();
  final _settingsController = StreamController<AppSettings>.broadcast();

  final List<FridgeItem> _items;
  final List<FridgeChangeLog> _logs = [];
  int _nextId = 100;

  AppSettings _settings = AppSettings(
    fridgeLogRetentionDays: 0,
    fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  FakeFridgeRepository() : _items = _createMockData() {
    _seedHistoryLogs();
    _settings = AppSettings(
      fridgeLogRetentionDays: 0,
      fridgeLogLastCleanupAt: DateTime.fromMillisecondsSinceEpoch(0),
      settingsJson: '{"fridgeTags":["海鲜","调味"]}',
    );
  }

  void _seedHistoryLogs() {
    final now = DateTime.now();
    _logs.addAll([
      FridgeChangeLog(
        id: 1,
        itemId: 1,
        itemName: '巴氏鲜牛奶',
        timestamp: now.subtract(const Duration(days: 8)),
        action: FridgeAction.add,
        beforeQty: '0',
        afterQty: '1 L',
        beforeExpiry: now.subtract(const Duration(days: 8)),
        afterExpiry: now.subtract(const Duration(days: 1)),
      ),
      FridgeChangeLog(
        id: 2,
        itemId: 3,
        itemName: '切片面包',
        timestamp: now.subtract(const Duration(days: 4)),
        action: FridgeAction.update,
        beforeQty: '1 袋',
        afterQty: '半袋',
        beforeExpiry: now.add(const Duration(days: 5)),
        afterExpiry: now.subtract(const Duration(days: 10)),
      ),
      FridgeChangeLog(
        id: 3,
        itemId: 5,
        itemName: '西红柿',
        timestamp: now.subtract(const Duration(days: 2)),
        action: FridgeAction.add,
        beforeQty: '0',
        afterQty: '3 个',
        beforeExpiry: now.subtract(const Duration(days: 2)),
        afterExpiry: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  static List<FridgeItem> _createMockData() {
    return [
      FridgeItem(
        id: 1,
        name: '巴氏鲜牛奶',
        quantity: '1 L',
        addedDate: DateTime(2026, 6, 25),
        expiryDate: DateTime(2026, 7, 2),
        tag: '蔬菜',
      ),
      FridgeItem(
        id: 2,
        name: '菠菜',
        quantity: '1 把',
        addedDate: DateTime(2026, 6, 27),
        expiryDate: DateTime(2026, 7, 3),
        tag: '蔬菜',
      ),
      FridgeItem(
        id: 3,
        name: '切片面包',
        quantity: '半袋',
        addedDate: DateTime(2026, 6, 22),
        expiryDate: DateTime(2026, 6, 29),
        tag: '调味',
      ),
      FridgeItem(
        id: 4,
        name: '土鸡蛋',
        quantity: '8 枚',
        addedDate: DateTime(2026, 6, 20),
        expiryDate: DateTime(2026, 7, 13),
        tag: '蔬菜',
      ),
      FridgeItem(
        id: 5,
        name: '西红柿',
        quantity: '3 个',
        addedDate: DateTime(2026, 6, 26),
        expiryDate: DateTime(2026, 7, 6),
        tag: '蔬菜',
      ),
      FridgeItem(
        id: 6,
        name: '猪里脊',
        quantity: '400 g',
        addedDate: DateTime(2026, 6, 28),
        expiryDate: DateTime(2026, 7, 3),
        tag: '肉类',
      ),
    ];
  }

  // ── Item Stream ──────────────────────────────────────────────────────

  @override
  Stream<List<FridgeItem>> watchAll() {
    Future.microtask(() => _controller.add(List.unmodifiable(_items)));
    return _controller.stream;
  }

  void _pushItems() => _controller.add(List.unmodifiable(_items));

  // ── Log Stream ───────────────────────────────────────────────────────

  @override
  Stream<List<FridgeChangeLog>> watchChangeLog() {
    Future.microtask(() {
      final sorted = _logsSortedDesc();
      _logController.add(List.unmodifiable(sorted));
    });
    return _logController.stream;
  }

  void _pushLogs() {
    final sorted = _logsSortedDesc();
    _logController.add(List.unmodifiable(sorted));
  }

  /// ponytail: List.sort 不稳定，相邻 _appendLog 在 Windows 上 DateTime.now()
  /// 可能撞档（毫秒级精度），需用 id 兜底保持稳定降序——晚进先出。
  List<FridgeChangeLog> _logsSortedDesc() {
    final list = List<FridgeChangeLog>.from(_logs);
    list.sort((a, b) {
      final c = b.timestamp.compareTo(a.timestamp);
      if (c != 0) return c;
      return b.id.compareTo(a.id);
    });
    return list;
  }

  // ── Settings Stream ──────────────────────────────────────────────────

  @override
  Stream<AppSettings> watchSettings() {
    Future.microtask(() => _settingsController.add(_settings));
    return _settingsController.stream;
  }

  void _pushSettings() => _settingsController.add(_settings);

  // ── Mutations（事务 + 日志：Fake 中按顺序依次 push controllers） ───

  void _appendLog(FridgeChangeLog entry) {
    _logs.add(entry);
    _pushLogs();
  }

  int _nextLogId() => _logs.isEmpty
      ? 1
      : _logs.map((e) => e.id).reduce((a, b) => a > b ? a : b) + 1;

  @override
  Future<int> addItem(FridgeItem item) async {
    final newItem = item.id == 0 ? item.copyWith(id: _nextId++) : item;
    _items.add(newItem);
    _appendLog(FridgeChangeLog(
      id: _nextLogId(),
      itemId: newItem.id,
      itemName: newItem.name,
      timestamp: DateTime.now(),
      action: FridgeAction.add,
      beforeQty: '0',
      afterQty: newItem.quantity,
      beforeExpiry: newItem.addedDate,
      afterExpiry: newItem.expiryDate,
    ));
    _pushItems();
    return newItem.id;
  }

  @override
  Future<void> updateItem(FridgeItem item) async {
    final idx = _items.indexWhere((e) => e.id == item.id);
    if (idx == -1) return;
    final old = _items[idx];
    // diff gate：业务字段无变化则跳过（不写日志、不 push stream）
    // 避免打开编辑 sheet 不改东西点保存时凭空冒一条 update 日志。
    if (!old.hasBusinessChange(item)) return;
    _items[idx] = item;
    _appendLog(FridgeChangeLog(
      id: _nextLogId(),
      itemId: item.id,
      itemName: item.name,
      timestamp: DateTime.now(),
      action: FridgeAction.update,
      beforeQty: old.quantity,
      afterQty: item.quantity,
      beforeExpiry: old.expiryDate,
      afterExpiry: item.expiryDate,
    ));
    _pushItems();
  }

  @override
  Future<void> removeItem(int id) async {
    final old = _items.firstWhere(
      (e) => e.id == id,
      orElse: () => FridgeItem(
        id: 0,
        name: '',
        quantity: '',
        addedDate: DateTime.fromMillisecondsSinceEpoch(0),
        expiryDate: DateTime.fromMillisecondsSinceEpoch(0),
      ),
    );
    _items.removeWhere((e) => e.id == id);
    if (old.id == 0) return; // 没找到，不写日志
    _appendLog(FridgeChangeLog(
      id: _nextLogId(),
      itemId: id,
      itemName: old.name,
      timestamp: DateTime.now(),
      action: FridgeAction.delete,
      beforeQty: old.quantity,
      afterQty: '0',
      beforeExpiry: old.expiryDate,
      afterExpiry: old.expiryDate,
    ));
    _pushItems();
  }

  @override
  Future<void> restoreItem(FridgeItem item) async {
    _items.add(item);
    _appendLog(FridgeChangeLog(
      id: _nextLogId(),
      itemId: item.id,
      itemName: item.name,
      timestamp: DateTime.now(),
      action: FridgeAction.restore,
      beforeQty: '0',
      afterQty: item.quantity,
      beforeExpiry: item.addedDate,
      afterExpiry: item.expiryDate,
    ));
    _pushItems();
  }

  // ── 历史/导出 ────────────────────────────────────────────────────────

  @override
  Future<void> deleteChangeLogEntry(int id) async {
    _logs.removeWhere((e) => e.id == id);
    _pushLogs();
  }

  @override
  Future<int> clearChangeLogOlderThan(DateTime cutoff) async {
    final removed = _logs.where((e) => e.timestamp.isBefore(cutoff)).toList();
    _logs.removeWhere((e) => e.timestamp.isBefore(cutoff));
    if (removed.isNotEmpty) _pushLogs();
    return removed.length;
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
  Future<AppSettings> getSettings() async => _settings;

  @override
  Future<void> updateSettings(AppSettings settings) async {
    _settings = settings;
    _pushSettings();
  }

  @override
  Future<void> runRetentionSweep(DateTime now) async {
    try {
      if (_settings.fridgeLogRetentionDays == 0) return;
      final cutoff = now.subtract(
        Duration(days: _settings.fridgeLogRetentionDays),
      );
      final rolled = _hasBucketRolled(
        _settings.fridgeLogLastCleanupAt,
        now,
        _settings.fridgeLogRetentionDays,
      );
      if (!rolled) return;
      final n = await clearChangeLogOlderThan(cutoff);
      await updateSettings(_settings.copyWith(fridgeLogLastCleanupAt: now));
      // ignore: avoid_print
      print('[retention] swept $n fridge log entries older than $cutoff');
    } catch (e) {
      // ignore: avoid_print
      print('[retention] sweep failed: $e');
    }
  }

  static bool _hasBucketRolled(DateTime last, DateTime now, int days) {
    if (last.year == 0) return true;
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
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    _items[idx] = _items[idx].copyWith(remainingPercent: 0);
    _pushItems();
  }

  @override
  Future<void> updateStockPercent(int id, int percent) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx == -1) return;
    final clamped = percent.clamp(0, 100);
    _items[idx] = _items[idx].copyWith(remainingPercent: clamped);
    _pushItems();
  }

  @override
  Future<List<RestockCandidate>> getRestockCandidates() async {
    final restocked = _items.where((i) => i.restockEnabled && i.remainingPercent <= i.restockThresholdPercent).toList();
    restocked.sort((a, b) {
      final aExp = a.expiryDate;
      final bExp = b.expiryDate;
      return aExp.compareTo(bExp);
    });
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
  }
}
