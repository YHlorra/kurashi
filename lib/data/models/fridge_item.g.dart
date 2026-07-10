// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fridge_item.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetFridgeItemCollection on Isar {
  IsarCollection<int, FridgeItem> get fridgeItems => this.collection();
}

final FridgeItemSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'FridgeItem',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'name', type: IsarType.string),
      IsarPropertySchema(name: 'quantity', type: IsarType.string),
      IsarPropertySchema(name: 'addedDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'expiryDate', type: IsarType.dateTime),
      IsarPropertySchema(name: 'tag', type: IsarType.string),
      IsarPropertySchema(name: 'remainingPercent', type: IsarType.long),
      IsarPropertySchema(name: 'restockEnabled', type: IsarType.bool),
      IsarPropertySchema(name: 'restockThresholdPercent', type: IsarType.long),
      IsarPropertySchema(name: 'restockQty', type: IsarType.string),
    ],
    indexes: [],
  ),
  converter: IsarObjectConverter<int, FridgeItem>(
    serialize: serializeFridgeItem,
    deserialize: deserializeFridgeItem,
    deserializeProperty: deserializeFridgeItemProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeFridgeItem(IsarWriter writer, FridgeItem object) {
  IsarCore.writeString(writer, 1, object.name);
  IsarCore.writeString(writer, 2, object.quantity);
  IsarCore.writeLong(
    writer,
    3,
    object.addedDate.toUtc().microsecondsSinceEpoch,
  );
  IsarCore.writeLong(
    writer,
    4,
    object.expiryDate.toUtc().microsecondsSinceEpoch,
  );
  {
    final value = object.tag;
    if (value == null) {
      IsarCore.writeNull(writer, 5);
    } else {
      IsarCore.writeString(writer, 5, value);
    }
  }
  IsarCore.writeLong(writer, 6, object.remainingPercent);
  IsarCore.writeBool(writer, 7, value: object.restockEnabled);
  IsarCore.writeLong(writer, 8, object.restockThresholdPercent);
  IsarCore.writeString(writer, 9, object.restockQty);
  return object.id;
}

@isarProtected
FridgeItem deserializeFridgeItem(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final String _name;
  _name = IsarCore.readString(reader, 1) ?? '';
  final String _quantity;
  _quantity = IsarCore.readString(reader, 2) ?? '';
  final DateTime _addedDate;
  {
    final value = IsarCore.readLong(reader, 3);
    if (value == -9223372036854775808) {
      _addedDate = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _addedDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final DateTime _expiryDate;
  {
    final value = IsarCore.readLong(reader, 4);
    if (value == -9223372036854775808) {
      _expiryDate = DateTime.fromMillisecondsSinceEpoch(
        0,
        isUtc: true,
      ).toLocal();
    } else {
      _expiryDate = DateTime.fromMicrosecondsSinceEpoch(
        value,
        isUtc: true,
      ).toLocal();
    }
  }
  final String? _tag;
  _tag = IsarCore.readString(reader, 5);
  final int _remainingPercent;
  {
    final value = IsarCore.readLong(reader, 6);
    if (value == -9223372036854775808) {
      _remainingPercent = 100;
    } else {
      _remainingPercent = value;
    }
  }
  final bool _restockEnabled;
  _restockEnabled = IsarCore.readBool(reader, 7);
  final int _restockThresholdPercent;
  {
    final value = IsarCore.readLong(reader, 8);
    if (value == -9223372036854775808) {
      _restockThresholdPercent = 20;
    } else {
      _restockThresholdPercent = value;
    }
  }
  final String _restockQty;
  _restockQty = IsarCore.readString(reader, 9) ?? '';
  final object = FridgeItem(
    id: _id,
    name: _name,
    quantity: _quantity,
    addedDate: _addedDate,
    expiryDate: _expiryDate,
    tag: _tag,
    remainingPercent: _remainingPercent,
    restockEnabled: _restockEnabled,
    restockThresholdPercent: _restockThresholdPercent,
    restockQty: _restockQty,
  );
  return object;
}

@isarProtected
dynamic deserializeFridgeItemProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readString(reader, 1) ?? '';
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
        final value = IsarCore.readLong(reader, 4);
        if (value == -9223372036854775808) {
          return DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
        } else {
          return DateTime.fromMicrosecondsSinceEpoch(
            value,
            isUtc: true,
          ).toLocal();
        }
      }
    case 5:
      return IsarCore.readString(reader, 5);
    case 6:
      {
        final value = IsarCore.readLong(reader, 6);
        if (value == -9223372036854775808) {
          return 100;
        } else {
          return value;
        }
      }
    case 7:
      return IsarCore.readBool(reader, 7);
    case 8:
      {
        final value = IsarCore.readLong(reader, 8);
        if (value == -9223372036854775808) {
          return 20;
        } else {
          return value;
        }
      }
    case 9:
      return IsarCore.readString(reader, 9) ?? '';
    default:
      throw ArgumentError('Unknown property: $property');
  }
}

