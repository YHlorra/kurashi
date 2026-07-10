import '../models/app_settings.dart';
import '../models/fridge_change_log.dart';
import '../models/fridge_item.dart';

/// 补货候选 — 按 name 聚合后的购物清单项
///
/// ponytail: lives here because only FridgeRepository uses it. No separate file needed.
class RestockCandidate {
  final String name;
  final String restockQty;
  final List<FridgeItem> batches;
  final DateTime? earliestExpiry;

  const RestockCandidate({
    required this.name,
    required this.restockQty,
    required this.batches,
    this.earliestExpiry,
  });
}

/// 仓库导出的报表维度。影响 SegmentedControl 选中和 JSON 导出文件名。
enum ReportScope { day, week, month, all }

/// 冰箱仓库抽象接口。
///
/// 阶段 2.x：4 个 mutation（add/update/remove/restore）在实现层都要写一条
/// FridgeChangeLog，且同一个 writeTxn 内提交——保证数据与日志同生同灭。
/// 应用设置（保留策略）也由本抽象承载（避免新增 SettingsRepository）。
abstract class FridgeRepository {
  /// 食材流（Isar lazy stream）。
  Stream<List<FridgeItem>> watchAll();

  // ── Mutation（每个 mutation 内部必须追加一条 FridgeChangeLog，写入同一事务）
  /// 新增食材，返回分配后的 id（用于通知调度）。
  Future<int> addItem(FridgeItem item);

  /// 更新食材（任何字段变化都视为 update）。
  Future<void> updateItem(FridgeItem item);

  /// 出库（删除食材行；日志保留以审计）。
  Future<void> removeItem(int id);

  /// 撤销出库（toast 2.4s 窗口内的 undo）。
  Future<void> restoreItem(FridgeItem item);

  // ── 补货系统（阶段 2.x 新增）────────────────────────────────────────

  /// 标记用完 → percent=0 (UI 层检查 restockEnabled 并生成 todo)
  Future<void> markAsFinished(int id);

  /// 更新 percent (UI 层检查阈值并生成 todo)
  Future<void> updateStockPercent(int id, int percent);

  /// 获取补货候选清单（按 name 聚合）
  Future<List<RestockCandidate>> getRestockCandidates();

  // ── 历史/导出（阶段 2.x 新增）

  /// 监听变更日志流（按 timestamp 倒序）。
  Stream<List<FridgeChangeLog>> watchChangeLog();

  /// 单条删除变更日志。供历史屏 trailing IconButton / 全清使用。
  Future<void> deleteChangeLogEntry(int id);

  /// 批量删除早于 [cutoff] 的日志，返回删除条数。
  Future<int> clearChangeLogOlderThan(DateTime cutoff);

  /// 导出当前报表范围的 JSON。
  /// 写入 `getTemporaryDirectory()`，返回文件绝对路径。
  /// UI 层用 share_plus 触发系统分享。
  Future<String> exportChangeLogJson({
    required ReportScope scope,
    required List<FridgeChangeLog> entries,
  });

  // ── 应用设置（阶段 2.x 新增，本仓库承载避免再加 SettingsRepository）

  /// 监听应用设置流。单行 collection（id=0）。
  Stream<AppSettings> watchSettings();

  /// 读当前设置；若不存在则返回默认 {0, now}。
  Future<AppSettings> getSettings();

  /// 更新应用设置（仅覆盖本次）。
  Future<void> updateSettings(AppSettings settings);

  /// 启动时调用：若策略 != 永久 + 已跨月/跨季度，清理过期日志并刷新 lastCleanupAt。
  /// 实现必须吞掉异常（清理失败不应阻塞 app 启动）。
  Future<void> runRetentionSweep(DateTime now);
}
