import 'dart:async';
import '../../../core/lunar/festival_presets.dart';
import '../../models/subscription.dart';
import '../subscription_repository.dart';

/// 订阅仓库的内存实现（阶段 1 用 mock 数据）
class FakeSubscriptionRepository implements SubscriptionRepository {
  final _controller = StreamController<List<Subscription>>.broadcast();
  final List<Subscription> _items;
  int _nextId = 112;

  FakeSubscriptionRepository() : _items = _createMockData();

  static List<Subscription> _createMockData() {
    final now = DateTime(2026, 7, 1);
    return [
      // 中国节日（9 项预设，初始 active=false 与设计图未订阅态一致）
      Subscription(
        id: 1,
        title: '元旦',
        type: SubType.cnFestival,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 1,
        anchorDay: 1,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 2,
        title: '春节',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 1,
        anchorDay: 1,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 3,
        title: '元宵节',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 1,
        anchorDay: 15,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 4,
        title: '清明节',
        type: SubType.cnFestival,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 4,
        anchorDay: 5,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 5,
        title: '端午节',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 5,
        anchorDay: 5,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 6,
        title: '七夕',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 7,
        anchorDay: 7,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 7,
        title: '中秋节',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 8,
        anchorDay: 15,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 8,
        title: '国庆节',
        type: SubType.cnFestival,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 10,
        anchorDay: 1,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 9,
        title: '腊八节',
        type: SubType.cnFestival,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 12,
        anchorDay: 8,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      // 生日 1 条：爸爸生日 农历 7/8 提前 3 天（初始未订阅）
      Subscription(
        id: 10,
        title: '爸爸生日',
        type: SubType.birthday,
        calendar: Calendar.lunar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 7,
        anchorDay: 8,
        leadDays: 3,
        active: false,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      // 还款 1 条：花呗 每月 5 号 提前 1 天（初始未订阅）
      Subscription(
        id: 11,
        title: '花呗',
        type: SubType.bill,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorDay: 5,
        leadDays: 1,
        active: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      // 自定义 1 条（按月）：整理桌面 每月 15 号 提前 0 天（初始未订阅）
      Subscription(
        id: 12,
        title: '整理桌面',
        type: SubType.custom,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorDay: 15,
        leadDays: 0,
        active: false,
        createdAt: now.subtract(const Duration(days: 3)),
      ),
      // 家居（3 项）
      Subscription(
        id: 100,
        title: '净水器滤芯',
        type: SubType.homeMaintenance,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 180,
        leadDays: 7,
        active: true,
        createdAt: now.subtract(const Duration(days: 40)),
      ),
      Subscription(
        id: 101,
        title: '烟雾报警器电池',
        type: SubType.homeMaintenance,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 365,
        leadDays: 14,
        active: true,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
      Subscription(
        id: 102,
        title: '牙刷',
        type: SubType.homeMaintenance,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 90,
        leadDays: 7,
        active: false,
        createdAt: now.subtract(const Duration(days: 5)),
      ),
      // 宠物（3 项）
      Subscription(
        id: 103,
        title: '狂犬疫苗（豆豆）',
        type: SubType.petCare,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 365,
        leadDays: 7,
        active: true,
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      Subscription(
        id: 104,
        title: '心丝虫预防',
        type: SubType.petCare,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 30,
        leadDays: 3,
        active: true,
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      Subscription(
        id: 105,
        title: '体内驱虫',
        type: SubType.petCare,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 180,
        leadDays: 7,
        active: false,
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      // 证件（2 项）
      Subscription(
        id: 106,
        title: '爸爸的身份证',
        type: SubType.document,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 3,
        anchorDay: 15,
        leadDays: 30,
        active: false,
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      Subscription(
        id: 107,
        title: '我的驾驶证',
        type: SubType.document,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 8,
        anchorDay: 20,
        leadDays: 90,
        active: false,
        createdAt: now.subtract(const Duration(days: 25)),
      ),
      // 健康（2 项）
      Subscription(
        id: 108,
        title: '年度全面体检',
        type: SubType.healthCheck,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 365,
        leadDays: 30,
        active: false,
        createdAt: now.subtract(const Duration(days: 8)),
      ),
      Subscription(
        id: 109,
        title: '牙科检查+洁牙',
        type: SubType.healthCheck,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 180,
        leadDays: 7,
        active: true,
        createdAt: now.subtract(const Duration(days: 12)),
      ),
      // 车辆（2 项）
      Subscription(
        id: 110,
        title: '机油更换（全合成）',
        type: SubType.vehicle,
        calendar: Calendar.solar,
        mode: TriggerMode.intervalDays,
        intervalDays: 365,
        leadDays: 14,
        active: false,
        createdAt: now.subtract(const Duration(days: 18)),
      ),
      Subscription(
        id: 111,
        title: '交强险续费',
        type: SubType.vehicle,
        calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly,
        anchorMonth: 5,
        anchorDay: 15,
        leadDays: 30,
        active: true,
        createdAt: now.subtract(const Duration(days: 22)),
      ),
    ];
  }

  @override
  Stream<List<Subscription>> watchAll() {
    Future.microtask(() => _controller.add(List.unmodifiable(_items)));
    return _controller.stream;
  }

  @override
  Future<int> addSubscription(Subscription sub) async {
    final newSub = sub.id == 0 ? sub.copyWith(id: _nextId++) : sub;
    _items.add(newSub);
    _controller.add(List.unmodifiable(_items));
    return newSub.id;
  }

  @override
  Future<void> deleteSubscription(int id) async {
    _items.removeWhere((sub) => sub.id == id);
    _controller.add(List.unmodifiable(_items));
  }

  @override
  Future<void> setActive(int id, bool active) async {
    final index = _items.indexWhere((sub) => sub.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(active: active);
      _controller.add(List.unmodifiable(_items));
    }
  }

  @override
  Future<void> setActiveByType(SubType type, bool active) async {
    // 先批量切换该 type 现有记录的 active 标志（与 Isar 实现保持一致）
    for (int i = 0; i < _items.length; i++) {
      if (_items[i].type == type) {
        _items[i] = _items[i].copyWith(active: active);
      }
    }
    // active=true 且为节日 type 时，按预设表批量 upsert 节日 Subscription
    if (active &&
        (type == SubType.cnFestival || type == SubType.westernFestival)) {
      final presets = presetsByType(type);
      for (final preset in presets) {
        // upsert 策略：同 type + 同 title 视为同一条记录
        final index = _items.indexWhere(
          (sub) => sub.type == type && sub.title == preset.title,
        );
        if (index != -1) {
          // 已存在：确保 active=true（上面已切换过，这里幂等再设一次）
          _items[index] = _items[index].copyWith(active: true);
        } else {
          // 不存在：新建一条节日 Subscription
          _items.add(Subscription(
            id: _nextId++,
            title: preset.title,
            type: preset.type,
            calendar: preset.calendar,
            mode: TriggerMode.anchorMonthly,
            anchorMonth: preset.anchorMonth,
            anchorDay: preset.anchorDay,
            leadDays: preset.leadDays,
            active: true,
            createdAt: DateTime.now(),
          ));
        }
      }
    }
    _controller.add(List.unmodifiable(_items));
  }
}
