import 'dart:async';
import 'package:flutter/material.dart';
import '../../models/habit.dart';
import '../../models/habit_checkin.dart';
import '../habit_repository.dart';

/// 习惯仓库的内存实现（阶段 1 用 mock 数据）
class FakeHabitRepository implements HabitRepository {
  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _checkinsController = StreamController<List<HabitCheckin>>.broadcast();
  final List<Habit> _habits;
  final List<HabitCheckin> _checkins;
  int _nextHabitId = 100;
  int _nextCheckinId = 1000;

  FakeHabitRepository()
      : _habits = _createMockHabits(),
        _checkins = _createMockCheckins();

  static List<Habit> _createMockHabits() {
    final now = DateTime(2026, 7, 1);
    return [
      Habit(
        id: 1,
        title: '阅读 30 分钟',
        frequencyPerWeek: 3,
        reminderTime: const TimeOfDay(hour: 22, minute: 0),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Habit(
        id: 2,
        title: '喝 8 杯水',
        frequencyPerWeek: 7,
        reminderTime: const TimeOfDay(hour: 9, minute: 0),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
      Habit(
        id: 3,
        title: '跑步 5km',
        frequencyPerWeek: 7,
        reminderTime: const TimeOfDay(hour: 7, minute: 0),
        createdAt: now.subtract(const Duration(days: 7)),
      ),
    ];
  }

  static List<HabitCheckin> _createMockCheckins() {
    // 本周从 2026-06-29（周一）开始
    final weekStart = DateTime(2026, 6, 29);
    return [
      // 阅读 30 分钟：本周打卡 2 次（进度 2/3）
      HabitCheckin(id: 1, habitId: 1, date: weekStart),
      HabitCheckin(id: 2, habitId: 1, date: weekStart.add(const Duration(days: 1))),
      // 喝 8 杯水：本周打卡 7 次（进度 7/7）
      HabitCheckin(id: 3, habitId: 2, date: weekStart),
      HabitCheckin(id: 4, habitId: 2, date: weekStart.add(const Duration(days: 1))),
      HabitCheckin(id: 5, habitId: 2, date: weekStart.add(const Duration(days: 2))),
      HabitCheckin(id: 6, habitId: 2, date: weekStart.add(const Duration(days: 3))),
      HabitCheckin(id: 7, habitId: 2, date: weekStart.add(const Duration(days: 4))),
      HabitCheckin(id: 8, habitId: 2, date: weekStart.add(const Duration(days: 5))),
      HabitCheckin(id: 9, habitId: 2, date: weekStart.add(const Duration(days: 6))),
      // 跑步 5km：本周打卡 5 次（进度 5/7）
      HabitCheckin(id: 10, habitId: 3, date: weekStart),
      HabitCheckin(id: 11, habitId: 3, date: weekStart.add(const Duration(days: 1))),
      HabitCheckin(id: 12, habitId: 3, date: weekStart.add(const Duration(days: 2))),
      HabitCheckin(id: 13, habitId: 3, date: weekStart.add(const Duration(days: 3))),
      HabitCheckin(id: 14, habitId: 3, date: weekStart.add(const Duration(days: 4))),
    ];
  }

  @override
  Stream<List<Habit>> watchAll() {
    Future.microtask(() => _habitsController.add(List.unmodifiable(_habits)));
    return _habitsController.stream;
  }

  @override
  Future<int> addHabit(Habit habit) async {
    final newHabit = habit.id == 0 ? habit.copyWith(id: _nextHabitId++) : habit;
    _habits.add(newHabit);
    _habitsController.add(List.unmodifiable(_habits));
    return newHabit.id;
  }

  @override
  Future<void> deleteHabit(int id) async {
    _habits.removeWhere((h) => h.id == id);
    _checkins.removeWhere((c) => c.habitId == id);
    _habitsController.add(List.unmodifiable(_habits));
    _checkinsController.add(List.unmodifiable(_checkins));
  }

  @override
  Future<void> checkin(int habitId, DateTime date) async {
    // 检查是否已存在
    final exists = _checkins.any(
      (c) => c.habitId == habitId && _isSameDay(c.date, date),
    );
    if (!exists) {
      final newCheckin = HabitCheckin(
        id: _nextCheckinId++,
        habitId: habitId,
        date: date,
      );
      _checkins.add(newCheckin);
      _checkinsController.add(List.unmodifiable(_checkins));
    }
  }

  @override
  Future<void> uncheckin(int habitId, DateTime date) async {
    _checkins.removeWhere(
      (c) => c.habitId == habitId && _isSameDay(c.date, date),
    );
    _checkinsController.add(List.unmodifiable(_checkins));
  }

  @override
  Stream<List<HabitCheckin>> watchCheckinsFor(int habitId, DateTime weekStart) {
    final weekEnd = weekStart.add(const Duration(days: 7));
    Future.microtask(() {
      final filtered = _checkins
          .where((c) =>
              c.habitId == habitId &&
              !c.date.isBefore(weekStart) &&
              c.date.isBefore(weekEnd))
          .toList();
      _checkinsController.add(List.unmodifiable(filtered));
    });
    return _checkinsController.stream;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
