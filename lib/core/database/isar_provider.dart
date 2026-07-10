import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar_plus/isar_plus.dart';
import 'package:path_provider/path_provider.dart';

import 'schemas.dart';

/// Isar 实例 Provider —— 阶段 2.1 引入。
///
/// 在 main.dart 中通过 `await container.read(isarProvider.future)` 预热，
/// 确保 Isar 初始化完成后才 runApp；后续仓库 Provider 直接 `ref.watch(isarProvider)`
/// 即可拿到非空 Isar 实例。
///
/// isar_plus 的 `Isar.open` 为同步 API（返回 Isar），但获取应用文档目录是 async，
/// 故仍用 FutureProvider 包装。
///
/// Schema migration: 2026-07-09 removed StorageZone enum + zone field from FridgeItem.
/// isar_plus 不自动处理 column drop。从老版本升级时 schema hash  mismatch → 清空冰箱数据
/// 重建 DB（冰箱数据可重录，spec 允许降级到全量清空）。
final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  try {
    return Isar.open(
      schemas: schemas,
      directory: dir.path,
      inspector: true,
    );
  } catch (e) {
    // Schema mismatch — delete and recreate DB ponytail: 首次 schema 改动降级
    final dbName = 'default.isar';
    final dbFile = File('${dir.path}/$dbName');
    final lockFile = File('${dir.path}/$dbName.lock');
    try { if (dbFile.existsSync()) dbFile.deleteSync(); } catch (_) {}
    try { if (lockFile.existsSync()) lockFile.deleteSync(); } catch (_) {}
    return Isar.open(
      schemas: schemas,
      directory: dir.path,
      inspector: true,
    );
  }
});