sealed class _FridgeItemUpdate {
  bool call({
    required int id,
    String? name,
    String? quantity,
    DateTime? addedDate,
    DateTime? expiryDate,
    String? tag,
    int? remainingPercent,
    bool? restockEnabled,
    int? restockThresholdPercent,
    String? restockQty,
  });
}

class _FridgeItemUpdateImpl implements _FridgeItemUpdate {
  const _FridgeItemUpdateImpl(this.collection);

  final IsarCollection<int, FridgeItem> collection;

  @override
  bool call({
    required int id,
    Object? name = ignore,
    Object? quantity = ignore,
    Object? addedDate = ignore,
    Object? expiryDate = ignore,
    Object? tag = ignore,
    Object? remainingPercent = ignore,
    Object? restockEnabled = ignore,
    Object? restockThresholdPercent = ignore,
    Object? restockQty = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (name != ignore) 1: name as String?,
            if (quantity != ignore) 2: quantity as String?,
            if (addedDate != ignore) 3: addedDate as DateTime?,
            if (expiryDate != ignore) 4: expiryDate as DateTime?,
            if (tag != ignore) 5: tag as String?,
            if (remainingPercent != ignore) 6: remainingPercent as int?,
            if (restockEnabled != ignore) 7: restockEnabled as bool?,
            if (restockThresholdPercent != ignore)
              8: restockThresholdPercent as int?,
            if (restockQty != ignore) 9: restockQty as String?,
          },
        ) >
        0;
  }
}

sealed class _FridgeItemUpdateAll {
  int call({
    required List<int> id,
    String? name,
    String? quantity,
    DateTime? addedDate,
    DateTime? expiryDate,
    String? tag,
    int? remainingPercent,
    bool? restockEnabled,
    int? restockThresholdPercent,
    String? restockQty,
  });
}

class _FridgeItemUpdateAllImpl implements _FridgeItemUpdateAll {
  const _FridgeItemUpdateAllImpl(this.collection);

  final IsarCollection<int, FridgeItem> collection;

  @override
  int call({
    required List<int> id,
    Object? name = ignore,
    Object? quantity = ignore,
    Object? addedDate = ignore,
    Object? expiryDate = ignore,
    Object? tag = ignore,
    Object? remainingPercent = ignore,
    Object? restockEnabled = ignore,
    Object? restockThresholdPercent = ignore,
    Object? restockQty = ignore,
  }) {
    return collection.updateProperties(id, {
      if (name != ignore) 1: name as String?,
      if (quantity != ignore) 2: quantity as String?,
      if (addedDate != ignore) 3: addedDate as DateTime?,
      if (expiryDate != ignore) 4: expiryDate as DateTime?,
      if (tag != ignore) 5: tag as String?,
      if (remainingPercent != ignore) 6: remainingPercent as int?,
      if (restockEnabled != ignore) 7: restockEnabled as bool?,
      if (restockThresholdPercent != ignore) 8: restockThresholdPercent as int?,
      if (restockQty != ignore) 9: restockQty as String?,
    });
  }
}

extension FridgeItemUpdate on IsarCollection<int, FridgeItem> {
  _FridgeItemUpdate get update => _FridgeItemUpdateImpl(this);

  _FridgeItemUpdateAll get updateAll => _FridgeItemUpdateAllImpl(this);
}

sealed class _FridgeItemQueryUpdate {
  int call({
    String? name,
    String? quantity,
    DateTime? addedDate,
    DateTime? expiryDate,
    String? tag,
    int? remainingPercent,
    bool? restockEnabled,
    int? restockThresholdPercent,
    String? restockQty,
  });
}

