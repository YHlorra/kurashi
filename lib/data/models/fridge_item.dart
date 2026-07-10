import 'package:isar_plus/isar_plus.dart';

part 'fridge_item.g.dart';

/// 冰箱食材数据模型
///
/// 阶段 2.1：迁移为 isar_plus @collection。
@collection
class FridgeItem {
  final int id;

  final String name;
  final String quantity;
  final DateTime addedDate;
  final DateTime expiryDate;

  /// 食材标签：蔬菜 / 水果 / 肉类 / 自定义（持久化到 AppSettings.settingsJson.fridgeTags）
  final String? tag;

  /// 当前剩余百分比（0-100）
  final int remainingPercent;

  /// 补货提醒总开关
  final bool restockEnabled;

  /// per-item 阈值（默认 20%）
  final int restockThresholdPercent;

  /// 补货量（首次添加 backfill = quantity）
  final String restockQty;

  const FridgeItem({
    this.id = 0,
    required this.name,
    required this.quantity,
    required this.addedDate,
    required this.expiryDate,
    this.tag,
    this.remainingPercent = 100,
    this.restockEnabled = false,
    this.restockThresholdPercent = 20,
    this.restockQty = '',
  });

  FridgeItem copyWith({
    int? id,
    String? name,
    String? quantity,
    DateTime? addedDate,
    DateTime? expiryDate,
    String? tag,
    int? remainingPercent,
    bool? restockEnabled,
    int? restockThresholdPercent,
    String? restockQty,
  }) {
    return FridgeItem(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      addedDate: addedDate ?? this.addedDate,
      expiryDate: expiryDate ?? this.expiryDate,
      tag: tag ?? this.tag,
      remainingPercent: remainingPercent ?? this.remainingPercent,
      restockEnabled: restockEnabled ?? this.restockEnabled,
      restockThresholdPercent: restockThresholdPercent ?? this.restockThresholdPercent,
      restockQty: restockQty ?? this.restockQty,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FridgeItem &&
        other.id == id &&
        other.name == name &&
        other.quantity == quantity &&
        other.addedDate == addedDate &&
        other.expiryDate == expiryDate &&
        other.tag == tag &&
        other.remainingPercent == remainingPercent &&
        other.restockEnabled == restockEnabled &&
        other.restockThresholdPercent == restockThresholdPercent &&
        other.restockQty == restockQty;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      name,
      quantity,
      addedDate,
      expiryDate,
      tag,
      remainingPercent,
      restockEnabled,
      restockThresholdPercent,
      restockQty,
    );
  }

  /// 业务字段变更检测 —— 仓库 updateItem 的 diff gate。
  ///
  /// 只比对 8 个用户可见字段（name/quantity/expiryDate/tag/4 个 restock），
  /// 排除 `id`（身份）和 `addedDate`（入库时刻，不应参与「是否有改动」判定）。
  ///
  /// 不用 `operator ==`：== 比对包含 `addedDate`，且即便 same-millis，
  /// 不同实例 `DateTime` 也不 identity-equal，逻辑会错。
  bool hasBusinessChange(FridgeItem other) {
    return name != other.name ||
        quantity != other.quantity ||
        expiryDate != other.expiryDate ||
        tag != other.tag ||
        remainingPercent != other.remainingPercent ||
        restockEnabled != other.restockEnabled ||
        restockThresholdPercent != other.restockThresholdPercent ||
        restockQty != other.restockQty;
  }
}
