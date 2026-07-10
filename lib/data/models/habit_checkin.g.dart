// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'habit_checkin.dart';

// **************************************************************************
// _IsarCollectionGenerator
// **************************************************************************

// coverage:ignore-file
// ignore_for_file: duplicate_ignore, invalid_use_of_protected_member, lines_longer_than_80_chars, constant_identifier_names, avoid_js_rounded_ints, no_leading_underscores_for_local_identifiers, require_trailing_commas, unnecessary_parenthesis, unnecessary_raw_strings, unnecessary_null_in_if_null_operators, library_private_types_in_public_api, prefer_const_constructors
// ignore_for_file: type=lint

extension GetHabitCheckinCollection on Isar {
  IsarCollection<int, HabitCheckin> get habitCheckins => this.collection();
}

final HabitCheckinSchema = IsarGeneratedSchema(
  schema: IsarSchema(
    name: 'HabitCheckin',
    idName: 'id',
    embedded: false,
    properties: [
      IsarPropertySchema(name: 'habitId', type: IsarType.long),
      IsarPropertySchema(name: 'date', type: IsarType.dateTime),
    ],
    indexes: [
      IsarIndexSchema(
        name: 'habitId',
        properties: ["habitId"],
        unique: false,
        hash: false,
      ),
    ],
  ),
  converter: IsarObjectConverter<int, HabitCheckin>(
    serialize: serializeHabitCheckin,
    deserialize: deserializeHabitCheckin,
    deserializeProperty: deserializeHabitCheckinProp,
  ),
  getEmbeddedSchemas: () => [],
);

@isarProtected
int serializeHabitCheckin(IsarWriter writer, HabitCheckin object) {
  IsarCore.writeLong(writer, 1, object.habitId);
  IsarCore.writeLong(writer, 2, object.date.toUtc().microsecondsSinceEpoch);
  return object.id;
}

@isarProtected
HabitCheckin deserializeHabitCheckin(IsarReader reader) {
  final int _id;
  _id = IsarCore.readId(reader);
  final int _habitId;
  _habitId = IsarCore.readLong(reader, 1);
  final DateTime _date;
  {
    final value = IsarCore.readLong(reader, 2);
    if (value == -9223372036854775808) {
      _date = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true).toLocal();
    } else {
      _date = DateTime.fromMicrosecondsSinceEpoch(value, isUtc: true).toLocal();
    }
  }
  final object = HabitCheckin(id: _id, habitId: _habitId, date: _date);
  return object;
}