class _FridgeItemQueryUpdateImpl implements _FridgeItemQueryUpdate {
  const _FridgeItemQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<FridgeItem> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? quantity = ignore,
    Object? addedDate = ignore,
    Object? expiryDate = ignore,
    Object? tag = ignore,
    Object? remainingPercent = ignore,
    Object? restockEnabled = ignore,
    Object? restockThresholdPercent = ignore,
    Object? restockQty = ignore,
  }) {
    return query.updateProperties(limit: limit, {
      if (name != ignore) 1: name as String?,
      if (quantity != ignore) 2: quantity as String?,
      if (addedDate != ignore) 3: addedDate as DateTime?,
      if (expiryDate != ignore) 4: expiryDate as DateTime?,
      if (tag != ignore) 5: tag as String?,
      if (remainingPercent != ignore) 6: remainingPercent as int?,
      if (restockEnabled != ignore) 7: restockEnabled as bool?,
      if (restockThresholdPercent != ignore) 8: restockThresholdPercent as int?,
      if (restockQty != ignore) 9: restockQty as String?,
    });
  }
}

extension FridgeItemQueryUpdate on IsarQuery<FridgeItem> {
  _FridgeItemQueryUpdate get updateFirst =>
      _FridgeItemQueryUpdateImpl(this, limit: 1);

  _FridgeItemQueryUpdate get updateAll => _FridgeItemQueryUpdateImpl(this);
}

class _FridgeItemQueryBuilderUpdateImpl implements _FridgeItemQueryUpdate {
  const _FridgeItemQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<FridgeItem, FridgeItem, QOperations> query;
  final int? limit;

  @override
  int call({
    Object? name = ignore,
    Object? quantity = ignore,
    Object? addedDate = ignore,
    Object? expiryDate = ignore,
    Object? tag = ignore,
    Object? remainingPercent = ignore,
    Object? restockEnabled = ignore,
    Object? restockThresholdPercent = ignore,
    Object? restockQty = ignore,
  }) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (name != ignore) 1: name as String?,
        if (quantity != ignore) 2: quantity as String?,
        if (addedDate != ignore) 3: addedDate as DateTime?,
        if (expiryDate != ignore) 4: expiryDate as DateTime?,
        if (tag != ignore) 5: tag as String?,
        if (remainingPercent != ignore) 6: remainingPercent as int?,
        if (restockEnabled != ignore) 7: restockEnabled as bool?,
        if (restockThresholdPercent != ignore)
          8: restockThresholdPercent as int?,
        if (restockQty != ignore) 9: restockQty as String?,
      });
    } finally {
      q.close();
    }
  }
}

extension FridgeItemQueryBuilderUpdate
    on QueryBuilder<FridgeItem, FridgeItem, QOperations> {
  _FridgeItemQueryUpdate get updateFirst =>
      _FridgeItemQueryBuilderUpdateImpl(this, limit: 1);

  _FridgeItemQueryUpdate get updateAll =>
      _FridgeItemQueryBuilderUpdateImpl(this);
}

