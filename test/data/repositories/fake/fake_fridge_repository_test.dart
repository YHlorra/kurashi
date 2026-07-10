// FakeFridgeRepository 单测（Task 1.4）
//
// 覆盖 4 个核心场景：
//   1.4.a addItem：新增后 watchAll 含它，返回 id
//   1.4.b removeItem：删除后列表不含
//   1.4.c restoreItem：恢复后列表含它
//   1.4.d updateItem：更新后字段变化（如 expiryDate 改了）
//
// 约定：
// - mock 数据 6 项（id 1-6），_nextId 起始 100
// - Fake 是同步内存实现，watchAll() 通过 Future.microtask 推送
import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/fridge_item.dart';
import 'package:kurashi/data/repositories/fake/fake_fridge_repository.dart';

void main() {
  late FakeFridgeRepository repo;

  setUp(() {
    repo = FakeFridgeRepository();
  });

  group('FakeFridgeRepository', () {
    // ── 1.4.a addItem：新增后 watchAll 含它，返回 id ──────────────────
    test('addItem：新增后 watchAll 含它，返回 id', () async {
      final item = FridgeItem(
        name: '酸奶',
        quantity: '4 杯',
        addedDate: DateTime(2026, 7, 6),
        expiryDate: DateTime(2026, 7, 13),

      );
      final id = await repo.addItem(item);
      expect(id, isPositive);

      final list = await repo.watchAll().first;
      expect(list.any((e) => e.id == id), isTrue);
      expect(list.firstWhere((e) => e.id == id).name, '酸奶');
    });

    // ── 1.4.b removeItem：删除后列表不含 ──────────────────────────────
    test('removeItem：删除后列表不含', () async {
      await repo.removeItem(1);
      final list = await repo.watchAll().first;
      expect(list.any((e) => e.id == 1), isFalse);
    });

    // ── 1.4.c restoreItem：恢复后列表含它 ─────────────────────────────
    test('restoreItem：恢复后列表含它', () async {
      // 先删除再恢复（restoreItem 直接 add 回传入的 item，不分配新 id）
      // DateTime 非 const 构造，FridgeItem 不能用 const
      final item = FridgeItem(
        id: 1,
        name: '巴氏鲜牛奶',
        quantity: '1 L',
        addedDate: DateTime(2026, 6, 25),
        expiryDate: DateTime(2026, 7, 2),

      );
      await repo.removeItem(1);
      await repo.restoreItem(item);

      final list = await repo.watchAll().first;
      expect(list.any((e) => e.id == 1), isTrue);
      expect(list.firstWhere((e) => e.id == 1).name, '巴氏鲜牛奶');
    });

    // ── 1.4.d updateItem：更新后字段变化 ──────────────────────────────
    test('updateItem：更新后字段变化（expiryDate 改了）', () async {
      // mock id=1 expiryDate=2026-07-02，更新为 2026-07-10
      final updated = FridgeItem(
        id: 1,
        name: '巴氏鲜牛奶',
        quantity: '1 L',
        addedDate: DateTime(2026, 6, 25),
        expiryDate: DateTime(2026, 7, 10),

      );
      await repo.updateItem(updated);

      final list = await repo.watchAll().first;
      final item = list.firstWhere((e) => e.id == 1);
      expect(item.expiryDate, DateTime(2026, 7, 10));
    });
  });
}
