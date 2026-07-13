import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/designsystem/app_icons.dart';
import '../../../core/designsystem/colors.dart';
import '../../../data/models/subscription.dart';
import '../../../data/repositories/providers.dart';
import '../widgets/add_sheets.dart';
import 'birthday_page.dart';
import 'bill_page.dart';
import 'custom_page.dart';
import 'festival_detail_screen.dart';

/// 类目侧栏的过滤键 —— 与 chips 一一对应。
///
/// "全部" 展示所有激活项；其余 chip 是若干 SubType 的并集
/// （节日：cn + western；财务：bill；自定义不在 chip 中，仅从 tile 入口进入）。
enum _CatKey {
  all('全部'),
  festival('节日'),
  home('家居'),
  pet('宠物'),
  doc('证件'),
  health('健康'),
  vehicle('车辆'),
  birthday('纪念日'),
  finance('财务');

  final String label;
  const _CatKey(this.label);

  Set<SubType> get types {
    switch (this) {
      case _CatKey.all:
        return SubType.values.toSet();
      case _CatKey.festival:
        return {SubType.cnFestival, SubType.westernFestival};
      case _CatKey.home:
        return {SubType.homeMaintenance};
      case _CatKey.pet:
        return {SubType.petCare};
      case _CatKey.doc:
        return {SubType.document};
      case _CatKey.health:
        return {SubType.healthCheck};
      case _CatKey.vehicle:
        return {SubType.vehicle};
      case _CatKey.birthday:
        return {SubType.birthday};
      case _CatKey.finance:
        return {SubType.bill};
    }
  }
}

/// 订阅 tab 主界面
class SubscriptionScreen extends ConsumerStatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  ConsumerState<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends ConsumerState<SubscriptionScreen> {
  _CatKey _selected = _CatKey.all;

  @override
  Widget build(BuildContext context) {
    final subsStream = ref.watch(subscriptionRepositoryProvider).watchAll();

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 52,
        title: const Text(
          '订阅',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.44,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppColors.borderSoft),
        ),
      ),
      body: StreamBuilder<List<Subscription>>(
        stream: subsStream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final subs = snapshot.data!;
          final grouped = _groupByType(subs);

          // 每个类目的计数（仅 active 项）。
          final counts = <_CatKey, int>{};
          for (final cat in _CatKey.values) {
            counts[cat] = cat.types.fold<int>(
              0,
              (sum, t) => sum + (grouped[t]?.length ?? 0),
            );
          }

          // 9 个 tile 在 "全部" 时全部展示；选中具体类目时按 types 过滤。
          final allTiles = _buildTiles(grouped);
          final visibleTiles = allTiles
              .where((t) => _selected.types.contains(t.type))
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CategoryBar(
                selected: _selected,
                counts: counts,
                onSelected: (k) => setState(() => _selected = k),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Lede(totalCount: counts[_CatKey.all]!),
                      _TileList(tiles: visibleTiles),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// 把订阅按 SubType 分组（仅保留 active）。`Map<SubType, List<Subscription>>`。
  Map<SubType, List<Subscription>> _groupByType(List<Subscription> subs) {
    final map = <SubType, List<Subscription>>{};
    for (final sub in subs) {
      if (!sub.active) continue;
      map.putIfAbsent(sub.type, () => []).add(sub);
    }
    return map;
  }

  /// 9 个 category tile 的元数据。
  ///
  /// 显示策略：
  /// - festival（cn/western）：count = active 项数；isActive = count>0
  /// - birthday / bill / custom / home / pet / doc / health / vehicle：同上
  ///
  /// 每个 tile 的"已订"状态：active 项数 > 0 → 右上角加绿色对勾徽标
  /// （沿用旧版 _FestivalTile 的视觉逻辑 —— 不翻黑底，仅绿色徽标叠加）。
  List<_TileData> _buildTiles(Map<SubType, List<Subscription>> grouped) {
    int countOf(SubType t) => grouped[t]?.length ?? 0;
    return [
      _TileData(
        title: '中国节日',
        type: SubType.cnFestival,
        icon: AppIcons.cnFestival(),
        count: countOf(SubType.cnFestival),
        onTap: () => _openFestivalDetail(SubType.cnFestival),
      ),
      _TileData(
        title: '西方节日',
        type: SubType.westernFestival,
        icon: AppIcons.westernFestival(),
        isWarm: true,
        count: countOf(SubType.westernFestival),
        onTap: () => _openFestivalDetail(SubType.westernFestival),
      ),
      _TileData(
        title: '家居',
        type: SubType.homeMaintenance,
        icon: AppIcons.home(),
        count: countOf(SubType.homeMaintenance),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const HomeSheet(),
        ),
      ),
      _TileData(
        title: '宠物',
        type: SubType.petCare,
        icon: AppIcons.pet(),
        count: countOf(SubType.petCare),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const PetSheet(),
        ),
      ),
      _TileData(
        title: '证件',
        type: SubType.document,
        icon: AppIcons.document(),
        count: countOf(SubType.document),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const DocumentSheet(),
        ),
      ),
      _TileData(
        title: '健康',
        type: SubType.healthCheck,
        icon: AppIcons.health(),
        count: countOf(SubType.healthCheck),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const HealthSheet(),
        ),
      ),
      _TileData(
        title: '车辆',
        type: SubType.vehicle,
        icon: AppIcons.vehicle(),
        count: countOf(SubType.vehicle),
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const VehicleSheet(),
        ),
      ),
      _TileData(
        title: '生日',
        type: SubType.birthday,
        icon: AppIcons.birthday(),
        count: countOf(SubType.birthday),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BirthdayPage()),
        ),
      ),
      _TileData(
        title: '还款',
        type: SubType.bill,
        icon: AppIcons.bill(),
        count: countOf(SubType.bill),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const BillPage()),
        ),
      ),
      _TileData(
        title: '自定义',
        type: SubType.custom,
        icon: AppIcons.custom(),
        count: countOf(SubType.custom),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CustomPage()),
        ),
      ),
    ];
  }

  /// 节日订阅入口：跳全屏详情页（替代旧 _FestivalSheet）。
  ///
  /// 走 MaterialPageRoute 直接 push（与项目内 fridge_history_screen 一致），
  /// 不污染 go_router 注册表。详情页内订阅状态由 StreamBuilder 自行驱动。
  void _openFestivalDetail(SubType type) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => FestivalDetailScreen(type: type)),
    );
  }
}