extension FridgeItemQueryFilter
    on QueryBuilder<FridgeItem, FridgeItem, QFilterCondition> {
  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameGreaterThan(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  nameGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 1, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  nameLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameBetween(
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameEndsWith(
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameContains(
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameMatches(
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> nameIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 1, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityGreaterThan(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityLessThan(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 2, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityStartsWith(String value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> quantityMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  quantityIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 2, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> addedDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  addedDateGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  addedDateGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> addedDateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 3, value: value));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  addedDateLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 3, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> addedDateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 3, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> expiryDateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  expiryDateGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  expiryDateGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  expiryDateLessThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 4, value: value));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  expiryDateLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 4, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> expiryDateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 4, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagIsNull() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagIsNotNull() {
    return QueryBuilder.apply(not(), (query) {
      return query.addFilterCondition(const IsNullCondition(property: 5));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagEqualTo(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagGreaterThan(
    String? value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  tagGreaterThanOrEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagLessThan(
    String? value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 5, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  tagLessThanOrEqualTo(String? value, {bool caseSensitive = true}) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagBetween(
    String? lower,
    String? upper, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagStartsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagEndsWith(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagContains(
    String value, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
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

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> tagIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 5, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 6, value: value));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 6, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  remainingPercentBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 6, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockEnabledEqualTo(bool value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 7, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 8, value: value));
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 8, value: value),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockThresholdPercentBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 8, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> restockQtyEqualTo(
    String value, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyGreaterThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyGreaterThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyLessThan(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessCondition(property: 9, value: value, caseSensitive: caseSensitive),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyLessThanOrEqualTo(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> restockQtyBetween(
    String lower,
    String upper, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(
          property: 9,
          lower: lower,
          upper: upper,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyStartsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        StartsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyEndsWith(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EndsWithCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyContains(String value, {bool caseSensitive = true}) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        ContainsCondition(
          property: 9,
          value: value,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition> restockQtyMatches(
    String pattern, {
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        MatchesCondition(
          property: 9,
          wildcard: pattern,
          caseSensitive: caseSensitive,
        ),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyIsEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const EqualCondition(property: 9, value: ''),
      );
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterFilterCondition>
  restockQtyIsNotEmpty() {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        const GreaterCondition(property: 9, value: ''),
      );
    });
  }
}

extension FridgeItemQueryObject
    on QueryBuilder<FridgeItem, FridgeItem, QFilterCondition> {}

extension FridgeItemQuerySortBy
    on QueryBuilder<FridgeItem, FridgeItem, QSortBy> {
  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByQuantity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByQuantityDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByAddedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByAddedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByTag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByTagDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByRemainingPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  sortByRemainingPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByRestockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  sortByRestockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  sortByRestockThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  sortByRestockThresholdPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByRestockQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> sortByRestockQtyDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension FridgeItemQuerySortThenBy
    on QueryBuilder<FridgeItem, FridgeItem, QSortThenBy> {
  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByNameDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByQuantity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByQuantityDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByAddedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByAddedDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(3, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByExpiryDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(4, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByTag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByTagDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(5, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByRemainingPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  thenByRemainingPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(6, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByRestockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  thenByRestockEnabledDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(7, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  thenByRestockThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy>
  thenByRestockThresholdPercentDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(8, sort: Sort.desc);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByRestockQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterSortBy> thenByRestockQtyDesc({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(9, sort: Sort.desc, caseSensitive: caseSensitive);
    });
  }
}

extension FridgeItemQueryWhereDistinct
    on QueryBuilder<FridgeItem, FridgeItem, QDistinct> {
  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByName({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByQuantity({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByAddedDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(3);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByExpiryDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(4);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByTag({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(5, caseSensitive: caseSensitive);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct>
  distinctByRemainingPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(6);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct>
  distinctByRestockEnabled() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(7);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct>
  distinctByRestockThresholdPercent() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(8);
    });
  }

  QueryBuilder<FridgeItem, FridgeItem, QAfterDistinct> distinctByRestockQty({
    bool caseSensitive = true,
  }) {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(9, caseSensitive: caseSensitive);
    });
  }
}

extension FridgeItemQueryProperty1
    on QueryBuilder<FridgeItem, FridgeItem, QProperty> {
  QueryBuilder<FridgeItem, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeItem, String, QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeItem, String, QAfterProperty> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeItem, DateTime, QAfterProperty> addedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeItem, DateTime, QAfterProperty> expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeItem, String?, QAfterProperty> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeItem, int, QAfterProperty> remainingPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeItem, bool, QAfterProperty> restockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeItem, int, QAfterProperty>
  restockThresholdPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FridgeItem, String, QAfterProperty> restockQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension FridgeItemQueryProperty2<R>
    on QueryBuilder<FridgeItem, R, QAfterProperty> {
  QueryBuilder<FridgeItem, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeItem, (R, String), QAfterProperty> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeItem, (R, String), QAfterProperty> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeItem, (R, DateTime), QAfterProperty> addedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeItem, (R, DateTime), QAfterProperty> expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeItem, (R, String?), QAfterProperty> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeItem, (R, int), QAfterProperty>
  remainingPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeItem, (R, bool), QAfterProperty> restockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeItem, (R, int), QAfterProperty>
  restockThresholdPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FridgeItem, (R, String), QAfterProperty> restockQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}

extension FridgeItemQueryProperty3<R1, R2>
    on QueryBuilder<FridgeItem, (R1, R2), QAfterProperty> {
  QueryBuilder<FridgeItem, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, String), QOperations> nameProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, String), QOperations> quantityProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, DateTime), QOperations>
  addedDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(3);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, DateTime), QOperations>
  expiryDateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(4);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, String?), QOperations> tagProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(5);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, int), QOperations>
  remainingPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(6);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, bool), QOperations>
  restockEnabledProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(7);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, int), QOperations>
  restockThresholdPercentProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(8);
    });
  }

  QueryBuilder<FridgeItem, (R1, R2, String), QOperations> restockQtyProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(9);
    });
  }
}
