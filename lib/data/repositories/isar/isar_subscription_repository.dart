import 'package:isar_plus/isar_plus.dart';

import '../../../core/lunar/festival_presets.dart';
import '../../models/subscription.dart';
import '../subscription_repository.dart';

/// 订阅仓库的 Isar 实现。
///
/// setActiveByType 在 active=true 且 type 为节日（cnFestival/westernFestival）时，
/// 调用 festival_presets 批量 upsert 该 type 的预设 Subscription；其余情况仅批量
/// 切换 active flag
///
/// INVARIANT（2026-07-09）：isar_plus 的 put/delete 通过
/// `getWriteTxn(consume: true, ...)` 依赖当前已有的写事务——**不会自己开启**。
/// 裸调必抛 `WriteTxnRequiredError`。本仓库所有写路径必须包在 `isar.write(...)` 内。
/// 防御：tools/check_isar_writes.dart 在 CI / 本地 grep 兜底。
// TODO: integration test on real device
class IsarSubscriptionRepository implements SubscriptionRepository {
  final Isar isar;

  IsarSubscriptionRepository(this.isar);

  @override
  Stream<List<Subscription>> watchAll() {
    return isar.subscriptions
        .watchLazy(fireImmediately: true)
        .map((_) => isar.subscriptions.where().findAll());
  }

  @override
  Future<int> addSubscription(Subscription sub) async {
    final newSub = sub.id == 0
        ? sub.copyWith(id: isar.subscriptions.autoIncrement())
        : sub;
    return isar.write((isar) {
      isar.subscriptions.put(newSub);
      return newSub.id;
    });
  }

  @override
  Future<void> deleteSubscription(int id) async {
    isar.write((isar) => isar.subscriptions.delete(id));
  }

  @override
  Future<void> setActive(int id, bool active) async {
    isar.write((isar) {
      final sub = isar.subscriptions.get(id);
      if (sub == null) return;
      isar.subscriptions.put(sub.copyWith(active: active));
    });
  }

  @override
  Future<void> setActiveByType(SubType type, bool active) async {
    isar.write((isar) {
      // 先批量切换该 type 现有记录的 active flag（覆盖已订阅 / 用户手工新增的记录）
      final existing = isar.subscriptions.where().typeEqualTo(type).findAll();
      for (final sub in existing) {
        isar.subscriptions.put(sub.copyWith(active: active));
      }
      // active=true 且为节日 type 时，按预设表批量 upsert 节日 Subscription
      if (active &&
          (type == SubType.cnFestival || type == SubType.westernFestival)) {
        final presets = presetsByType(type);
        for (final preset in presets) {
          // upsert 策略：同 type + 同 title 视为同一条记录
          final matched = isar.subscriptions
              .where()
              .typeEqualTo(type)
              .titleEqualTo(preset.title)
              .findAll();
          if (matched.isNotEmpty) {
            // 已存在：确保 active=true（上面已切换过，这里幂等再 put 一次）
            for (final sub in matched) {
              isar.subscriptions.put(sub.copyWith(active: true));
            }
          } else {
            // 不存在：新建一条节日 Subscription
            final newSub = Subscription(
              id: isar.subscriptions.autoIncrement(),
              title: preset.title,
              type: preset.type,
              calendar: preset.calendar,
              mode: TriggerMode.anchorMonthly,
              anchorMonth: preset.anchorMonth,
              anchorDay: preset.anchorDay,
              leadDays: preset.leadDays,
              active: true,
              createdAt: DateTime.now(),
            );
            isar.subscriptions.put(newSub);
          }
        }
      }
    });
  }
}
