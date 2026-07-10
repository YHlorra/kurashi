import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:kurashi/data/models/subscription.dart';
import 'package:kurashi/data/repositories/fake/fake_subscription_repository.dart';

void main() {
  group('SubscriptionRepository - behavior', () {
    test('user adds a subscription and sees it', () async {
      final repo = FakeSubscriptionRepository();
      final events = <List<Subscription>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final before = events.last.length;
      await repo.addSubscription(Subscription(
        title: 'New Bill', type: SubType.bill, calendar: Calendar.solar,
        mode: TriggerMode.anchorMonthly, anchorDay: 15, leadDays: 1,
        active: true, createdAt: DateTime.now(),
      ));
      await Future.delayed(Duration.zero);

      expect(events.last.length, before + 1);
      await sub.cancel();
    });

    test('user deletes a subscription and it disappears', () async {
      final repo = FakeSubscriptionRepository();
      final events = <List<Subscription>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      final before = events.last.length;
      final id = events.last.first.id;
      await repo.deleteSubscription(id);
      await Future.delayed(Duration.zero);

      expect(events.last.length, before - 1);
      expect(events.last.any((s) => s.id == id), isFalse);
      await sub.cancel();
    });

    test('user taps activate on a festival subscription and all become active', () async {
      final repo = FakeSubscriptionRepository();
      final events = <List<Subscription>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      await repo.setActiveByType(SubType.cnFestival, true);
      await Future.delayed(Duration.zero);

      final festivals = events.last.where((s) => s.type == SubType.cnFestival).toList();
      expect(festivals, isNotEmpty);
      expect(festivals.every((s) => s.active), isTrue);
      await sub.cancel();
    });

    test('user taps deactivate and all matching become inactive', () async {
      final repo = FakeSubscriptionRepository();
      final events = <List<Subscription>>[];
      final sub = repo.watchAll().listen(events.add);
      await Future.delayed(Duration.zero);

      await repo.setActiveByType(SubType.cnFestival, false);
      await Future.delayed(Duration.zero);

      final festivals = events.last.where((s) => s.type == SubType.cnFestival).toList();
      expect(festivals.every((s) => !s.active), isTrue);
      await sub.cancel();
    });
  });
}
