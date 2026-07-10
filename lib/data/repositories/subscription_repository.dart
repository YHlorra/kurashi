import '../models/subscription.dart';

/// 订阅仓库抽象接口
abstract class SubscriptionRepository {
  /// 监听全部订阅
  Stream<List<Subscription>> watchAll();

  /// 新增订阅，返回分配后的 id（用于通知调度）
  Future<int> addSubscription(Subscription sub);

  /// 删除订阅
  Future<void> deleteSubscription(int id);

  /// 设置单条订阅的激活状态
  Future<void> setActive(int id, bool active);

  /// 按类型批量设置激活状态（用于节日一键订阅 / 取消）
  Future<void> setActiveByType(SubType type, bool active);
}
