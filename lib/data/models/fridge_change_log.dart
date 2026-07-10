import 'package:isar_plus/isar_plus.dart';

part 'fridge_change_log.g.dart';

/// 冰箱食材变更动作。
///
/// 阶段 2.x：4 个 mutation 各对应一种 action（add/update/delete/restore）。
/// 枚举由 isar_plus 自动按 index 序列化。
enum FridgeAction {
  add, // 入库
  update, // 编辑（数量 / 名称 / 过期日 任意字段变化）
  delete, // 出库（长按 → 仓库移除）
  restore, // 撤销出库（toast 2.4s 窗口内的 undo）
}

/// 冰箱食材变更日志。
///
/// 阶段 2.x：每次 [FridgeRepository] 的 addItem / updateItem / removeItem /
/// restoreItem 都在同一个 `isar.writeTxn` 内既改数据又落一行本 collection，
/// 满足 V1 「数据与日志同生同灭」的原子性。
///
/// 倒序拉取按 timestamp 索引；itemId 给「按食材聚合」下版留口子。
@collection
class FridgeChangeLog {
  final int id;

  /// 食材 id。食材被硬删后仍指向原 id；历史屏展示时不影响可读性。
  final int itemId;

  /// 食材名称快照——食材重命名 / 硬删后仍可读。
  final String itemName;

  final DateTime timestamp;

  final FridgeAction action;

  /// 数量前。add / restore 写 `"0"`；update / delete 写旧 quantity。
  final String beforeQty;

  /// 数量后。delete 写 `"0"`；add / update / restore 写新 quantity。
  final String afterQty;

  /// 过期日前。add / restore 用 `addedDate`；update / delete 用旧 expiry。
  final DateTime beforeExpiry;

  /// 过期日后。
  final DateTime afterExpiry;

  const FridgeChangeLog({
    this.id = 0,
    required this.itemId,
    required this.itemName,
    required this.timestamp,
    required this.action,
    required this.beforeQty,
    required this.afterQty,
    required this.beforeExpiry,
    required this.afterExpiry,
  });
}
