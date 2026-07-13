import '../models/habit.dart';
import '../models/habit_checkin.dart';

/// 习惯仓库抽象接口
abstract class HabitRepository {
  Stream<List<Habit>> watchAll();

  /// 新增习惯，返回分配后的 id（用于通知调度）
  Future<int> addHabit(Habit habit);
  Future<void> updateHabit(Habit habit);
  Future<void> deleteHabit(int id);
  Future<void> checkin(int habitId, DateTime date);
  Future<void> uncheckin(int habitId, DateTime date);
  Stream<List<HabitCheckin>> watchCheckinsFor(int habitId, DateTime weekStart);
}
