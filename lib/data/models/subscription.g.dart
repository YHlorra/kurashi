// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetSubscriptionCollection on Isar {
  IsarCollection<int, Subscription> get subscriptions => this.collection();
}

final SubscriptionSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'Subscription',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'title', type: IsarType.string),
      IsarPropertySchema(
        name: 'type',
        type: IsarType.byte,

        enumMap: {
          "cnFestival": 0,
          "westernFestival": 1,
          "birthday": 2,
          "bill": 3,
          "custom": 4,
          "homeMaintenance": 5,
          "petCare": 6,
          "document": 7,
          "healthCheck": 8,
          "vehicle": 9,
        },
      ),
      IsarPropertySchema(
        name: 'calendar',
        type: IsarType.byte,

        enumMap: {"solar": 0, "lunar": 1},
      ),
      IsarPropertySchema(
        name: 'mode',
        type: IsarType.byte,

        enumMap: {"anchorMonthly": 0, "intervalDays": 1},
      ),
      IsarPropertySchema(name: 'anchorMonth', type: IsarType.long),
      IsarPropertySchema(name: 'anchorDay', type: IsarType.long),
      IsarPropertySchema(name: 'intervalDays', type: IsarType.long),
      IsarPropertySchema(name: 'leadDays', type: IsarType.long),
      IsarPropertySchema(name: 'active', type: IsarType.bool),
      IsarPropertySchema(name: 'isPack', type: IsarType.bool),
      IsarPropertySchema(name: 'createdAt', type: IsarType.dateTime),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, Subscription>(
    serialize: serializeSubscription,
    deserialize: deserializeSubscription,
    deserializeProperty: deserializeSubscriptionProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeSubscription(IsarWriter writer, Subscription object) {
  IsarCore.writeString(writer, 1, object.title);
  IsarCore.writeByte(writer, 2, object.type.index);
  IsarCore.writeByte(writer, 3, object.calendar.index);
  IsarCore.writeByte(writer, 4, object.mode.index);
  IsarCore.writeLong(writer, 5, object.anchorMonth ?? -9223372036854775808);
  IsarCore.writeLong(writer, 6, object.anchorDay ?? -9223372036854775808);
  IsarCore.writeLong(writer, 7, object.intervalDays ?? -9223372036854775808);
  IsarCore.writeLong(writer, 8, object.leadDays);
  IsarCore.writeBool(writer, 9, value: object.active);
  IsarCore.writeBool(writer, 10, value: object.isPack);
  IsarCore.writeLong(
    writer,
    11,
    object.createdAt.toUtc().microsecondsSinceEpoch,
  );
  return object.id;
}

@isarProtected
Subscription deserializeSubscription(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _title;
  _title = IsarCore.readString(reader, 1) ?? '';
  final SubType _type;
  {
    if (IsarCore.readNull(reader, 2)) {
      _type = SubType.cnFestival;
    } else {
      _type =
          _subscriptionType[IsarCore.readByte(reader, 2)] ?? SubType.cnFestival;
    }
  }
  final Calendar _calendar;
  {
    if (IsarCore.readNull(reader, 3)) {
      _calendar = Calendar.solar;
    } else {
      _calendar =
          _subscriptionCalendar[IsarCore.readByte(reader, 3)] ?? Calendar.solar;
    }
  }
  final TriggerMode _mode;
  {
    if (IsarCore.readNull(reader, 4)) {
      _mode = TriggerMode.anchorMonthly;
    } else {
      _mode =
          _subscriptionMode[IsarCore.readByte(reader, 4)] ??
          TriggerMode.anchorMonthly;
    }
  }
  final int? _anchorMonth;
  {
    final value = IsarCore.readLong(reader, 5);
    if (value == -9223372036854775808) {
      _anchorMonth = null;
    } else {
      _anchorMonth = value;
    }
  }
  final int? _anchorDay;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _anchorDay = null;
    } else {
      _anchorDay = value;
    }
  }
  final int? _intervalDays;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _intervalDays = null;
    } else {
      _intervalDays = value;
    }
  }
  final int _leadDays;
  _leadDays = IsarCore.readLong(reader, 8);
  final bool _active;
  {
    if (IsarCore.readNull(reader, 9)) {
      _active = true;
    } else {
      _active = IsarCore.readBool(reader, 9);
    }
  }
  final bool _isPack;
  _isPack = IsarCore.readBool(reader, 10);
  final DateTime _createdAt;
  {
    final value = IsarCore.readLong(reader, 11);
    if (value == -9223372036854775808) {
      _createdAt = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _createdAt = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final object = Subscription(
    id: _id,
    title: _title,
    type: _type,
    calendar: _calendar,
    mode: _mode,
    anchorMonth: _anchorMonth,
    anchorDay: _anchorDay,
    intervalDays: _intervalDays,
    leadDays: _leadDays,
    active: _active,
    isPack: _isPack,
    createdAt: _createdAt,
  );
  return object;
}

@isarProtected
dynamic deserializeSubscriptionProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
    case 2:
      {
        if (IsarCore.readNull(reader, 2)) {
          return SubType.cnFestival;
        } else {
          return _subscriptionType[IsarCore.readByte(reader, 2)] ??
              SubType.cnFestival;
        }
      }
    case 3:
      {
        if (IsarCore.readNull(reader, 3)) {
          return Calendar.solar;
        } else {
          return _subscriptionCalendar[IsarCore.readByte(reader, 3)] ??
              Calendar.solar;
        }
      }
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return TriggerMode.anchorMonthly;
        } else {
          return _subscriptionMode[IsarCore.readByte(reader, 4)] ??
              TriggerMode.anchorMonthly;
        }
      }
    case 5:
      {
        final value = IsarCore.readLong(reader, 5);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return null;
        } else {
          return value;
        }
      }
    case 8:
      return IsarCore.readLong(reader, 8);
    case 9:
      {
        if (IsarCore.readNull(reader, 9)) {
          return true;
        } else {
          return IsarCore.readBool(reader, 9);
        }
      }
    case 10:
      return IsarCore.readBool(reader, 10);
    case 11:
      {
        final value = IsarCore.readLong(reader, 11);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _SubscriptionUpdate {
  bool call({
    required int id,
    String? title,
    SubType? type,
    Calendar? calendar,
    TriggerMode? mode,
    int? anchorMonth,
    int? anchorDay,
    int? intervalDays,
    int? leadDays,
    bool? active,
    bool? isPack,
    DateTime? createdAt,
  });
}

class _SubscriptionUpdateImpl implements _SubscriptionUpdate {
  const _SubscriptionUpdateImpl(this.collection);

  final IsarCollection<int, Subscription> collection;

  @override
  bool call({
    required int id,
    Object? title = ignore,
    Object? type = ignore,
    Object? calendar = ignore,
    Object? mode = ignore,
    Object? anchorMonth = ignore,
    Object? anchorDay = ignore,
    Object? intervalDays = ignore,
    Object? leadDays = ignore,
    Object? active = ignore,
    Object? isPack = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (title != ignore) 1: title as String?,
            if (type != ignore) 2: type as SubType?,
            if (calendar != ignore) 3: calendar as Calendar?,
            if (mode != ignore) 4: mode as TriggerMode?,
            if (anchorMonth != ignore) 5: anchorMonth as int?,
            if (anchorDay != ignore) 6: anchorDay as int?,
            if (intervalDays != ignore) 7: intervalDays as int?,
            if (leadDays != ignore) 8: leadDays as int?,
            if (active != ignore) 9: active as bool?,
            if (isPack != ignore) 10: isPack as bool?,
            if (createdAt != ignore) 11: createdAt as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _SubscriptionUpdateAll {
  int call({
    required List<int> id,
    String? title,
    SubType? type,
    Calendar? calendar,
    TriggerMode? mode,
    int? anchorMonth,
    int? anchorDay,
    int? intervalDays,
    int? leadDays,
    bool? active,
    bool? isPack,
    DateTime? createdAt,
  });
}

class _SubscriptionUpdateAllImpl implements _SubscriptionUpdateAll {
  const _SubscriptionUpdateAllImpl(this.collection);

  final IsarCollection<int, Subscription> collection;

  @override
  int call({
    required List<int> id,
    Object? title = ignore,
    Object? type = ignore,
    Object? calendar = ignore,
    Object? mode = ignore,
    Object? anchorMonth = ignore,
    Object? anchorDay = ignore,
    Object? intervalDays = ignore,
    Object? leadDays = ignore,
    Object? active = ignore,
    Object? isPack = ignore,
    Object? createdAt = ignore,
  }) {
    return collection.updateProperties(id, {
      if (title != ignore) 1: title as String?,
      if (type != ignore) 2: type as SubType?,
      if (calendar != ignore) 3: calendar as Calendar?,
      if (mode != ignore) 4: mode as TriggerMode?,
      if (anchorMonth != ignore) 5: anchorMonth as int?,
      if (anchorDay != ignore) 6: anchorDay as int?,
      if (intervalDays != ignore) 7: intervalDays as int?,
      if (leadDays != ignore) 8: leadDays as int?,
      if (active != ignore) 9: active as bool?,
      if (isPack != ignore) 10: isPack as bool?,
      if (createdAt != ignore) 11: createdAt as DateTime?,
    });
  }
}

extension SubscriptionUpdate on IsarCollection<int, Subscription> {
  _SubscriptionUpdate get update => _SubscriptionUpdateImpl(this);

  _SubscriptionUpdateAll get updateAll => _SubscriptionUpdateAllImpl(this);
}

sealed class _SubscriptionQueryUpdate {
  int call({
    String? title,
    SubType? type,
    Calendar? calendar,
    TriggerMode? mode,
    int? anchorMonth,
    int? anchorDay,
    int? intervalDays,
    int? leadDays,
    bool? active,
    bool? isPack,
    DateTime? createdAt,
  });
}

class _SubscriptionQueryUpdateImpl implements _SubscriptionQueryUpdate {
  const _SubscriptionQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<Subscription> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? type = ignore,
    Object? calendar = ignore,
    Object? mode = ignore,
    Object? anchorMonth = ignore,
    Object? anchorDay = ignore,
    Object? intervalDays = ignore,
    Object? leadDays = ignore,
    Object? active = ignore,
    Object? isPack = ignore,
    Object? createdAt = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (title != ignore) 1: title as String?,
      if (type != ignore) 2: type as SubType?,
      if (calendar != ignore) 3: calendar as Calendar?,
      if (mode != ignore) 4: mode as TriggerMode?,
      if (anchorMonth != ignore) 5: anchorMonth as int?,
      if (anchorDay != ignore) 6: anchorDay as int?,
      if (intervalDays != ignore) 7: intervalDays as int?,
      if (leadDays != ignore) 8: leadDays as int?,
      if (active != ignore) 9: active as bool?,
      if (isPack != ignore) 10: isPack as bool?,
      if (createdAt != ignore) 11: createdAt as DateTime?,
    });
  }
}

extension SubscriptionQueryUpdate on IsarQuery<Subscription> {
  _SubscriptionQueryUpdate get updateFirst =>
      _SubscriptionQueryUpdateImpl(this, limit: 1);

  _SubscriptionQueryUpdate get updateAll => _SubscriptionQueryUpdateImpl(this);
}

class _SubscriptionQueryBuilderUpdateImpl implements _SubscriptionQueryUpdate {
  const _SubscriptionQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<Subscription, Subscription, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? title = ignore,
    Object? type = ignore,
    Object? calendar = ignore,
    Object? mode = ignore,
    Object? anchorMonth = ignore,
    Object? anchorDay = ignore,
    Object? intervalDays = ignore,
    Object? leadDays = ignore,
    Object? active = ignore,
    Object? isPack = ignore,
    Object? createdAt = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (title != ignore) 1: title as String?,
        if (type != ignore) 2: type as SubType?,
        if (calendar != ignore) 3: calendar as Calendar?,
        if (mode != ignore) 4: mode as TriggerMode?,
        if (anchorMonth != ignore) 5: anchorMonth as int?,
        if (anchorDay != ignore) 6: anchorDay as int?,
        if (intervalDays != ignore) 7: intervalDays as int?,
        if (leadDays != ignore) 8: leadDays as int?,
        if (active != ignore) 9: active as bool?,
        if (isPack != ignore) 10: isPack as bool?,
        if (createdAt != ignore) 11: createdAt as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension SubscriptionQueryBuilderUpdate
    on QueryBuilder<Subscription, Subscription, QOperations> {
  _SubscriptionQueryUpdate get updateFirst =>
      _SubscriptionQueryBuilderUpdateImpl(this, limit: 1);

  _SubscriptionQueryUpdate get updateAll =>
      _SubscriptionQueryBuilderUpdateImpl(this);
}

const _subscriptionType = {
  0: SubType.cnFestival,
  1: SubType.westernFestival,
  2: SubType.birthday,
  3: SubType.bill,
  4: SubType.custom,
  5: SubType.homeMaintenance,
  6: SubType.petCare,
  7: SubType.document,
  8: SubType.healthCheck,
  9: SubType.vehicle,
};
const _subscriptionCalendar = {0: Calendar.solar, 1: Calendar.lunar};
const _subscriptionMode = {
  0: TriggerMode.anchorMonthly,
  1: TriggerMode.intervalDays,
};

extension SubscriptionQueryFilter
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {
  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 1,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleContains(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 1,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> titleMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 1,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  titleIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> typeEqualTo(
    SubType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  typeGreaterThan(SubType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 2, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  typeGreaterThanOrEqualTo(SubType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 2, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> typeLessThan(
    SubType value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  typeLessThanOrEqualTo(SubType value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 2, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> typeBetween(
    SubType lower,
    SubType upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 2, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarEqualTo(Calendar value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarGreaterThan(Calendar value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarGreaterThanOrEqualTo(Calendar value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarLessThan(Calendar value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarLessThanOrEqualTo(Calendar value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  calendarBetween(Calendar lower, Calendar upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> modeEqualTo(
    TriggerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  modeGreaterThan(TriggerMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  modeGreaterThanOrEqualTo(TriggerMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> modeLessThan(
    TriggerMode value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  modeLessThanOrEqualTo(TriggerMode value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> modeBetween(
    TriggerMode lower,
    TriggerMode upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthGreaterThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthLessThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 5, value: value));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 5, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorMonthBetween(int? lower, int? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 5, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 6));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayGreaterThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayLessThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  anchorDayBetween(int? lower, int? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 7));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysGreaterThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysGreaterThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysLessThan(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysLessThanOrEqualTo(int? value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  intervalDaysBetween(int? lower, int? upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 8, value: value));
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  leadDaysBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> activeEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition> isPackEqualTo(
    bool value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 10, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 11, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 11, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 11, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 11, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 11, value: value),
      );
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterFilterCondition>
  createdAtBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 11, lower: lower, upper: upper),
      );
    });
  }
}

extension SubscriptionQueryObject
    on QueryBuilder<Subscription, Subscription, QFilterCondition> {}

extension SubscriptionQuerySortBy
    on QueryBuilder<Subscription, Subscription, QSortBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByAnchorMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByAnchorMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByAnchorDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByAnchorDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  sortByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByLeadDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByLeadDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByIsPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> sortByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension SubscriptionQuerySortThenBy
    on QueryBuilder<Subscription, Subscription, QSortThenBy> {
  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByTitleDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByTypeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByCalendarDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByModeDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByAnchorMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByAnchorMonthDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByAnchorDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByAnchorDayDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy>
  thenByIntervalDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByLeadDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByLeadDaysDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByActiveDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByIsPackDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(10, sort: Sort.desc);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterSortBy> thenByCreatedAtDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(11, sort: Sort.desc);
    });
  }
}

extension SubscriptionQueryWhereDistinct
    on QueryBuilder<Subscription, Subscription, QDistinct> {
  QueryBuilder<Subscription, Subscription, QAfterDistinct> distinctByTitle({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct> distinctByType() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByCalendar() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct> distinctByMode() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByAnchorMonth() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByAnchorDay() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByIntervalDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByLeadDays() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct> distinctByActive() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct> distinctByIsPack() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(10);
    });
  }

  QueryBuilder<Subscription, Subscription, QAfterDistinct>
  distinctByCreatedAt() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(11);
    });
  }
}

extension SubscriptionQueryProperty1
    on QueryBuilder<Subscription, Subscription, QProperty> {
  QueryBuilder<Subscription, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Subscription, String, QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Subscription, SubType, QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Subscription, Calendar, QAfterProperty> calendarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Subscription, TriggerMode, QAfterProperty> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Subscription, int?, QAfterProperty> anchorMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Subscription, int?, QAfterProperty> anchorDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Subscription, int?, QAfterProperty> intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Subscription, int, QAfterProperty> leadDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Subscription, bool, QAfterProperty> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Subscription, bool, QAfterProperty> isPackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<Subscription, DateTime, QAfterProperty> createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension SubscriptionQueryProperty2<R>
    on QueryBuilder<Subscription, R, QAfterProperty> {
  QueryBuilder<Subscription, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Subscription, (R, String), QAfterProperty> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Subscription, (R, SubType), QAfterProperty> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Subscription, (R, Calendar), QAfterProperty> calendarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Subscription, (R, TriggerMode), QAfterProperty> modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Subscription, (R, int?), QAfterProperty> anchorMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Subscription, (R, int?), QAfterProperty> anchorDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Subscription, (R, int?), QAfterProperty> intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Subscription, (R, int), QAfterProperty> leadDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Subscription, (R, bool), QAfterProperty> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Subscription, (R, bool), QAfterProperty> isPackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<Subscription, (R, DateTime), QAfterProperty>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}

extension SubscriptionQueryProperty3<R1, R2>
    on QueryBuilder<Subscription, (R1, R2), QAfterProperty> {
  QueryBuilder<Subscription, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<Subscription, (R1, R2, String), QOperations> titleProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<Subscription, (R1, R2, SubType), QOperations> typeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<Subscription, (R1, R2, Calendar), QOperations>
  calendarProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<Subscription, (R1, R2, TriggerMode), QOperations>
  modeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<Subscription, (R1, R2, int?), QOperations>
  anchorMonthProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<Subscription, (R1, R2, int?), QOperations> anchorDayProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<Subscription, (R1, R2, int?), QOperations>
  intervalDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<Subscription, (R1, R2, int), QOperations> leadDaysProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<Subscription, (R1, R2, bool), QOperations> activeProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }

  QueryBuilder<Subscription, (R1, R2, bool), QOperations> isPackProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(10);
    });
  }

  QueryBuilder<Subscription, (R1, R2, DateTime), QOperations>
  createdAtProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(11);
    });
  }
}