/// 类目 tile 的不可变数据。
class _TileData {
  final String title;
  final SubType type;
  final Widget icon;
  final bool isWarm;
  final int count;
  final VoidCallback onTap;

  const _TileData({
    required this.title,
    required this.type,
    required this.icon,
    required this.count,
    required this.onTap,
    this.isWarm = false,
  });
}

/// Lede 区域 — 说明文字 + 已订阅 N 项
class _Lede extends StatelessWidget {
  final int totalCount;
  const _Lede({required this.totalCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: const Text(
        '选一个类别，一次订阅一类。',
        style: TextStyle(fontSize: 14, color: AppColors.fg2, height: 1.5),
      ),
    );
  }
}

/// 9 个 tile 列表
class _TileList extends StatelessWidget {
  final List<_TileData> tiles;

  const _TileList({required this.tiles});

  @override
  Widget build(BuildContext context) {
    if (tiles.isEmpty) {
      return const Padding(
        padding: EdgeInsets.fromLTRB(16, 32, 16, 32),
        child: Center(
          child: Text(
            '该类目暂无项目',
            style: TextStyle(fontSize: 13, color: AppColors.muted),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          for (int i = 0; i < tiles.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _ActionTile(
              title: tiles[i].title,
              icon: tiles[i].icon,
              isWarm: tiles[i].isWarm,
              count: tiles[i].count,
              onTap: tiles[i].onTap,
            ),
          ],
        ],
      ),
    );
  }
}

/// 操作 tile — 14px 圆角卡片，左 glyph + 标题 + 右箭头。
/// 计数由上层 [SubscriptionScreen] 计算后传入（避免 9 个独立 StreamBuilder 订阅）。
class _ActionTile extends StatelessWidget {
  final String title;
  final Widget icon;
  final bool isWarm;
  final int count;
  final VoidCallback onTap;

  const _ActionTile({
    required this.title,
    required this.icon,
    required this.count,
    required this.onTap,
    this.isWarm = false,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = count > 0;
    final description = isActive ? '已订 $count' : '未订阅';
    final glyphBg = isWarm ? AppColors.surfaceWarm : AppColors.surface;

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            constraints: const BoxConstraints(minHeight: 64),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.bg,
              border: Border.all(color: AppColors.border, width: 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: glyphBg,
                    border: Border.all(color: AppColors.borderSoft, width: 1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: icon,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                          color: AppColors.fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.muted,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                AppIcons.right(color: AppColors.muted),
              ],
            ),
          ),
          if (isActive)
            Positioned(
              top: -7,
              right: -7,
              child: Container(
                width: 22,
                height: 22,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: AppIcons.check(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}

/// 类目侧栏（水平可滚动）—— 与 _TileList 共享 SubType → count 映射。
class _CategoryBar extends StatelessWidget {
  final _CatKey selected;
  final Map<_CatKey, int> counts;
  final ValueChanged<_CatKey> onSelected;

  const _CategoryBar({
    required this.selected,
    required this.counts,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderSoft, width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            for (final cat in _CatKey.values) ...[
              _CatChip(
                label: cat.label,
                count: counts[cat] ?? 0,
                isSelected: cat == selected,
                onTap: () => onSelected(cat),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

/// 单个类目 chip —— 36 高 pill，选中 fg bg，未选 bg + border。
class _CatChip extends StatelessWidget {
  final String label;
  final int count;
  final bool isSelected;
  final VoidCallback onTap;

  const _CatChip({
    required this.label,
    required this.count,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.fg : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.fg : AppColors.border,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(999),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? AppColors.bg : AppColors.fg,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.bg : AppColors.muted,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
