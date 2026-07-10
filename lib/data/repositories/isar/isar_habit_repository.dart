import 'package:isar_plus/isar_plus.dart';

import '../../models/habit.dart';
import '../../models/habit_checkin.dart';
import '../habit_repository.dart';

/// 习惯仓库的 Isar 实现。
///
/// INVARIANT（2026-07-09）：isar_plus 的 put/delete/clear 通过
/// `getWriteTxn(consume: true, ...)` 依赖当前已有的写事务——**不会自己开启**。
/// 裸调必抛 `WriteTxnRequiredError`。本仓库所有写路径必须包在 `isar.write(...)` 内。
/// 防御：tools/check_isar_writes.dart 在 CI / 本地 grep 兜底。
class IsarHabitRepository implements HabitRepository {
  final Isar isar;

  IsarHabitRepository(this.isar);

  @override
  Stream<List<Habit>> watchAll() {
    return isar.habits
        .watchLazy(fireImmediately: true)
        .map((_) => isar.habits.where().findAll());
  }

  @override
  Future<int> addHabit(Habit habit) async {
    // id == 0 表示 UI 新建未分配，用 autoIncrement 取实际 id（autoIncrement 是只读，无需事务）。
    final newHabit = habit.id == 0
        ? habit.copyWith(id: isar.habits.autoIncrement())
        : habit;
    return isar.write((isar) {
      isar.habits.put(newHabit);
      return newHabit.id;
    });
  }

  @override
  Future<void> deleteHabit(int id) async {
    // 级联删除该习惯的打卡记录
    isar.write((isar) {
      isar.habits.delete(id);
      final checkins = isar.habitCheckins.where().habitIdEqualTo(id).findAll();
      for (final c in checkins) {
        isar.habitCheckins.delete(c.id);
      }
    });
  }

  @override
  Future<void> checkin(int habitId, DateTime date) async {
    // 幂等：若当日已打卡则跳过
    // 注：date 取 dayStart 归一化到 00:00，便于按天匹配。
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    final exists = isar.habitCheckins
            .where()
            .habitIdEqualTo(habitId)
            .dateGreaterThanOrEqualTo(dayStart)
            .dateLessThan(dayEnd)
            .findAll()
            .isNotEmpty;
    if (exists) return;

    final id = isar.habitCheckins.autoIncrement();
    isar.write((isar) {
      isar.habitCheckins.put(
        HabitCheckin(id: id, habitId: habitId, date: dayStart),
      );
    });
  }

  @override
  Future<void> uncheckin(int habitId, DateTime date) async {
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    isar.write((isar) {
      final checkins = isar.habitCheckins
          .where()
          .habitIdEqualTo(habitId)
          .dateGreaterThanOrEqualTo(dayStart)
          .dateLessThan(dayEnd)
          .findAll();
      for (final c in checkins) {
        isar.habitCheckins.delete(c.id);
      }
    });
  }

  @override
  Stream<List<HabitCheckin>> watchCheckinsFor(int habitId, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    return isar.habitCheckins
        .watchLazy(fireImmediately: true)
        .map((_) => isar.habitCheckins
            .where()
            .habitIdEqualTo(habitId)
            .dateGreaterThanOrEqualTo(weekStart)
            .dateLessThan(weekEnd)
            .findAll());
  }
}