@isarProtected
dynamic deserializeHabitCheckinProp(IsarReader reader, int property) {
  switch (property) {
    case 0:
      return IsarCore.readId(reader);
    case 1:
      return IsarCore.readLong(reader, 1);
    case 2:
      {
        final value = IsarCore.readLong(reader, 2);
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

sealed class _HabitCheckinUpdate {
  bool call({required int id, int? habitId, DateTime? date});
}

class _HabitCheckinUpdateImpl implements _HabitCheckinUpdate {
  const _HabitCheckinUpdateImpl(this.collection);

  final IsarCollection<int, HabitCheckin> collection;

  @override
  bool call({
    required int id,
    Object? habitId = ignore,
    Object? date = ignore,
  }) {
    return collection.updateProperties(
          [id],
          {
            if (habitId != ignore) 1: habitId as int?,
            if (date != ignore) 2: date as DateTime?,
          },
        ) >
        0;
  }
}

sealed class _HabitCheckinUpdateAll {
  int call({required List<int> id, int? habitId, DateTime? date});
}

class _HabitCheckinUpdateAllImpl implements _HabitCheckinUpdateAll {
  const _HabitCheckinUpdateAllImpl(this.collection);

  final IsarCollection<int, HabitCheckin> collection;

  @override
  int call({
    required List<int> id,
    Object? habitId = ignore,
    Object? date = ignore,
  }) {
    return collection.updateProperties(id, {
      if (habitId != ignore) 1: habitId as int?,
      if (date != ignore) 2: date as DateTime?,
    });
  }
}

extension HabitCheckinUpdate on IsarCollection<int, HabitCheckin> {
  _HabitCheckinUpdate get update => _HabitCheckinUpdateImpl(this);

  _HabitCheckinUpdateAll get updateAll => _HabitCheckinUpdateAllImpl(this);
}

sealed class _HabitCheckinQueryUpdate {
  int call({int? habitId, DateTime? date});
}

class _HabitCheckinQueryUpdateImpl implements _HabitCheckinQueryUpdate {
  const _HabitCheckinQueryUpdateImpl(this.query, {this.limit});

  final IsarQuery<HabitCheckin> query;
  final int? limit;

  @override
  int call({Object? habitId = ignore, Object? date = ignore}) {
    return query.updateProperties(limit: limit, {
      if (habitId != ignore) 1: habitId as int?,
      if (date != ignore) 2: date as DateTime?,
    });
  }
}

extension HabitCheckinQueryUpdate on IsarQuery<HabitCheckin> {
  _HabitCheckinQueryUpdate get updateFirst =>
      _HabitCheckinQueryUpdateImpl(this, limit: 1);

  _HabitCheckinQueryUpdate get updateAll => _HabitCheckinQueryUpdateImpl(this);
}

class _HabitCheckinQueryBuilderUpdateImpl implements _HabitCheckinQueryUpdate {
  const _HabitCheckinQueryBuilderUpdateImpl(this.query, {this.limit});

  final QueryBuilder<HabitCheckin, HabitCheckin, QOperations> query;
  final int? limit;

  @override
  int call({Object? habitId = ignore, Object? date = ignore}) {
    final q = query.build();
    try {
      return q.updateProperties(limit: limit, {
        if (habitId != ignore) 1: habitId as int?,
        if (date != ignore) 2: date as DateTime?,
      });
    } finally {
      q.close();
    }
  }
}

extension HabitCheckinQueryBuilderUpdate
    on QueryBuilder<HabitCheckin, HabitCheckin, QOperations> {
  _HabitCheckinQueryUpdate get updateFirst =>
      _HabitCheckinQueryBuilderUpdateImpl(this, limit: 1);

  _HabitCheckinQueryUpdate get updateAll =>
      _HabitCheckinQueryBuilderUpdateImpl(this);
}

extension HabitCheckinQueryFilter
    on QueryBuilder<HabitCheckin, HabitCheckin, QFilterCondition> {
  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> idEqualTo(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> idGreaterThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  idGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> idLessThan(
    int value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 0, value: value));
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  idLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 0, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> idBetween(
    int lower,
    int upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 0, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdGreaterThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdGreaterThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdLessThan(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 1, value: value));
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdLessThanOrEqualTo(int value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 1, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  habitIdBetween(int lower, int upper) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 1, lower: lower, upper: upper),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> dateEqualTo(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        EqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  dateGreaterThan(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  dateGreaterThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        GreaterOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> dateLessThan(
    DateTime value,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(LessCondition(property: 2, value: value));
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition>
  dateLessThanOrEqualTo(DateTime value) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        LessOrEqualCondition(property: 2, value: value),
      );
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterFilterCondition> dateBetween(
    DateTime lower,
    DateTime upper,
  ) {
    return QueryBuilder.apply(this, (query) {
      return query.addFilterCondition(
        BetweenCondition(property: 2, lower: lower, upper: upper),
      );
    });
  }
}

extension HabitCheckinQueryObject
    on QueryBuilder<HabitCheckin, HabitCheckin, QFilterCondition> {}

extension HabitCheckinQuerySortBy
    on QueryBuilder<HabitCheckin, HabitCheckin, QSortBy> {
  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortByHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortByHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> sortByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension HabitCheckinQuerySortThenBy
    on QueryBuilder<HabitCheckin, HabitCheckin, QSortThenBy> {
  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenById() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenByIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(0, sort: Sort.desc);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenByHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenByHabitIdDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(1, sort: Sort.desc);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterSortBy> thenByDateDesc() {
    return QueryBuilder.apply(this, (query) {
      return query.addSortBy(2, sort: Sort.desc);
    });
  }
}

extension HabitCheckinQueryWhereDistinct
    on QueryBuilder<HabitCheckin, HabitCheckin, QDistinct> {
  QueryBuilder<HabitCheckin, HabitCheckin, QAfterDistinct> distinctByHabitId() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(1);
    });
  }

  QueryBuilder<HabitCheckin, HabitCheckin, QAfterDistinct> distinctByDate() {
    return QueryBuilder.apply(this, (query) {
      return query.addDistinctBy(2);
    });
  }
}

extension HabitCheckinQueryProperty1
    on QueryBuilder<HabitCheckin, HabitCheckin, QProperty> {
  QueryBuilder<HabitCheckin, int, QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HabitCheckin, int, QAfterProperty> habitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HabitCheckin, DateTime, QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension HabitCheckinQueryProperty2<R>
    on QueryBuilder<HabitCheckin, R, QAfterProperty> {
  QueryBuilder<HabitCheckin, (R, int), QAfterProperty> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HabitCheckin, (R, int), QAfterProperty> habitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HabitCheckin, (R, DateTime), QAfterProperty> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}

extension HabitCheckinQueryProperty3<R1, R2>
    on QueryBuilder<HabitCheckin, (R1, R2), QAfterProperty> {
  QueryBuilder<HabitCheckin, (R1, R2, int), QOperations> idProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(0);
    });
  }

  QueryBuilder<HabitCheckin, (R1, R2, int), QOperations> habitIdProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(1);
    });
  }

  QueryBuilder<HabitCheckin, (R1, R2, DateTime), QOperations> dateProperty() {
    return QueryBuilder.apply(this, (query) {
      return query.addProperty(2);
    });
  }
}
