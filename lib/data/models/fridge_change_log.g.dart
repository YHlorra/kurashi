// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_change_log.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFridgeChangeLogCollection on Isar {
  IsarCollection<int, FridgeChangeLog> get fridgeChangeLogs =>
      this.collection();
}

final FridgeChangeLogSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FridgeChangeLog',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'itemId', type: IsarType.long),
      IsarPropertySchema(name: 'itemName', type: IsarType.string),
      IsarPropertySchema(name: 'timestamp', type: IsarType.dateTime),
      IsarPropertySchema(
        name: 'action',
        type: IsarType.byte,

        enumMap: {"add": 0, "update": 1, "delete": 2, "restore": 3},
      ),
      IsarPropertySchema(name: 'beforeQty', type: IsarType.string),
      IsarPropertySchema(name: 'afterQty', type: IsarType.string),
      IsarPropertySchema(name: 'beforeExpiry', type: IsarType.dateTime),
      IsarPropertySchema(name: 'afterExpiry', type: IsarType.dateTime),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, FridgeChangeLog>(
    serialize: serializeFridgeChangeLog,
    deserialize: deserializeFridgeChangeLog,
    deserializeProperty: deserializeFridgeChangeLogProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeFridgeChangeLog(IsarWriter writer, FridgeChangeLog object) {
  IsarCore.writeLong(writer, 1, object.itemId);
  IsarCore.writeString(writer, 2, object.itemName);
  IsarCore.writeLong(
    writer,
    3,
    object.timestamp.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeByte(writer, 4, object.action.index);
  IsarCore.writeString(writer, 5, object.beforeQty);
  IsarCore.writeString(writer, 6, object.afterQty);
  IsarCore.writeLong(
    writer,
    7,
    object.beforeExpiry.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeLong(
    writer,
    8,
    object.afterExpiry.toUtc().microsecondsSinceEpoch,
  );
  return object.id;
}

@isarProtected
FridgeChangeLog deserializeFridgeChangeLog(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final int _itemId;
  _itemId = IsarCore.readLong(reader, 1);
  final String _itemName;
  _itemName = IsarCore.readString(reader, 2) ?? '';
  final DateTime _timestamp;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _timestamp = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _timestamp = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final FridgeAction _action;
  {
    if (IsarCore.readNull(reader, 4)) {
      _action = FridgeAction.add;
    } else {
      _action =
          _fridgeChangeLogAction[IsarCore.readByte(reader, 4)] ??
          FridgeAction.add;
    }
  }
  final String _beforeQty;
  _beforeQty = IsarCore.readString(reader, 5) ?? '';
  final String _afterQty;
  _afterQty = IsarCore.readString(reader, 6) ?? '';
  final DateTime _beforeExpiry;
  {
    final value = IsarCore.readLong(reader, 7);
    if (value == -9223372036854775808) {
      _beforeExpiry = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _beforeExpiry = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final DateTime _afterExpiry;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _afterExpiry = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _afterExpiry = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final object = FridgeChangeLog(
    id: _id,
    itemId: _itemId,
    itemName: _itemName,
    timestamp: _timestamp,
    action: _action,
    beforeQty: _beforeQty,
    afterQty: _afterQty,
    beforeExpiry: _beforeExpiry,
    afterExpiry: _afterExpiry,
  );
  return object;
}

@isarProtected
dynamic deserializeFridgeChangeLogProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readLong(reader, 1);
    case 2:
      return IsarCore.readString(reader, 2) ?? '';
    case 3:
      {
        final value = IsarCore.readLong(reader, 3);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 4:
      {
        if (IsarCore.readNull(reader, 4)) {
          return FridgeAction.add;
        } else {
          return _fridgeChangeLogAction[IsarCore.readByte(reader, 4)] ??
              FridgeAction.add;
        }
      }
    case 5:
      return IsarCore.readString(reader, 5) ?? '';
    case 6:
      return IsarCore.readString(reader, 6) ?? '';
    case 7:
      {
        final value = IsarCore.readLong(reader, 7);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
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

sealed class _FridgeChangeLogUpdate {
  bool call({
    required int id,
    int? itemId,
    String? itemName,
    DateTime? timestamp,
    FridgeAction? action,
    String? beforeQty,
    String? afterQty,
    DateTime? beforeExpiry,
    DateTime? afterExpiry,
  });
}

class _FridgeChangeLogUpdateImpl implements _FridgeChangeLogUpdate {
  const _FridgeChangeLogUpdateImpl(this.collection);

  final IsarCollection<int, FridgeChangeLog> collection;

  @override
  bool call({
    required int id,
    Object? itemId = ignore,
    Object? itemName = ignore,
    Object? timestamp = ignore,
    Object? action = ignore,
    Object? beforeQty = ignore,
    Object? afterQty = ignore,
    Object? beforeExpiry = ignore,
    Object? afterExpiry = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (itemId != ignore) 1: itemId as int?,
            if (itemName != ignore) 2: itemName as String?,
            if (timestamp != ignore) 3: timestamp as DateTime?,
            if (action != ignore) 4: action as FridgeAction?,
            if (beforeQty != ignore) 5: beforeQty as String?,
            if (afterQty != ignore) 6: afterQty as String?,
            if (beforeExpiry != ignore) 7: beforeExpiry as DateTime?,
            if (afterExpiry != ignore) 8: afterExpiry as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _FridgeChangeLogUpdateAll {
  int call({
    required List<int> id,
    int? itemId,
    String? itemName,
    DateTime? timestamp,
    FridgeAction? action,
    String? beforeQty,
    String? afterQty,
    DateTime? beforeExpiry,
    DateTime? afterExpiry,
  });
}

class _FridgeChangeLogUpdateAllImpl implements _FridgeChangeLogUpdateAll {
  const _FridgeChangeLogUpdateAllImpl(this.collection);

  final IsarCollection<int, FridgeChangeLog> collection;

  @override
  int call({
    required List<int> id,
    Object? itemId = ignore,
    Object? itemName = ignore,
    Object? timestamp = ignore,
    Object? action = ignore,
    Object? beforeQty = ignore,
    Object? afterQty = ignore,
    Object? beforeExpiry = ignore,
    Object? afterExpiry = ignore,
  }) {
    return collection.updateProperties(id, {
      if (itemId != ignore) 1: itemId as int?,
      if (itemName != ignore) 2: itemName as String?,
      if (timestamp != ignore) 3: timestamp as DateTime?,
      if (action != ignore) 4: action as FridgeAction?,
      if (beforeQty != ignore) 5: beforeQty as String?,
      if (afterQty != ignore) 6: afterQty as String?,
      if (beforeExpiry != ignore) 7: beforeExpiry as DateTime?,
      if (afterExpiry != ignore) 8: afterExpiry as DateTime?,
    });
  }
}

extension FridgeChangeLogUpdate on IsarCollection<int, FridgeChangeLog> {
  _FridgeChangeLogUpdate get update => _FridgeChangeLogUpdateImpl(this);

  _FridgeChangeLogUpdateAll get updateAll =>
      _FridgeChangeLogUpdateAllImpl(this);
}

sealed class _FridgeChangeLogQueryUpdate {
  int call({
    int? itemId,
    String? itemName,
    DateTime? timestamp,
    FridgeAction? action,
    String? beforeQty,
    String? afterQty,
    DateTime? beforeExpiry,
    DateTime? afterExpiry,
  });
}

class _FridgeChangeLogQueryUpdateImpl implements _FridgeChangeLogQueryUpdate {
  const _FridgeChangeLogQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FridgeChangeLog> query;
  final int? limit;

  @override
  int call({
    Object? itemId = ignore,
    Object? itemName = ignore,
    Object? timestamp = ignore,
    Object? action = ignore,
    Object? beforeQty = ignore,
    Object? afterQty = ignore,
    Object? beforeExpiry = ignore,
    Object? afterExpiry = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (itemId != ignore) 1: itemId as int?,
      if (itemName != ignore) 2: itemName as String?,
      if (timestamp != ignore) 3: timestamp as DateTime?,
      if (action != ignore) 4: action as FridgeAction?,
      if (beforeQty != ignore) 5: beforeQty as String?,
      if (afterQty != ignore) 6: afterQty as String?,
      if (beforeExpiry != ignore) 7: beforeExpiry as DateTime?,
      if (afterExpiry != ignore) 8: afterExpiry as DateTime?,
    });
  }
}

extension FridgeChangeLogQueryUpdate on IsarQuery<FridgeChangeLog> {
  _FridgeChangeLogQueryUpdate get updateFirst =>
      _FridgeChangeLogQueryUpdateImpl(this, limit: 1);

  _FridgeChangeLogQueryUpdate get updateAll =>
      _FridgeChangeLogQueryUpdateImpl(this);
}

class _FridgeChangeLogQueryBuilderUpdateImpl
    implements _FridgeChangeLogQueryUpdate {
  const _FridgeChangeLogQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FridgeChangeLog, FridgeChangeLog, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? itemId = ignore,
    Object? itemName = ignore,
    Object? timestamp = ignore,
    Object? action = ignore,
    Object? beforeQty = ignore,
    Object? afterQty = ignore,
    Object? beforeExpiry = ignore,
    Object? afterExpiry = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (itemId != ignore) 1: itemId as int?,
        if (itemName != ignore) 2: itemName as String?,
        if (timestamp != ignore) 3: timestamp as DateTime?,
        if (action != ignore) 4: action as FridgeAction?,
        if (beforeQty != ignore) 5: beforeQty as String?,
        if (afterQty != ignore) 6: afterQty as String?,
        if (beforeExpiry != ignore) 7: beforeExpiry as DateTime?,
        if (afterExpiry != ignore) 8: afterExpiry as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension FridgeChangeLogQueryBuilderUpdate
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QOperations> {
  _FridgeChangeLogQueryUpdate get updateFirst =>
      _FridgeChangeLogQueryBuilderUpdateImpl(this, limit: 1);

  _FridgeChangeLogQueryUpdate get updateAll =>
      _FridgeChangeLogQueryBuilderUpdateImpl(this);
}

const _fridgeChangeLogAction = {
  0: FridgeAction.add,
  1: FridgeAction.update,
  2: FridgeAction.delete,
  3: FridgeAction.restore,
};

extension FridgeChangeLogQueryFilter
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QFilterCondition> {
  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  idBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 1, value: value));
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemIdBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 1, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 2,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 2,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 2,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  itemNameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  timestampBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionEqualTo(FridgeAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionGreaterThan(FridgeAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionGreaterThanOrEqualTo(FridgeAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionLessThan(FridgeAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionLessThanOrEqualTo(FridgeAction value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  actionBetween(FridgeAction lower, FridgeAction upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower.index, upper: upper.index),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 5,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 5,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 5,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeQtyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 6, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyBetween(String lower, String upper, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 6,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 6,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyMatches(String pattern, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 6,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterQtyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 6, value: ''),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 7, value: value));
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  beforeExpiryBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 7, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 8, value: value));
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterFilterCondition>
  afterExpiryBetween(DateTime lower, DateTime upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower, upper: upper),
      );
    });
  }
}

extension FridgeChangeLogQueryObject
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QFilterCondition> {}

extension FridgeChangeLogQuerySortBy
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QSortBy> {
  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByItemName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByItemNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByBeforeQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByBeforeQtyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> sortByAfterQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByAfterQtyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByBeforeExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByBeforeExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByAfterExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  sortByAfterExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension FridgeChangeLogQuerySortThenBy
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QSortThenBy> {
  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByItemIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByItemName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByItemNameDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByTimestampDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByActionDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByBeforeQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByBeforeQtyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy> thenByAfterQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByAfterQtyDesc({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByBeforeExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByBeforeExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByAfterExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterSortBy>
  thenByAfterExpiryDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }
}

extension FridgeChangeLogQueryWhereDistinct
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QDistinct> {
  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByItemId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByItemName({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByTimestamp() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByAction() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByBeforeQty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByAfterQty({bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByBeforeExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeChangeLog, QAfterDistinct>
  distinctByAfterExpiry() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }
}

extension FridgeChangeLogQueryProperty1
    on QueryBuilder<FridgeChangeLog, FridgeChangeLog, QProperty> {
  QueryBuilder<FridgeChangeLog, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeChangeLog, int, QAfterProperty> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeChangeLog, String, QAfterProperty> itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeChangeLog, DateTime, QAfterProperty> timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeChangeLog, FridgeAction, QAfterProperty> actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeChangeLog, String, QAfterProperty> beforeQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeChangeLog, String, QAfterProperty> afterQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeChangeLog, DateTime, QAfterProperty>
  beforeExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeChangeLog, DateTime, QAfterProperty>
  afterExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension FridgeChangeLogQueryProperty2<R>
    on QueryBuilder<FridgeChangeLog, R, QAfterProperty> {
  QueryBuilder<FridgeChangeLog, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, int), QAfterProperty> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, String), QAfterProperty>
  itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, DateTime), QAfterProperty>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, FridgeAction), QAfterProperty>
  actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, String), QAfterProperty>
  beforeQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, String), QAfterProperty>
  afterQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, DateTime), QAfterProperty>
  beforeExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeChangeLog, (R, DateTime), QAfterProperty>
  afterExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}

extension FridgeChangeLogQueryProperty3<R1, R2>
    on QueryBuilder<FridgeChangeLog, (R1, R2), QAfterProperty> {
  QueryBuilder<FridgeChangeLog, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, int), QOperations> itemIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, String), QOperations>
  itemNameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, DateTime), QOperations>
  timestampProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, FridgeAction), QOperations>
  actionProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, String), QOperations>
  beforeQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, String), QOperations>
  afterQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, DateTime), QOperations>
  beforeExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeChangeLog, (R1, R2, DateTime), QOperations>
  afterExpiryProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }
}
