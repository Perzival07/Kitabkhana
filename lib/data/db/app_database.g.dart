// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LocationsTable extends Locations
    with TableInfo<$LocationsTable, LocationRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES locations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    name,
    parentId,
    sortOrder,
    icon,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'locations';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocationRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocationRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocationRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
      icon: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon'],
      ),
    );
  }

  @override
  $LocationsTable createAlias(String alias) {
    return $LocationsTable(attachedDatabase, alias);
  }
}

class LocationRow extends DataClass implements Insertable<LocationRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String name;
  final String? parentId;
  final int sortOrder;
  final String? icon;
  const LocationRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.name,
    this.parentId,
    required this.sortOrder,
    this.icon,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['sort_order'] = Variable<int>(sortOrder);
    if (!nullToAbsent || icon != null) {
      map['icon'] = Variable<String>(icon);
    }
    return map;
  }

  LocationsCompanion toCompanion(bool nullToAbsent) {
    return LocationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      name: Value(name),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      sortOrder: Value(sortOrder),
      icon: icon == null && nullToAbsent ? const Value.absent() : Value(icon),
    );
  }

  factory LocationRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocationRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      name: serializer.fromJson<String>(json['name']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
      icon: serializer.fromJson<String?>(json['icon']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'name': serializer.toJson<String>(name),
      'parentId': serializer.toJson<String?>(parentId),
      'sortOrder': serializer.toJson<int>(sortOrder),
      'icon': serializer.toJson<String?>(icon),
    };
  }

  LocationRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? name,
    Value<String?> parentId = const Value.absent(),
    int? sortOrder,
    Value<String?> icon = const Value.absent(),
  }) => LocationRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    name: name ?? this.name,
    parentId: parentId.present ? parentId.value : this.parentId,
    sortOrder: sortOrder ?? this.sortOrder,
    icon: icon.present ? icon.value : this.icon,
  );
  LocationRow copyWithCompanion(LocationsCompanion data) {
    return LocationRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      name: data.name.present ? data.name.value : this.name,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
      icon: data.icon.present ? data.icon.value : this.icon,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocationRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    name,
    parentId,
    sortOrder,
    icon,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocationRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.name == this.name &&
          other.parentId == this.parentId &&
          other.sortOrder == this.sortOrder &&
          other.icon == this.icon);
}

class LocationsCompanion extends UpdateCompanion<LocationRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> name;
  final Value<String?> parentId;
  final Value<int> sortOrder;
  final Value<String?> icon;
  final Value<int> rowid;
  const LocationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.name = const Value.absent(),
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocationsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String name,
    this.parentId = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.icon = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<LocationRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? name,
    Expression<String>? parentId,
    Expression<int>? sortOrder,
    Expression<String>? icon,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (name != null) 'name': name,
      if (parentId != null) 'parent_id': parentId,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (icon != null) 'icon': icon,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? name,
    Value<String?>? parentId,
    Value<int>? sortOrder,
    Value<String?>? icon,
    Value<int>? rowid,
  }) {
    return LocationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      name: name ?? this.name,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      icon: icon ?? this.icon,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('name: $name, ')
          ..write('parentId: $parentId, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('icon: $icon, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _isbn13Meta = const VerificationMeta('isbn13');
  @override
  late final GeneratedColumn<String> isbn13 = GeneratedColumn<String>(
    'isbn13',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _olWorkKeyMeta = const VerificationMeta(
    'olWorkKey',
  );
  @override
  late final GeneratedColumn<String> olWorkKey = GeneratedColumn<String>(
    'ol_work_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  @override
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  @override
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _titleKeyMeta = const VerificationMeta(
    'titleKey',
  );
  @override
  late final GeneratedColumn<String> titleKey = GeneratedColumn<String>(
    'title_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverLocalPathMeta = const VerificationMeta(
    'coverLocalPath',
  );
  @override
  late final GeneratedColumn<String> coverLocalPath = GeneratedColumn<String>(
    'cover_local_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pagesMeta = const VerificationMeta('pages');
  @override
  late final GeneratedColumn<int> pages = GeneratedColumn<int>(
    'pages',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Ownership, String> ownership =
      GeneratedColumn<String>(
        'ownership',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(Ownership.owned.name),
      ).withConverter<Ownership>($BooksTable.$converterownership);
  @override
  late final GeneratedColumnWithTypeConverter<ReadStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: Constant(ReadStatus.want.name),
      ).withConverter<ReadStatus>($BooksTable.$converterstatus);
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationIdMeta = const VerificationMeta(
    'locationId',
  );
  @override
  late final GeneratedColumn<String> locationId = GeneratedColumn<String>(
    'location_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES locations (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _ownerNameMeta = const VerificationMeta(
    'ownerName',
  );
  @override
  late final GeneratedColumn<String> ownerName = GeneratedColumn<String>(
    'owner_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> startedOn =
      GeneratedColumn<String>(
        'started_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BooksTable.$converterstartedOnn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> finishedOn =
      GeneratedColumn<String>(
        'finished_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($BooksTable.$converterfinishedOnn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    isbn13,
    olWorkKey,
    title,
    subtitle,
    authors,
    titleKey,
    coverUrl,
    coverLocalPath,
    pages,
    genre,
    language,
    ownership,
    status,
    currentPage,
    rating,
    locationId,
    ownerName,
    notes,
    startedOn,
    finishedOn,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('isbn13')) {
      context.handle(
        _isbn13Meta,
        isbn13.isAcceptableOrUnknown(data['isbn13']!, _isbn13Meta),
      );
    }
    if (data.containsKey('ol_work_key')) {
      context.handle(
        _olWorkKeyMeta,
        olWorkKey.isAcceptableOrUnknown(data['ol_work_key']!, _olWorkKeyMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    }
    if (data.containsKey('title_key')) {
      context.handle(
        _titleKeyMeta,
        titleKey.isAcceptableOrUnknown(data['title_key']!, _titleKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_titleKeyMeta);
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('cover_local_path')) {
      context.handle(
        _coverLocalPathMeta,
        coverLocalPath.isAcceptableOrUnknown(
          data['cover_local_path']!,
          _coverLocalPathMeta,
        ),
      );
    }
    if (data.containsKey('pages')) {
      context.handle(
        _pagesMeta,
        pages.isAcceptableOrUnknown(data['pages']!, _pagesMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('location_id')) {
      context.handle(
        _locationIdMeta,
        locationId.isAcceptableOrUnknown(data['location_id']!, _locationIdMeta),
      );
    }
    if (data.containsKey('owner_name')) {
      context.handle(
        _ownerNameMeta,
        ownerName.isAcceptableOrUnknown(data['owner_name']!, _ownerNameMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      isbn13: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}isbn13'],
      ),
      olWorkKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ol_work_key'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      ),
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
      titleKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title_key'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      ),
      coverLocalPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_local_path'],
      ),
      pages: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      )!,
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      ownership: $BooksTable.$converterownership.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}ownership'],
        )!,
      ),
      status: $BooksTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      locationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location_id'],
      ),
      ownerName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}owner_name'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      startedOn: $BooksTable.$converterstartedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}started_on'],
        ),
      ),
      finishedOn: $BooksTable.$converterfinishedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}finished_on'],
        ),
      ),
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<Ownership, String, String> $converterownership =
      const EnumNameConverter<Ownership>(Ownership.values);
  static JsonTypeConverter2<ReadStatus, String, String> $converterstatus =
      const EnumNameConverter<ReadStatus>(ReadStatus.values);
  static TypeConverter<DateTime, String> $converterstartedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterstartedOnn =
      NullAwareTypeConverter.wrap($converterstartedOn);
  static TypeConverter<DateTime, String> $converterfinishedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterfinishedOnn =
      NullAwareTypeConverter.wrap($converterfinishedOn);
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String? isbn13;
  final String? olWorkKey;
  final String title;
  final String? subtitle;
  final String authors;
  final String titleKey;
  final String? coverUrl;
  final String? coverLocalPath;
  final int? pages;
  final String genre;
  final String language;
  final Ownership ownership;
  final ReadStatus status;
  final int currentPage;
  final int? rating;
  final String? locationId;
  final String? ownerName;
  final String? notes;
  final DateTime? startedOn;
  final DateTime? finishedOn;
  const BookRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    this.isbn13,
    this.olWorkKey,
    required this.title,
    this.subtitle,
    required this.authors,
    required this.titleKey,
    this.coverUrl,
    this.coverLocalPath,
    this.pages,
    required this.genre,
    required this.language,
    required this.ownership,
    required this.status,
    required this.currentPage,
    this.rating,
    this.locationId,
    this.ownerName,
    this.notes,
    this.startedOn,
    this.finishedOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    if (!nullToAbsent || isbn13 != null) {
      map['isbn13'] = Variable<String>(isbn13);
    }
    if (!nullToAbsent || olWorkKey != null) {
      map['ol_work_key'] = Variable<String>(olWorkKey);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || subtitle != null) {
      map['subtitle'] = Variable<String>(subtitle);
    }
    map['authors'] = Variable<String>(authors);
    map['title_key'] = Variable<String>(titleKey);
    if (!nullToAbsent || coverUrl != null) {
      map['cover_url'] = Variable<String>(coverUrl);
    }
    if (!nullToAbsent || coverLocalPath != null) {
      map['cover_local_path'] = Variable<String>(coverLocalPath);
    }
    if (!nullToAbsent || pages != null) {
      map['pages'] = Variable<int>(pages);
    }
    map['genre'] = Variable<String>(genre);
    map['language'] = Variable<String>(language);
    {
      map['ownership'] = Variable<String>(
        $BooksTable.$converterownership.toSql(ownership),
      );
    }
    {
      map['status'] = Variable<String>(
        $BooksTable.$converterstatus.toSql(status),
      );
    }
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || locationId != null) {
      map['location_id'] = Variable<String>(locationId);
    }
    if (!nullToAbsent || ownerName != null) {
      map['owner_name'] = Variable<String>(ownerName);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || startedOn != null) {
      map['started_on'] = Variable<String>(
        $BooksTable.$converterstartedOnn.toSql(startedOn),
      );
    }
    if (!nullToAbsent || finishedOn != null) {
      map['finished_on'] = Variable<String>(
        $BooksTable.$converterfinishedOnn.toSql(finishedOn),
      );
    }
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      isbn13: isbn13 == null && nullToAbsent
          ? const Value.absent()
          : Value(isbn13),
      olWorkKey: olWorkKey == null && nullToAbsent
          ? const Value.absent()
          : Value(olWorkKey),
      title: Value(title),
      subtitle: subtitle == null && nullToAbsent
          ? const Value.absent()
          : Value(subtitle),
      authors: Value(authors),
      titleKey: Value(titleKey),
      coverUrl: coverUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(coverUrl),
      coverLocalPath: coverLocalPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverLocalPath),
      pages: pages == null && nullToAbsent
          ? const Value.absent()
          : Value(pages),
      genre: Value(genre),
      language: Value(language),
      ownership: Value(ownership),
      status: Value(status),
      currentPage: Value(currentPage),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      locationId: locationId == null && nullToAbsent
          ? const Value.absent()
          : Value(locationId),
      ownerName: ownerName == null && nullToAbsent
          ? const Value.absent()
          : Value(ownerName),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      startedOn: startedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(startedOn),
      finishedOn: finishedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(finishedOn),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      isbn13: serializer.fromJson<String?>(json['isbn13']),
      olWorkKey: serializer.fromJson<String?>(json['olWorkKey']),
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String?>(json['subtitle']),
      authors: serializer.fromJson<String>(json['authors']),
      titleKey: serializer.fromJson<String>(json['titleKey']),
      coverUrl: serializer.fromJson<String?>(json['coverUrl']),
      coverLocalPath: serializer.fromJson<String?>(json['coverLocalPath']),
      pages: serializer.fromJson<int?>(json['pages']),
      genre: serializer.fromJson<String>(json['genre']),
      language: serializer.fromJson<String>(json['language']),
      ownership: $BooksTable.$converterownership.fromJson(
        serializer.fromJson<String>(json['ownership']),
      ),
      status: $BooksTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      rating: serializer.fromJson<int?>(json['rating']),
      locationId: serializer.fromJson<String?>(json['locationId']),
      ownerName: serializer.fromJson<String?>(json['ownerName']),
      notes: serializer.fromJson<String?>(json['notes']),
      startedOn: serializer.fromJson<DateTime?>(json['startedOn']),
      finishedOn: serializer.fromJson<DateTime?>(json['finishedOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'isbn13': serializer.toJson<String?>(isbn13),
      'olWorkKey': serializer.toJson<String?>(olWorkKey),
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String?>(subtitle),
      'authors': serializer.toJson<String>(authors),
      'titleKey': serializer.toJson<String>(titleKey),
      'coverUrl': serializer.toJson<String?>(coverUrl),
      'coverLocalPath': serializer.toJson<String?>(coverLocalPath),
      'pages': serializer.toJson<int?>(pages),
      'genre': serializer.toJson<String>(genre),
      'language': serializer.toJson<String>(language),
      'ownership': serializer.toJson<String>(
        $BooksTable.$converterownership.toJson(ownership),
      ),
      'status': serializer.toJson<String>(
        $BooksTable.$converterstatus.toJson(status),
      ),
      'currentPage': serializer.toJson<int>(currentPage),
      'rating': serializer.toJson<int?>(rating),
      'locationId': serializer.toJson<String?>(locationId),
      'ownerName': serializer.toJson<String?>(ownerName),
      'notes': serializer.toJson<String?>(notes),
      'startedOn': serializer.toJson<DateTime?>(startedOn),
      'finishedOn': serializer.toJson<DateTime?>(finishedOn),
    };
  }

  BookRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    Value<String?> isbn13 = const Value.absent(),
    Value<String?> olWorkKey = const Value.absent(),
    String? title,
    Value<String?> subtitle = const Value.absent(),
    String? authors,
    String? titleKey,
    Value<String?> coverUrl = const Value.absent(),
    Value<String?> coverLocalPath = const Value.absent(),
    Value<int?> pages = const Value.absent(),
    String? genre,
    String? language,
    Ownership? ownership,
    ReadStatus? status,
    int? currentPage,
    Value<int?> rating = const Value.absent(),
    Value<String?> locationId = const Value.absent(),
    Value<String?> ownerName = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<DateTime?> startedOn = const Value.absent(),
    Value<DateTime?> finishedOn = const Value.absent(),
  }) => BookRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    isbn13: isbn13.present ? isbn13.value : this.isbn13,
    olWorkKey: olWorkKey.present ? olWorkKey.value : this.olWorkKey,
    title: title ?? this.title,
    subtitle: subtitle.present ? subtitle.value : this.subtitle,
    authors: authors ?? this.authors,
    titleKey: titleKey ?? this.titleKey,
    coverUrl: coverUrl.present ? coverUrl.value : this.coverUrl,
    coverLocalPath: coverLocalPath.present
        ? coverLocalPath.value
        : this.coverLocalPath,
    pages: pages.present ? pages.value : this.pages,
    genre: genre ?? this.genre,
    language: language ?? this.language,
    ownership: ownership ?? this.ownership,
    status: status ?? this.status,
    currentPage: currentPage ?? this.currentPage,
    rating: rating.present ? rating.value : this.rating,
    locationId: locationId.present ? locationId.value : this.locationId,
    ownerName: ownerName.present ? ownerName.value : this.ownerName,
    notes: notes.present ? notes.value : this.notes,
    startedOn: startedOn.present ? startedOn.value : this.startedOn,
    finishedOn: finishedOn.present ? finishedOn.value : this.finishedOn,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      isbn13: data.isbn13.present ? data.isbn13.value : this.isbn13,
      olWorkKey: data.olWorkKey.present ? data.olWorkKey.value : this.olWorkKey,
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      authors: data.authors.present ? data.authors.value : this.authors,
      titleKey: data.titleKey.present ? data.titleKey.value : this.titleKey,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      coverLocalPath: data.coverLocalPath.present
          ? data.coverLocalPath.value
          : this.coverLocalPath,
      pages: data.pages.present ? data.pages.value : this.pages,
      genre: data.genre.present ? data.genre.value : this.genre,
      language: data.language.present ? data.language.value : this.language,
      ownership: data.ownership.present ? data.ownership.value : this.ownership,
      status: data.status.present ? data.status.value : this.status,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      rating: data.rating.present ? data.rating.value : this.rating,
      locationId: data.locationId.present
          ? data.locationId.value
          : this.locationId,
      ownerName: data.ownerName.present ? data.ownerName.value : this.ownerName,
      notes: data.notes.present ? data.notes.value : this.notes,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      finishedOn: data.finishedOn.present
          ? data.finishedOn.value
          : this.finishedOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('isbn13: $isbn13, ')
          ..write('olWorkKey: $olWorkKey, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors, ')
          ..write('titleKey: $titleKey, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverLocalPath: $coverLocalPath, ')
          ..write('pages: $pages, ')
          ..write('genre: $genre, ')
          ..write('language: $language, ')
          ..write('ownership: $ownership, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('rating: $rating, ')
          ..write('locationId: $locationId, ')
          ..write('ownerName: $ownerName, ')
          ..write('notes: $notes, ')
          ..write('startedOn: $startedOn, ')
          ..write('finishedOn: $finishedOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    isbn13,
    olWorkKey,
    title,
    subtitle,
    authors,
    titleKey,
    coverUrl,
    coverLocalPath,
    pages,
    genre,
    language,
    ownership,
    status,
    currentPage,
    rating,
    locationId,
    ownerName,
    notes,
    startedOn,
    finishedOn,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.isbn13 == this.isbn13 &&
          other.olWorkKey == this.olWorkKey &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.authors == this.authors &&
          other.titleKey == this.titleKey &&
          other.coverUrl == this.coverUrl &&
          other.coverLocalPath == this.coverLocalPath &&
          other.pages == this.pages &&
          other.genre == this.genre &&
          other.language == this.language &&
          other.ownership == this.ownership &&
          other.status == this.status &&
          other.currentPage == this.currentPage &&
          other.rating == this.rating &&
          other.locationId == this.locationId &&
          other.ownerName == this.ownerName &&
          other.notes == this.notes &&
          other.startedOn == this.startedOn &&
          other.finishedOn == this.finishedOn);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String?> isbn13;
  final Value<String?> olWorkKey;
  final Value<String> title;
  final Value<String?> subtitle;
  final Value<String> authors;
  final Value<String> titleKey;
  final Value<String?> coverUrl;
  final Value<String?> coverLocalPath;
  final Value<int?> pages;
  final Value<String> genre;
  final Value<String> language;
  final Value<Ownership> ownership;
  final Value<ReadStatus> status;
  final Value<int> currentPage;
  final Value<int?> rating;
  final Value<String?> locationId;
  final Value<String?> ownerName;
  final Value<String?> notes;
  final Value<DateTime?> startedOn;
  final Value<DateTime?> finishedOn;
  final Value<int> rowid;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.olWorkKey = const Value.absent(),
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.authors = const Value.absent(),
    this.titleKey = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.coverLocalPath = const Value.absent(),
    this.pages = const Value.absent(),
    this.genre = const Value.absent(),
    this.language = const Value.absent(),
    this.ownership = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.rating = const Value.absent(),
    this.locationId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.notes = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.finishedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.isbn13 = const Value.absent(),
    this.olWorkKey = const Value.absent(),
    required String title,
    this.subtitle = const Value.absent(),
    this.authors = const Value.absent(),
    required String titleKey,
    this.coverUrl = const Value.absent(),
    this.coverLocalPath = const Value.absent(),
    this.pages = const Value.absent(),
    this.genre = const Value.absent(),
    this.language = const Value.absent(),
    this.ownership = const Value.absent(),
    this.status = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.rating = const Value.absent(),
    this.locationId = const Value.absent(),
    this.ownerName = const Value.absent(),
    this.notes = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.finishedOn = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       title = Value(title),
       titleKey = Value(titleKey);
  static Insertable<BookRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? isbn13,
    Expression<String>? olWorkKey,
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? authors,
    Expression<String>? titleKey,
    Expression<String>? coverUrl,
    Expression<String>? coverLocalPath,
    Expression<int>? pages,
    Expression<String>? genre,
    Expression<String>? language,
    Expression<String>? ownership,
    Expression<String>? status,
    Expression<int>? currentPage,
    Expression<int>? rating,
    Expression<String>? locationId,
    Expression<String>? ownerName,
    Expression<String>? notes,
    Expression<String>? startedOn,
    Expression<String>? finishedOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (isbn13 != null) 'isbn13': isbn13,
      if (olWorkKey != null) 'ol_work_key': olWorkKey,
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (authors != null) 'authors': authors,
      if (titleKey != null) 'title_key': titleKey,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (coverLocalPath != null) 'cover_local_path': coverLocalPath,
      if (pages != null) 'pages': pages,
      if (genre != null) 'genre': genre,
      if (language != null) 'language': language,
      if (ownership != null) 'ownership': ownership,
      if (status != null) 'status': status,
      if (currentPage != null) 'current_page': currentPage,
      if (rating != null) 'rating': rating,
      if (locationId != null) 'location_id': locationId,
      if (ownerName != null) 'owner_name': ownerName,
      if (notes != null) 'notes': notes,
      if (startedOn != null) 'started_on': startedOn,
      if (finishedOn != null) 'finished_on': finishedOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String?>? isbn13,
    Value<String?>? olWorkKey,
    Value<String>? title,
    Value<String?>? subtitle,
    Value<String>? authors,
    Value<String>? titleKey,
    Value<String?>? coverUrl,
    Value<String?>? coverLocalPath,
    Value<int?>? pages,
    Value<String>? genre,
    Value<String>? language,
    Value<Ownership>? ownership,
    Value<ReadStatus>? status,
    Value<int>? currentPage,
    Value<int?>? rating,
    Value<String?>? locationId,
    Value<String?>? ownerName,
    Value<String?>? notes,
    Value<DateTime?>? startedOn,
    Value<DateTime?>? finishedOn,
    Value<int>? rowid,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      isbn13: isbn13 ?? this.isbn13,
      olWorkKey: olWorkKey ?? this.olWorkKey,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authors: authors ?? this.authors,
      titleKey: titleKey ?? this.titleKey,
      coverUrl: coverUrl ?? this.coverUrl,
      coverLocalPath: coverLocalPath ?? this.coverLocalPath,
      pages: pages ?? this.pages,
      genre: genre ?? this.genre,
      language: language ?? this.language,
      ownership: ownership ?? this.ownership,
      status: status ?? this.status,
      currentPage: currentPage ?? this.currentPage,
      rating: rating ?? this.rating,
      locationId: locationId ?? this.locationId,
      ownerName: ownerName ?? this.ownerName,
      notes: notes ?? this.notes,
      startedOn: startedOn ?? this.startedOn,
      finishedOn: finishedOn ?? this.finishedOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (isbn13.present) {
      map['isbn13'] = Variable<String>(isbn13.value);
    }
    if (olWorkKey.present) {
      map['ol_work_key'] = Variable<String>(olWorkKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (titleKey.present) {
      map['title_key'] = Variable<String>(titleKey.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (coverLocalPath.present) {
      map['cover_local_path'] = Variable<String>(coverLocalPath.value);
    }
    if (pages.present) {
      map['pages'] = Variable<int>(pages.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (ownership.present) {
      map['ownership'] = Variable<String>(
        $BooksTable.$converterownership.toSql(ownership.value),
      );
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $BooksTable.$converterstatus.toSql(status.value),
      );
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (locationId.present) {
      map['location_id'] = Variable<String>(locationId.value);
    }
    if (ownerName.present) {
      map['owner_name'] = Variable<String>(ownerName.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(
        $BooksTable.$converterstartedOnn.toSql(startedOn.value),
      );
    }
    if (finishedOn.present) {
      map['finished_on'] = Variable<String>(
        $BooksTable.$converterfinishedOnn.toSql(finishedOn.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('isbn13: $isbn13, ')
          ..write('olWorkKey: $olWorkKey, ')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors, ')
          ..write('titleKey: $titleKey, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('coverLocalPath: $coverLocalPath, ')
          ..write('pages: $pages, ')
          ..write('genre: $genre, ')
          ..write('language: $language, ')
          ..write('ownership: $ownership, ')
          ..write('status: $status, ')
          ..write('currentPage: $currentPage, ')
          ..write('rating: $rating, ')
          ..write('locationId: $locationId, ')
          ..write('ownerName: $ownerName, ')
          ..write('notes: $notes, ')
          ..write('startedOn: $startedOn, ')
          ..write('finishedOn: $finishedOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingLogsTable extends ReadingLogs
    with TableInfo<$ReadingLogsTable, ReadingLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($ReadingLogsTable.$converterdate);
  static const VerificationMeta _pagesReadMeta = const VerificationMeta(
    'pagesRead',
  );
  @override
  late final GeneratedColumn<int> pagesRead = GeneratedColumn<int>(
    'pages_read',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromPageMeta = const VerificationMeta(
    'fromPage',
  );
  @override
  late final GeneratedColumn<int> fromPage = GeneratedColumn<int>(
    'from_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toPageMeta = const VerificationMeta('toPage');
  @override
  late final GeneratedColumn<int> toPage = GeneratedColumn<int>(
    'to_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    date,
    pagesRead,
    fromPage,
    toPage,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('pages_read')) {
      context.handle(
        _pagesReadMeta,
        pagesRead.isAcceptableOrUnknown(data['pages_read']!, _pagesReadMeta),
      );
    } else if (isInserting) {
      context.missing(_pagesReadMeta);
    }
    if (data.containsKey('from_page')) {
      context.handle(
        _fromPageMeta,
        fromPage.isAcceptableOrUnknown(data['from_page']!, _fromPageMeta),
      );
    } else if (isInserting) {
      context.missing(_fromPageMeta);
    }
    if (data.containsKey('to_page')) {
      context.handle(
        _toPageMeta,
        toPage.isAcceptableOrUnknown(data['to_page']!, _toPageMeta),
      );
    } else if (isInserting) {
      context.missing(_toPageMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReadingLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      date: $ReadingLogsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      pagesRead: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pages_read'],
      )!,
      fromPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_page'],
      )!,
      toPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_page'],
      )!,
    );
  }

  @override
  $ReadingLogsTable createAlias(String alias) {
    return $ReadingLogsTable(attachedDatabase, alias);
  }

  static TypeConverter<DateTime, String> $converterdate =
      const DateOnlyConverter();
}

class ReadingLogRow extends DataClass implements Insertable<ReadingLogRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String bookId;
  final DateTime date;
  final int pagesRead;
  final int fromPage;
  final int toPage;
  const ReadingLogRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.bookId,
    required this.date,
    required this.pagesRead,
    required this.fromPage,
    required this.toPage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['book_id'] = Variable<String>(bookId);
    {
      map['date'] = Variable<String>(
        $ReadingLogsTable.$converterdate.toSql(date),
      );
    }
    map['pages_read'] = Variable<int>(pagesRead);
    map['from_page'] = Variable<int>(fromPage);
    map['to_page'] = Variable<int>(toPage);
    return map;
  }

  ReadingLogsCompanion toCompanion(bool nullToAbsent) {
    return ReadingLogsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      bookId: Value(bookId),
      date: Value(date),
      pagesRead: Value(pagesRead),
      fromPage: Value(fromPage),
      toPage: Value(toPage),
    );
  }

  factory ReadingLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingLogRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      bookId: serializer.fromJson<String>(json['bookId']),
      date: serializer.fromJson<DateTime>(json['date']),
      pagesRead: serializer.fromJson<int>(json['pagesRead']),
      fromPage: serializer.fromJson<int>(json['fromPage']),
      toPage: serializer.fromJson<int>(json['toPage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'bookId': serializer.toJson<String>(bookId),
      'date': serializer.toJson<DateTime>(date),
      'pagesRead': serializer.toJson<int>(pagesRead),
      'fromPage': serializer.toJson<int>(fromPage),
      'toPage': serializer.toJson<int>(toPage),
    };
  }

  ReadingLogRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? bookId,
    DateTime? date,
    int? pagesRead,
    int? fromPage,
    int? toPage,
  }) => ReadingLogRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    bookId: bookId ?? this.bookId,
    date: date ?? this.date,
    pagesRead: pagesRead ?? this.pagesRead,
    fromPage: fromPage ?? this.fromPage,
    toPage: toPage ?? this.toPage,
  );
  ReadingLogRow copyWithCompanion(ReadingLogsCompanion data) {
    return ReadingLogRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      date: data.date.present ? data.date.value : this.date,
      pagesRead: data.pagesRead.present ? data.pagesRead.value : this.pagesRead,
      fromPage: data.fromPage.present ? data.fromPage.value : this.fromPage,
      toPage: data.toPage.present ? data.toPage.value : this.toPage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('fromPage: $fromPage, ')
          ..write('toPage: $toPage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    date,
    pagesRead,
    fromPage,
    toPage,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingLogRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.bookId == this.bookId &&
          other.date == this.date &&
          other.pagesRead == this.pagesRead &&
          other.fromPage == this.fromPage &&
          other.toPage == this.toPage);
}

class ReadingLogsCompanion extends UpdateCompanion<ReadingLogRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> bookId;
  final Value<DateTime> date;
  final Value<int> pagesRead;
  final Value<int> fromPage;
  final Value<int> toPage;
  final Value<int> rowid;
  const ReadingLogsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.bookId = const Value.absent(),
    this.date = const Value.absent(),
    this.pagesRead = const Value.absent(),
    this.fromPage = const Value.absent(),
    this.toPage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingLogsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String bookId,
    required DateTime date,
    required int pagesRead,
    required int fromPage,
    required int toPage,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       bookId = Value(bookId),
       date = Value(date),
       pagesRead = Value(pagesRead),
       fromPage = Value(fromPage),
       toPage = Value(toPage);
  static Insertable<ReadingLogRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? bookId,
    Expression<String>? date,
    Expression<int>? pagesRead,
    Expression<int>? fromPage,
    Expression<int>? toPage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (bookId != null) 'book_id': bookId,
      if (date != null) 'date': date,
      if (pagesRead != null) 'pages_read': pagesRead,
      if (fromPage != null) 'from_page': fromPage,
      if (toPage != null) 'to_page': toPage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingLogsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? bookId,
    Value<DateTime>? date,
    Value<int>? pagesRead,
    Value<int>? fromPage,
    Value<int>? toPage,
    Value<int>? rowid,
  }) {
    return ReadingLogsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      bookId: bookId ?? this.bookId,
      date: date ?? this.date,
      pagesRead: pagesRead ?? this.pagesRead,
      fromPage: fromPage ?? this.fromPage,
      toPage: toPage ?? this.toPage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $ReadingLogsTable.$converterdate.toSql(date.value),
      );
    }
    if (pagesRead.present) {
      map['pages_read'] = Variable<int>(pagesRead.value);
    }
    if (fromPage.present) {
      map['from_page'] = Variable<int>(fromPage.value);
    }
    if (toPage.present) {
      map['to_page'] = Variable<int>(toPage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingLogsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('date: $date, ')
          ..write('pagesRead: $pagesRead, ')
          ..write('fromPage: $fromPage, ')
          ..write('toPage: $toPage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuotesTable extends Quotes with TableInfo<$QuotesTable, QuoteRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pageMeta = const VerificationMeta('page');
  @override
  late final GeneratedColumn<int> page = GeneratedColumn<int>(
    'page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isFavouriteMeta = const VerificationMeta(
    'isFavourite',
  );
  @override
  late final GeneratedColumn<bool> isFavourite = GeneratedColumn<bool>(
    'is_favourite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favourite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    body,
    page,
    isFavourite,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'quotes';
  @override
  VerificationContext validateIntegrity(
    Insertable<QuoteRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('page')) {
      context.handle(
        _pageMeta,
        page.isAcceptableOrUnknown(data['page']!, _pageMeta),
      );
    }
    if (data.containsKey('is_favourite')) {
      context.handle(
        _isFavouriteMeta,
        isFavourite.isAcceptableOrUnknown(
          data['is_favourite']!,
          _isFavouriteMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  QuoteRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QuoteRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      page: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page'],
      ),
      isFavourite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favourite'],
      )!,
    );
  }

  @override
  $QuotesTable createAlias(String alias) {
    return $QuotesTable(attachedDatabase, alias);
  }
}

class QuoteRow extends DataClass implements Insertable<QuoteRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String bookId;
  final String body;
  final int? page;
  final bool isFavourite;
  const QuoteRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.bookId,
    required this.body,
    this.page,
    required this.isFavourite,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['book_id'] = Variable<String>(bookId);
    map['body'] = Variable<String>(body);
    if (!nullToAbsent || page != null) {
      map['page'] = Variable<int>(page);
    }
    map['is_favourite'] = Variable<bool>(isFavourite);
    return map;
  }

  QuotesCompanion toCompanion(bool nullToAbsent) {
    return QuotesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      bookId: Value(bookId),
      body: Value(body),
      page: page == null && nullToAbsent ? const Value.absent() : Value(page),
      isFavourite: Value(isFavourite),
    );
  }

  factory QuoteRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QuoteRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      bookId: serializer.fromJson<String>(json['bookId']),
      body: serializer.fromJson<String>(json['body']),
      page: serializer.fromJson<int?>(json['page']),
      isFavourite: serializer.fromJson<bool>(json['isFavourite']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'bookId': serializer.toJson<String>(bookId),
      'body': serializer.toJson<String>(body),
      'page': serializer.toJson<int?>(page),
      'isFavourite': serializer.toJson<bool>(isFavourite),
    };
  }

  QuoteRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? bookId,
    String? body,
    Value<int?> page = const Value.absent(),
    bool? isFavourite,
  }) => QuoteRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    bookId: bookId ?? this.bookId,
    body: body ?? this.body,
    page: page.present ? page.value : this.page,
    isFavourite: isFavourite ?? this.isFavourite,
  );
  QuoteRow copyWithCompanion(QuotesCompanion data) {
    return QuoteRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      body: data.body.present ? data.body.value : this.body,
      page: data.page.present ? data.page.value : this.page,
      isFavourite: data.isFavourite.present
          ? data.isFavourite.value
          : this.isFavourite,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QuoteRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('body: $body, ')
          ..write('page: $page, ')
          ..write('isFavourite: $isFavourite')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    body,
    page,
    isFavourite,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QuoteRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.bookId == this.bookId &&
          other.body == this.body &&
          other.page == this.page &&
          other.isFavourite == this.isFavourite);
}

class QuotesCompanion extends UpdateCompanion<QuoteRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> bookId;
  final Value<String> body;
  final Value<int?> page;
  final Value<bool> isFavourite;
  final Value<int> rowid;
  const QuotesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.bookId = const Value.absent(),
    this.body = const Value.absent(),
    this.page = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuotesCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String bookId,
    required String body,
    this.page = const Value.absent(),
    this.isFavourite = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       bookId = Value(bookId),
       body = Value(body);
  static Insertable<QuoteRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? bookId,
    Expression<String>? body,
    Expression<int>? page,
    Expression<bool>? isFavourite,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (bookId != null) 'book_id': bookId,
      if (body != null) 'body': body,
      if (page != null) 'page': page,
      if (isFavourite != null) 'is_favourite': isFavourite,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuotesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? bookId,
    Value<String>? body,
    Value<int?>? page,
    Value<bool>? isFavourite,
    Value<int>? rowid,
  }) {
    return QuotesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      bookId: bookId ?? this.bookId,
      body: body ?? this.body,
      page: page ?? this.page,
      isFavourite: isFavourite ?? this.isFavourite,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (page.present) {
      map['page'] = Variable<int>(page.value);
    }
    if (isFavourite.present) {
      map['is_favourite'] = Variable<bool>(isFavourite.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuotesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('body: $body, ')
          ..write('page: $page, ')
          ..write('isFavourite: $isFavourite, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LoansTable extends Loans with TableInfo<$LoansTable, LoanRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LoansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LoanDirection, String> direction =
      GeneratedColumn<String>(
        'direction',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LoanDirection>($LoansTable.$converterdirection);
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _personPhoneMeta = const VerificationMeta(
    'personPhone',
  );
  @override
  late final GeneratedColumn<String> personPhone = GeneratedColumn<String>(
    'person_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DateTime, String> startedOn =
      GeneratedColumn<String>(
        'started_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DateTime>($LoansTable.$converterstartedOn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> dueOn =
      GeneratedColumn<String>(
        'due_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LoansTable.$converterdueOnn);
  @override
  late final GeneratedColumnWithTypeConverter<DateTime?, String> returnedOn =
      GeneratedColumn<String>(
        'returned_on',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<DateTime?>($LoansTable.$converterreturnedOnn);
  static const VerificationMeta _previousLocationIdMeta =
      const VerificationMeta('previousLocationId');
  @override
  late final GeneratedColumn<String> previousLocationId =
      GeneratedColumn<String>(
        'previous_location_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES locations (id) ON DELETE SET NULL',
        ),
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    direction,
    personName,
    personPhone,
    startedOn,
    dueOn,
    returnedOn,
    previousLocationId,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'loans';
  @override
  VerificationContext validateIntegrity(
    Insertable<LoanRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    } else if (isInserting) {
      context.missing(_personNameMeta);
    }
    if (data.containsKey('person_phone')) {
      context.handle(
        _personPhoneMeta,
        personPhone.isAcceptableOrUnknown(
          data['person_phone']!,
          _personPhoneMeta,
        ),
      );
    }
    if (data.containsKey('previous_location_id')) {
      context.handle(
        _previousLocationIdMeta,
        previousLocationId.isAcceptableOrUnknown(
          data['previous_location_id']!,
          _previousLocationIdMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LoanRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LoanRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      direction: $LoansTable.$converterdirection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}direction'],
        )!,
      ),
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      )!,
      personPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_phone'],
      ),
      startedOn: $LoansTable.$converterstartedOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}started_on'],
        )!,
      ),
      dueOn: $LoansTable.$converterdueOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}due_on'],
        ),
      ),
      returnedOn: $LoansTable.$converterreturnedOnn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}returned_on'],
        ),
      ),
      previousLocationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}previous_location_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $LoansTable createAlias(String alias) {
    return $LoansTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<LoanDirection, String, String> $converterdirection =
      const EnumNameConverter<LoanDirection>(LoanDirection.values);
  static TypeConverter<DateTime, String> $converterstartedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime, String> $converterdueOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterdueOnn =
      NullAwareTypeConverter.wrap($converterdueOn);
  static TypeConverter<DateTime, String> $converterreturnedOn =
      const DateOnlyConverter();
  static TypeConverter<DateTime?, String?> $converterreturnedOnn =
      NullAwareTypeConverter.wrap($converterreturnedOn);
}

class LoanRow extends DataClass implements Insertable<LoanRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String bookId;
  final LoanDirection direction;
  final String personName;
  final String? personPhone;
  final DateTime startedOn;
  final DateTime? dueOn;
  final DateTime? returnedOn;
  final String? previousLocationId;
  final String? note;
  const LoanRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.bookId,
    required this.direction,
    required this.personName,
    this.personPhone,
    required this.startedOn,
    this.dueOn,
    this.returnedOn,
    this.previousLocationId,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['book_id'] = Variable<String>(bookId);
    {
      map['direction'] = Variable<String>(
        $LoansTable.$converterdirection.toSql(direction),
      );
    }
    map['person_name'] = Variable<String>(personName);
    if (!nullToAbsent || personPhone != null) {
      map['person_phone'] = Variable<String>(personPhone);
    }
    {
      map['started_on'] = Variable<String>(
        $LoansTable.$converterstartedOn.toSql(startedOn),
      );
    }
    if (!nullToAbsent || dueOn != null) {
      map['due_on'] = Variable<String>(
        $LoansTable.$converterdueOnn.toSql(dueOn),
      );
    }
    if (!nullToAbsent || returnedOn != null) {
      map['returned_on'] = Variable<String>(
        $LoansTable.$converterreturnedOnn.toSql(returnedOn),
      );
    }
    if (!nullToAbsent || previousLocationId != null) {
      map['previous_location_id'] = Variable<String>(previousLocationId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  LoansCompanion toCompanion(bool nullToAbsent) {
    return LoansCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      bookId: Value(bookId),
      direction: Value(direction),
      personName: Value(personName),
      personPhone: personPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(personPhone),
      startedOn: Value(startedOn),
      dueOn: dueOn == null && nullToAbsent
          ? const Value.absent()
          : Value(dueOn),
      returnedOn: returnedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(returnedOn),
      previousLocationId: previousLocationId == null && nullToAbsent
          ? const Value.absent()
          : Value(previousLocationId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory LoanRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LoanRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      bookId: serializer.fromJson<String>(json['bookId']),
      direction: $LoansTable.$converterdirection.fromJson(
        serializer.fromJson<String>(json['direction']),
      ),
      personName: serializer.fromJson<String>(json['personName']),
      personPhone: serializer.fromJson<String?>(json['personPhone']),
      startedOn: serializer.fromJson<DateTime>(json['startedOn']),
      dueOn: serializer.fromJson<DateTime?>(json['dueOn']),
      returnedOn: serializer.fromJson<DateTime?>(json['returnedOn']),
      previousLocationId: serializer.fromJson<String?>(
        json['previousLocationId'],
      ),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'bookId': serializer.toJson<String>(bookId),
      'direction': serializer.toJson<String>(
        $LoansTable.$converterdirection.toJson(direction),
      ),
      'personName': serializer.toJson<String>(personName),
      'personPhone': serializer.toJson<String?>(personPhone),
      'startedOn': serializer.toJson<DateTime>(startedOn),
      'dueOn': serializer.toJson<DateTime?>(dueOn),
      'returnedOn': serializer.toJson<DateTime?>(returnedOn),
      'previousLocationId': serializer.toJson<String?>(previousLocationId),
      'note': serializer.toJson<String?>(note),
    };
  }

  LoanRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? bookId,
    LoanDirection? direction,
    String? personName,
    Value<String?> personPhone = const Value.absent(),
    DateTime? startedOn,
    Value<DateTime?> dueOn = const Value.absent(),
    Value<DateTime?> returnedOn = const Value.absent(),
    Value<String?> previousLocationId = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => LoanRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    bookId: bookId ?? this.bookId,
    direction: direction ?? this.direction,
    personName: personName ?? this.personName,
    personPhone: personPhone.present ? personPhone.value : this.personPhone,
    startedOn: startedOn ?? this.startedOn,
    dueOn: dueOn.present ? dueOn.value : this.dueOn,
    returnedOn: returnedOn.present ? returnedOn.value : this.returnedOn,
    previousLocationId: previousLocationId.present
        ? previousLocationId.value
        : this.previousLocationId,
    note: note.present ? note.value : this.note,
  );
  LoanRow copyWithCompanion(LoansCompanion data) {
    return LoanRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      direction: data.direction.present ? data.direction.value : this.direction,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      personPhone: data.personPhone.present
          ? data.personPhone.value
          : this.personPhone,
      startedOn: data.startedOn.present ? data.startedOn.value : this.startedOn,
      dueOn: data.dueOn.present ? data.dueOn.value : this.dueOn,
      returnedOn: data.returnedOn.present
          ? data.returnedOn.value
          : this.returnedOn,
      previousLocationId: data.previousLocationId.present
          ? data.previousLocationId.value
          : this.previousLocationId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LoanRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('direction: $direction, ')
          ..write('personName: $personName, ')
          ..write('personPhone: $personPhone, ')
          ..write('startedOn: $startedOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('returnedOn: $returnedOn, ')
          ..write('previousLocationId: $previousLocationId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    direction,
    personName,
    personPhone,
    startedOn,
    dueOn,
    returnedOn,
    previousLocationId,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LoanRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.bookId == this.bookId &&
          other.direction == this.direction &&
          other.personName == this.personName &&
          other.personPhone == this.personPhone &&
          other.startedOn == this.startedOn &&
          other.dueOn == this.dueOn &&
          other.returnedOn == this.returnedOn &&
          other.previousLocationId == this.previousLocationId &&
          other.note == this.note);
}

class LoansCompanion extends UpdateCompanion<LoanRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> bookId;
  final Value<LoanDirection> direction;
  final Value<String> personName;
  final Value<String?> personPhone;
  final Value<DateTime> startedOn;
  final Value<DateTime?> dueOn;
  final Value<DateTime?> returnedOn;
  final Value<String?> previousLocationId;
  final Value<String?> note;
  final Value<int> rowid;
  const LoansCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.bookId = const Value.absent(),
    this.direction = const Value.absent(),
    this.personName = const Value.absent(),
    this.personPhone = const Value.absent(),
    this.startedOn = const Value.absent(),
    this.dueOn = const Value.absent(),
    this.returnedOn = const Value.absent(),
    this.previousLocationId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LoansCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String bookId,
    required LoanDirection direction,
    required String personName,
    this.personPhone = const Value.absent(),
    required DateTime startedOn,
    this.dueOn = const Value.absent(),
    this.returnedOn = const Value.absent(),
    this.previousLocationId = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       bookId = Value(bookId),
       direction = Value(direction),
       personName = Value(personName),
       startedOn = Value(startedOn);
  static Insertable<LoanRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? bookId,
    Expression<String>? direction,
    Expression<String>? personName,
    Expression<String>? personPhone,
    Expression<String>? startedOn,
    Expression<String>? dueOn,
    Expression<String>? returnedOn,
    Expression<String>? previousLocationId,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (bookId != null) 'book_id': bookId,
      if (direction != null) 'direction': direction,
      if (personName != null) 'person_name': personName,
      if (personPhone != null) 'person_phone': personPhone,
      if (startedOn != null) 'started_on': startedOn,
      if (dueOn != null) 'due_on': dueOn,
      if (returnedOn != null) 'returned_on': returnedOn,
      if (previousLocationId != null)
        'previous_location_id': previousLocationId,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LoansCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? bookId,
    Value<LoanDirection>? direction,
    Value<String>? personName,
    Value<String?>? personPhone,
    Value<DateTime>? startedOn,
    Value<DateTime?>? dueOn,
    Value<DateTime?>? returnedOn,
    Value<String?>? previousLocationId,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return LoansCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      bookId: bookId ?? this.bookId,
      direction: direction ?? this.direction,
      personName: personName ?? this.personName,
      personPhone: personPhone ?? this.personPhone,
      startedOn: startedOn ?? this.startedOn,
      dueOn: dueOn ?? this.dueOn,
      returnedOn: returnedOn ?? this.returnedOn,
      previousLocationId: previousLocationId ?? this.previousLocationId,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(
        $LoansTable.$converterdirection.toSql(direction.value),
      );
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (personPhone.present) {
      map['person_phone'] = Variable<String>(personPhone.value);
    }
    if (startedOn.present) {
      map['started_on'] = Variable<String>(
        $LoansTable.$converterstartedOn.toSql(startedOn.value),
      );
    }
    if (dueOn.present) {
      map['due_on'] = Variable<String>(
        $LoansTable.$converterdueOnn.toSql(dueOn.value),
      );
    }
    if (returnedOn.present) {
      map['returned_on'] = Variable<String>(
        $LoansTable.$converterreturnedOnn.toSql(returnedOn.value),
      );
    }
    if (previousLocationId.present) {
      map['previous_location_id'] = Variable<String>(previousLocationId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LoansCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('direction: $direction, ')
          ..write('personName: $personName, ')
          ..write('personPhone: $personPhone, ')
          ..write('startedOn: $startedOn, ')
          ..write('dueOn: $dueOn, ')
          ..write('returnedOn: $returnedOn, ')
          ..write('previousLocationId: $previousLocationId, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GoalsTable extends Goals with TableInfo<$GoalsTable, GoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetBooksMeta = const VerificationMeta(
    'targetBooks',
  );
  @override
  late final GeneratedColumn<int> targetBooks = GeneratedColumn<int>(
    'target_books',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    year,
    targetBooks,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<GoalRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    } else if (isInserting) {
      context.missing(_yearMeta);
    }
    if (data.containsKey('target_books')) {
      context.handle(
        _targetBooksMeta,
        targetBooks.isAcceptableOrUnknown(
          data['target_books']!,
          _targetBooksMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetBooksMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GoalRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      )!,
      targetBooks: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_books'],
      )!,
    );
  }

  @override
  $GoalsTable createAlias(String alias) {
    return $GoalsTable(attachedDatabase, alias);
  }
}

class GoalRow extends DataClass implements Insertable<GoalRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final int year;
  final int targetBooks;
  const GoalRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.year,
    required this.targetBooks,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['year'] = Variable<int>(year);
    map['target_books'] = Variable<int>(targetBooks);
    return map;
  }

  GoalsCompanion toCompanion(bool nullToAbsent) {
    return GoalsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      year: Value(year),
      targetBooks: Value(targetBooks),
    );
  }

  factory GoalRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GoalRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      year: serializer.fromJson<int>(json['year']),
      targetBooks: serializer.fromJson<int>(json['targetBooks']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'year': serializer.toJson<int>(year),
      'targetBooks': serializer.toJson<int>(targetBooks),
    };
  }

  GoalRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    int? year,
    int? targetBooks,
  }) => GoalRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    year: year ?? this.year,
    targetBooks: targetBooks ?? this.targetBooks,
  );
  GoalRow copyWithCompanion(GoalsCompanion data) {
    return GoalRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      year: data.year.present ? data.year.value : this.year,
      targetBooks: data.targetBooks.present
          ? data.targetBooks.value
          : this.targetBooks,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GoalRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('year: $year, ')
          ..write('targetBooks: $targetBooks')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, rev, year, targetBooks);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GoalRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.year == this.year &&
          other.targetBooks == this.targetBooks);
}

class GoalsCompanion extends UpdateCompanion<GoalRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<int> year;
  final Value<int> targetBooks;
  final Value<int> rowid;
  const GoalsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.year = const Value.absent(),
    this.targetBooks = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GoalsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required int year,
    required int targetBooks,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       year = Value(year),
       targetBooks = Value(targetBooks);
  static Insertable<GoalRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<int>? year,
    Expression<int>? targetBooks,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (year != null) 'year': year,
      if (targetBooks != null) 'target_books': targetBooks,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GoalsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<int>? year,
    Value<int>? targetBooks,
    Value<int>? rowid,
  }) {
    return GoalsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      year: year ?? this.year,
      targetBooks: targetBooks ?? this.targetBooks,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (targetBooks.present) {
      map['target_books'] = Variable<int>(targetBooks.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GoalsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('year: $year, ')
          ..write('targetBooks: $targetBooks, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, TagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    name,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<TagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class TagRow extends DataClass implements Insertable<TagRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String name;
  const TagRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.name,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      name: Value(name),
    );
  }

  factory TagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TagRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'name': serializer.toJson<String>(name),
    };
  }

  TagRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? name,
  }) => TagRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    name: name ?? this.name,
  );
  TagRow copyWithCompanion(TagsCompanion data) {
    return TagRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TagRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, rev, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TagRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<TagRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> name;
  final Value<int> rowid;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.name = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TagsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String name,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name);
  static Insertable<TagRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? name,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (name != null) 'name': name,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TagsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? name,
    Value<int>? rowid,
  }) {
    return TagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      name: name ?? this.name,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('name: $name, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BookTagsTable extends BookTags
    with TableInfo<$BookTagsTable, BookTagRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BookTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    clientDefault: uuidV7,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _revMeta = const VerificationMeta('rev');
  @override
  late final GeneratedColumn<int> rev = GeneratedColumn<int>(
    'rev',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id)',
    ),
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<String> tagId = GeneratedColumn<String>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    rev,
    bookId,
    tagId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'book_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookTagRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('rev')) {
      context.handle(
        _revMeta,
        rev.isAcceptableOrUnknown(data['rev']!, _revMeta),
      );
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookTagRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookTagRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      rev: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rev'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $BookTagsTable createAlias(String alias) {
    return $BookTagsTable(attachedDatabase, alias);
  }
}

class BookTagRow extends DataClass implements Insertable<BookTagRow> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final int rev;
  final String bookId;
  final String tagId;
  const BookTagRow({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.rev,
    required this.bookId,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['rev'] = Variable<int>(rev);
    map['book_id'] = Variable<String>(bookId);
    map['tag_id'] = Variable<String>(tagId);
    return map;
  }

  BookTagsCompanion toCompanion(bool nullToAbsent) {
    return BookTagsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      rev: Value(rev),
      bookId: Value(bookId),
      tagId: Value(tagId),
    );
  }

  factory BookTagRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookTagRow(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      rev: serializer.fromJson<int>(json['rev']),
      bookId: serializer.fromJson<String>(json['bookId']),
      tagId: serializer.fromJson<String>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'rev': serializer.toJson<int>(rev),
      'bookId': serializer.toJson<String>(bookId),
      'tagId': serializer.toJson<String>(tagId),
    };
  }

  BookTagRow copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    int? rev,
    String? bookId,
    String? tagId,
  }) => BookTagRow(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    rev: rev ?? this.rev,
    bookId: bookId ?? this.bookId,
    tagId: tagId ?? this.tagId,
  );
  BookTagRow copyWithCompanion(BookTagsCompanion data) {
    return BookTagRow(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      rev: data.rev.present ? data.rev.value : this.rev,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookTagRow(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, createdAt, updatedAt, deletedAt, rev, bookId, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookTagRow &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.rev == this.rev &&
          other.bookId == this.bookId &&
          other.tagId == this.tagId);
}

class BookTagsCompanion extends UpdateCompanion<BookTagRow> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<int> rev;
  final Value<String> bookId;
  final Value<String> tagId;
  final Value<int> rowid;
  const BookTagsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    this.bookId = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BookTagsCompanion.insert({
    this.id = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    this.rev = const Value.absent(),
    required String bookId,
    required String tagId,
    this.rowid = const Value.absent(),
  }) : createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       bookId = Value(bookId),
       tagId = Value(tagId);
  static Insertable<BookTagRow> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<int>? rev,
    Expression<String>? bookId,
    Expression<String>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (rev != null) 'rev': rev,
      if (bookId != null) 'book_id': bookId,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BookTagsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<int>? rev,
    Value<String>? bookId,
    Value<String>? tagId,
    Value<int>? rowid,
  }) {
    return BookTagsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      rev: rev ?? this.rev,
      bookId: bookId ?? this.bookId,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (rev.present) {
      map['rev'] = Variable<int>(rev.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<String>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BookTagsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('rev: $rev, ')
          ..write('bookId: $bookId, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class BooksFts extends Table
    with TableInfo<BooksFts, BooksFt>, VirtualTableInfo<BooksFts, BooksFt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  BooksFts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _subtitleMeta = const VerificationMeta(
    'subtitle',
  );
  late final GeneratedColumn<String> subtitle = GeneratedColumn<String>(
    'subtitle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  static const VerificationMeta _authorsMeta = const VerificationMeta(
    'authors',
  );
  late final GeneratedColumn<String> authors = GeneratedColumn<String>(
    'authors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [title, subtitle, authors];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books_fts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BooksFt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('subtitle')) {
      context.handle(
        _subtitleMeta,
        subtitle.isAcceptableOrUnknown(data['subtitle']!, _subtitleMeta),
      );
    } else if (isInserting) {
      context.missing(_subtitleMeta);
    }
    if (data.containsKey('authors')) {
      context.handle(
        _authorsMeta,
        authors.isAcceptableOrUnknown(data['authors']!, _authorsMeta),
      );
    } else if (isInserting) {
      context.missing(_authorsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  BooksFt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BooksFt(
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      subtitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subtitle'],
      )!,
      authors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}authors'],
      )!,
    );
  }

  @override
  BooksFts createAlias(String alias) {
    return BooksFts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
  @override
  String get moduleAndArgs =>
      'fts5(title, subtitle, authors, content = \'books\', content_rowid = \'rowid\', tokenize = \'unicode61 remove_diacritics 2\')';
}

class BooksFt extends DataClass implements Insertable<BooksFt> {
  final String title;
  final String subtitle;
  final String authors;
  const BooksFt({
    required this.title,
    required this.subtitle,
    required this.authors,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['title'] = Variable<String>(title);
    map['subtitle'] = Variable<String>(subtitle);
    map['authors'] = Variable<String>(authors);
    return map;
  }

  BooksFtsCompanion toCompanion(bool nullToAbsent) {
    return BooksFtsCompanion(
      title: Value(title),
      subtitle: Value(subtitle),
      authors: Value(authors),
    );
  }

  factory BooksFt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BooksFt(
      title: serializer.fromJson<String>(json['title']),
      subtitle: serializer.fromJson<String>(json['subtitle']),
      authors: serializer.fromJson<String>(json['authors']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'title': serializer.toJson<String>(title),
      'subtitle': serializer.toJson<String>(subtitle),
      'authors': serializer.toJson<String>(authors),
    };
  }

  BooksFt copyWith({String? title, String? subtitle, String? authors}) =>
      BooksFt(
        title: title ?? this.title,
        subtitle: subtitle ?? this.subtitle,
        authors: authors ?? this.authors,
      );
  BooksFt copyWithCompanion(BooksFtsCompanion data) {
    return BooksFt(
      title: data.title.present ? data.title.value : this.title,
      subtitle: data.subtitle.present ? data.subtitle.value : this.subtitle,
      authors: data.authors.present ? data.authors.value : this.authors,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BooksFt(')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(title, subtitle, authors);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BooksFt &&
          other.title == this.title &&
          other.subtitle == this.subtitle &&
          other.authors == this.authors);
}

class BooksFtsCompanion extends UpdateCompanion<BooksFt> {
  final Value<String> title;
  final Value<String> subtitle;
  final Value<String> authors;
  final Value<int> rowid;
  const BooksFtsCompanion({
    this.title = const Value.absent(),
    this.subtitle = const Value.absent(),
    this.authors = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BooksFtsCompanion.insert({
    required String title,
    required String subtitle,
    required String authors,
    this.rowid = const Value.absent(),
  }) : title = Value(title),
       subtitle = Value(subtitle),
       authors = Value(authors);
  static Insertable<BooksFt> custom({
    Expression<String>? title,
    Expression<String>? subtitle,
    Expression<String>? authors,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (title != null) 'title': title,
      if (subtitle != null) 'subtitle': subtitle,
      if (authors != null) 'authors': authors,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BooksFtsCompanion copyWith({
    Value<String>? title,
    Value<String>? subtitle,
    Value<String>? authors,
    Value<int>? rowid,
  }) {
    return BooksFtsCompanion(
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      authors: authors ?? this.authors,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (subtitle.present) {
      map['subtitle'] = Variable<String>(subtitle.value);
    }
    if (authors.present) {
      map['authors'] = Variable<String>(authors.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksFtsCompanion(')
          ..write('title: $title, ')
          ..write('subtitle: $subtitle, ')
          ..write('authors: $authors, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LookupCacheTable extends LookupCache
    with TableInfo<$LookupCacheTable, LookupCacheRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LookupCacheTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadJsonMeta = const VerificationMeta(
    'payloadJson',
  );
  @override
  late final GeneratedColumn<String> payloadJson = GeneratedColumn<String>(
    'payload_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fetchedAtMeta = const VerificationMeta(
    'fetchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> fetchedAt = GeneratedColumn<DateTime>(
    'fetched_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isNotFoundMeta = const VerificationMeta(
    'isNotFound',
  );
  @override
  late final GeneratedColumn<bool> isNotFound = GeneratedColumn<bool>(
    'is_not_found',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_not_found" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    key,
    payloadJson,
    fetchedAt,
    isNotFound,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lookup_cache';
  @override
  VerificationContext validateIntegrity(
    Insertable<LookupCacheRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('payload_json')) {
      context.handle(
        _payloadJsonMeta,
        payloadJson.isAcceptableOrUnknown(
          data['payload_json']!,
          _payloadJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_payloadJsonMeta);
    }
    if (data.containsKey('fetched_at')) {
      context.handle(
        _fetchedAtMeta,
        fetchedAt.isAcceptableOrUnknown(data['fetched_at']!, _fetchedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_fetchedAtMeta);
    }
    if (data.containsKey('is_not_found')) {
      context.handle(
        _isNotFoundMeta,
        isNotFound.isAcceptableOrUnknown(
          data['is_not_found']!,
          _isNotFoundMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  LookupCacheRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LookupCacheRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      payloadJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload_json'],
      )!,
      fetchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fetched_at'],
      )!,
      isNotFound: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_not_found'],
      )!,
    );
  }

  @override
  $LookupCacheTable createAlias(String alias) {
    return $LookupCacheTable(attachedDatabase, alias);
  }
}

class LookupCacheRow extends DataClass implements Insertable<LookupCacheRow> {
  final String key;
  final String payloadJson;
  final DateTime fetchedAt;
  final bool isNotFound;
  const LookupCacheRow({
    required this.key,
    required this.payloadJson,
    required this.fetchedAt,
    required this.isNotFound,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['payload_json'] = Variable<String>(payloadJson);
    map['fetched_at'] = Variable<DateTime>(fetchedAt);
    map['is_not_found'] = Variable<bool>(isNotFound);
    return map;
  }

  LookupCacheCompanion toCompanion(bool nullToAbsent) {
    return LookupCacheCompanion(
      key: Value(key),
      payloadJson: Value(payloadJson),
      fetchedAt: Value(fetchedAt),
      isNotFound: Value(isNotFound),
    );
  }

  factory LookupCacheRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LookupCacheRow(
      key: serializer.fromJson<String>(json['key']),
      payloadJson: serializer.fromJson<String>(json['payloadJson']),
      fetchedAt: serializer.fromJson<DateTime>(json['fetchedAt']),
      isNotFound: serializer.fromJson<bool>(json['isNotFound']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'payloadJson': serializer.toJson<String>(payloadJson),
      'fetchedAt': serializer.toJson<DateTime>(fetchedAt),
      'isNotFound': serializer.toJson<bool>(isNotFound),
    };
  }

  LookupCacheRow copyWith({
    String? key,
    String? payloadJson,
    DateTime? fetchedAt,
    bool? isNotFound,
  }) => LookupCacheRow(
    key: key ?? this.key,
    payloadJson: payloadJson ?? this.payloadJson,
    fetchedAt: fetchedAt ?? this.fetchedAt,
    isNotFound: isNotFound ?? this.isNotFound,
  );
  LookupCacheRow copyWithCompanion(LookupCacheCompanion data) {
    return LookupCacheRow(
      key: data.key.present ? data.key.value : this.key,
      payloadJson: data.payloadJson.present
          ? data.payloadJson.value
          : this.payloadJson,
      fetchedAt: data.fetchedAt.present ? data.fetchedAt.value : this.fetchedAt,
      isNotFound: data.isNotFound.present
          ? data.isNotFound.value
          : this.isNotFound,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LookupCacheRow(')
          ..write('key: $key, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isNotFound: $isNotFound')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, payloadJson, fetchedAt, isNotFound);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LookupCacheRow &&
          other.key == this.key &&
          other.payloadJson == this.payloadJson &&
          other.fetchedAt == this.fetchedAt &&
          other.isNotFound == this.isNotFound);
}

class LookupCacheCompanion extends UpdateCompanion<LookupCacheRow> {
  final Value<String> key;
  final Value<String> payloadJson;
  final Value<DateTime> fetchedAt;
  final Value<bool> isNotFound;
  final Value<int> rowid;
  const LookupCacheCompanion({
    this.key = const Value.absent(),
    this.payloadJson = const Value.absent(),
    this.fetchedAt = const Value.absent(),
    this.isNotFound = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LookupCacheCompanion.insert({
    required String key,
    required String payloadJson,
    required DateTime fetchedAt,
    this.isNotFound = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       payloadJson = Value(payloadJson),
       fetchedAt = Value(fetchedAt);
  static Insertable<LookupCacheRow> custom({
    Expression<String>? key,
    Expression<String>? payloadJson,
    Expression<DateTime>? fetchedAt,
    Expression<bool>? isNotFound,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (payloadJson != null) 'payload_json': payloadJson,
      if (fetchedAt != null) 'fetched_at': fetchedAt,
      if (isNotFound != null) 'is_not_found': isNotFound,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LookupCacheCompanion copyWith({
    Value<String>? key,
    Value<String>? payloadJson,
    Value<DateTime>? fetchedAt,
    Value<bool>? isNotFound,
    Value<int>? rowid,
  }) {
    return LookupCacheCompanion(
      key: key ?? this.key,
      payloadJson: payloadJson ?? this.payloadJson,
      fetchedAt: fetchedAt ?? this.fetchedAt,
      isNotFound: isNotFound ?? this.isNotFound,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (payloadJson.present) {
      map['payload_json'] = Variable<String>(payloadJson.value);
    }
    if (fetchedAt.present) {
      map['fetched_at'] = Variable<DateTime>(fetchedAt.value);
    }
    if (isNotFound.present) {
      map['is_not_found'] = Variable<bool>(isNotFound.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LookupCacheCompanion(')
          ..write('key: $key, ')
          ..write('payloadJson: $payloadJson, ')
          ..write('fetchedAt: $fetchedAt, ')
          ..write('isNotFound: $isNotFound, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaRow extends DataClass implements Insertable<AppMetaRow> {
  final String key;
  final String value;
  const AppMetaRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaRow copyWith({String? key, String? value}) =>
      AppMetaRow(key: key ?? this.key, value: value ?? this.value);
  AppMetaRow copyWithCompanion(AppMetaCompanion data) {
    return AppMetaRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaRow &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CoverBlobsTable extends CoverBlobs
    with TableInfo<$CoverBlobsTable, CoverBlobRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoverBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<String> bookId = GeneratedColumn<String>(
    'book_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<Uint8List> bytes = GeneratedColumn<Uint8List>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [bookId, bytes, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cover_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CoverBlobRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    } else if (isInserting) {
      context.missing(_bookIdMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {bookId};
  @override
  CoverBlobRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CoverBlobRow(
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}book_id'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}bytes'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CoverBlobsTable createAlias(String alias) {
    return $CoverBlobsTable(attachedDatabase, alias);
  }
}

class CoverBlobRow extends DataClass implements Insertable<CoverBlobRow> {
  final String bookId;
  final Uint8List bytes;
  final DateTime updatedAt;
  const CoverBlobRow({
    required this.bookId,
    required this.bytes,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['book_id'] = Variable<String>(bookId);
    map['bytes'] = Variable<Uint8List>(bytes);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CoverBlobsCompanion toCompanion(bool nullToAbsent) {
    return CoverBlobsCompanion(
      bookId: Value(bookId),
      bytes: Value(bytes),
      updatedAt: Value(updatedAt),
    );
  }

  factory CoverBlobRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CoverBlobRow(
      bookId: serializer.fromJson<String>(json['bookId']),
      bytes: serializer.fromJson<Uint8List>(json['bytes']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'bookId': serializer.toJson<String>(bookId),
      'bytes': serializer.toJson<Uint8List>(bytes),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  CoverBlobRow copyWith({
    String? bookId,
    Uint8List? bytes,
    DateTime? updatedAt,
  }) => CoverBlobRow(
    bookId: bookId ?? this.bookId,
    bytes: bytes ?? this.bytes,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  CoverBlobRow copyWithCompanion(CoverBlobsCompanion data) {
    return CoverBlobRow(
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CoverBlobRow(')
          ..write('bookId: $bookId, ')
          ..write('bytes: $bytes, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(bookId, $driftBlobEquality.hash(bytes), updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CoverBlobRow &&
          other.bookId == this.bookId &&
          $driftBlobEquality.equals(other.bytes, this.bytes) &&
          other.updatedAt == this.updatedAt);
}

class CoverBlobsCompanion extends UpdateCompanion<CoverBlobRow> {
  final Value<String> bookId;
  final Value<Uint8List> bytes;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const CoverBlobsCompanion({
    this.bookId = const Value.absent(),
    this.bytes = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoverBlobsCompanion.insert({
    required String bookId,
    required Uint8List bytes,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : bookId = Value(bookId),
       bytes = Value(bytes),
       updatedAt = Value(updatedAt);
  static Insertable<CoverBlobRow> custom({
    Expression<String>? bookId,
    Expression<Uint8List>? bytes,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (bookId != null) 'book_id': bookId,
      if (bytes != null) 'bytes': bytes,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoverBlobsCompanion copyWith({
    Value<String>? bookId,
    Value<Uint8List>? bytes,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return CoverBlobsCompanion(
      bookId: bookId ?? this.bookId,
      bytes: bytes ?? this.bytes,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (bookId.present) {
      map['book_id'] = Variable<String>(bookId.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<Uint8List>(bytes.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoverBlobsCompanion(')
          ..write('bookId: $bookId, ')
          ..write('bytes: $bytes, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LocationsTable locations = $LocationsTable(this);
  late final $BooksTable books = $BooksTable(this);
  late final Index idxBooksIsbn13 = Index(
    'idx_books_isbn13',
    'CREATE INDEX idx_books_isbn13 ON books (isbn13)',
  );
  late final Index idxBooksOlWorkKey = Index(
    'idx_books_ol_work_key',
    'CREATE INDEX idx_books_ol_work_key ON books (ol_work_key)',
  );
  late final Index idxBooksTitleKey = Index(
    'idx_books_title_key',
    'CREATE INDEX idx_books_title_key ON books (title_key)',
  );
  late final Index idxBooksLocationId = Index(
    'idx_books_location_id',
    'CREATE INDEX idx_books_location_id ON books (location_id)',
  );
  late final Index idxBooksOwnershipStatus = Index(
    'idx_books_ownership_status',
    'CREATE INDEX idx_books_ownership_status ON books (ownership, status)',
  );
  late final $ReadingLogsTable readingLogs = $ReadingLogsTable(this);
  late final Index idxReadingLogsBookDate = Index(
    'idx_reading_logs_book_date',
    'CREATE INDEX idx_reading_logs_book_date ON reading_logs (book_id, date)',
  );
  late final $QuotesTable quotes = $QuotesTable(this);
  late final Index idxQuotesBookId = Index(
    'idx_quotes_book_id',
    'CREATE INDEX idx_quotes_book_id ON quotes (book_id)',
  );
  late final $LoansTable loans = $LoansTable(this);
  late final Index idxLoansBookId = Index(
    'idx_loans_book_id',
    'CREATE INDEX idx_loans_book_id ON loans (book_id)',
  );
  late final Index idxLoansDueOpen = Index(
    'idx_loans_due_open',
    'CREATE INDEX idx_loans_due_open ON loans (due_on) WHERE returned_on IS NULL',
  );
  late final Index uqLoansOneActivePerBook = Index(
    'uq_loans_one_active_per_book',
    'CREATE UNIQUE INDEX uq_loans_one_active_per_book ON loans (book_id) WHERE returned_on IS NULL AND deleted_at IS NULL',
  );
  late final $GoalsTable goals = $GoalsTable(this);
  late final Index uqGoalsYear = Index(
    'uq_goals_year',
    'CREATE UNIQUE INDEX uq_goals_year ON goals (year) WHERE deleted_at IS NULL',
  );
  late final $TagsTable tags = $TagsTable(this);
  late final Index uqTagsName = Index(
    'uq_tags_name',
    'CREATE UNIQUE INDEX uq_tags_name ON tags (lower(name)) WHERE deleted_at IS NULL',
  );
  late final $BookTagsTable bookTags = $BookTagsTable(this);
  late final Index uqBookTagsPair = Index(
    'uq_book_tags_pair',
    'CREATE UNIQUE INDEX uq_book_tags_pair ON book_tags (book_id, tag_id) WHERE deleted_at IS NULL',
  );
  late final Index uqLocationsName = Index(
    'uq_locations_name',
    'CREATE UNIQUE INDEX uq_locations_name ON locations (lower(name), coalesce(parent_id, \'\')) WHERE deleted_at IS NULL',
  );
  late final BooksFts booksFts = BooksFts(this);
  late final Trigger booksFtsAi = Trigger(
    'CREATE TRIGGER books_fts_ai AFTER INSERT ON books WHEN new.deleted_at IS NULL BEGIN INSERT INTO books_fts ("rowid", title, subtitle, authors) VALUES (new."rowid", new.title, new.subtitle, new.authors);END',
    'books_fts_ai',
  );
  late final Trigger booksFtsAd = Trigger(
    'CREATE TRIGGER books_fts_ad AFTER DELETE ON books WHEN old.deleted_at IS NULL BEGIN INSERT INTO books_fts (books_fts, "rowid", title, subtitle, authors) VALUES (\'delete\', old."rowid", old.title, old.subtitle, old.authors);END',
    'books_fts_ad',
  );
  late final Trigger booksFtsAu = Trigger(
    'CREATE TRIGGER books_fts_au AFTER UPDATE ON books BEGIN INSERT INTO books_fts (books_fts, "rowid", title, subtitle, authors) SELECT \'delete\', old."rowid", old.title, old.subtitle, old.authors WHERE old.deleted_at IS NULL;INSERT INTO books_fts ("rowid", title, subtitle, authors) SELECT new."rowid", new.title, new.subtitle, new.authors WHERE new.deleted_at IS NULL;END',
    'books_fts_au',
  );
  late final $LookupCacheTable lookupCache = $LookupCacheTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  late final $CoverBlobsTable coverBlobs = $CoverBlobsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    locations,
    books,
    idxBooksIsbn13,
    idxBooksOlWorkKey,
    idxBooksTitleKey,
    idxBooksLocationId,
    idxBooksOwnershipStatus,
    readingLogs,
    idxReadingLogsBookDate,
    quotes,
    idxQuotesBookId,
    loans,
    idxLoansBookId,
    idxLoansDueOpen,
    uqLoansOneActivePerBook,
    goals,
    uqGoalsYear,
    tags,
    uqTagsName,
    bookTags,
    uqBookTagsPair,
    uqLocationsName,
    booksFts,
    booksFtsAi,
    booksFtsAd,
    booksFtsAu,
    lookupCache,
    appMeta,
    coverBlobs,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('locations', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('books', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'locations',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('loans', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [TableUpdate('books_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('books_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [TableUpdate('books_fts', kind: UpdateKind.insert)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cover_blobs', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$LocationsTableCreateCompanionBuilder = LocationsCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required String name,
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<String?> icon,
  Value<int> rowid,
});
typedef $$LocationsTableUpdateCompanionBuilder = LocationsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String> name,
  Value<String?> parentId,
  Value<int> sortOrder,
  Value<String?> icon,
  Value<int> rowid,
});

final class $$LocationsTableReferences
    extends BaseReferences<_$AppDatabase, $LocationsTable, LocationRow> {
  $$LocationsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocationsTable _parentIdTable(_$AppDatabase db) =>
      db.locations.createAlias('locations__parent_id__locations__id');

  $$LocationsTableProcessedTableManager? get parentId {
    final $_column = $_itemColumn<String>('parent_id');
    if ($_column == null) return null;
    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_parentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$BooksTable, List<BookRow>> _booksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.books,
    aliasName: 'locations__id__books__location_id',
  );

  $$BooksTableProcessedTableManager get booksRefs {
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.locationId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_booksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoansTable, List<LoanRow>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'locations__id__loans__previous_location_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager($_db, $_db.loans).filter(
      (f) => f.previousLocationId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$LocationsTableFilterComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  $$LocationsTableFilterComposer get parentId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> booksRefs(
    Expression<bool> Function($$BooksTableFilterComposer f) f,
  ) {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.previousLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableOrderingComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocationsTableOrderingComposer get parentId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableOrderingComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LocationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $LocationsTable> {
  $$LocationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  $$LocationsTableAnnotationComposer get parentId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.parentId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> booksRefs<T extends Object>(
    Expression<T> Function($$BooksTableAnnotationComposer a) f,
  ) {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.locationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.previousLocationId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$LocationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LocationsTable,
          LocationRow,
          $$LocationsTableFilterComposer,
          $$LocationsTableOrderingComposer,
          $$LocationsTableAnnotationComposer,
          $$LocationsTableCreateCompanionBuilder,
          $$LocationsTableUpdateCompanionBuilder,
          (LocationRow, $$LocationsTableReferences),
          LocationRow,
          PrefetchHooks Function({
            bool parentId,
            bool booksRefs,
            bool loansRefs,
          })
        > {
  $$LocationsTableTableManager(_$AppDatabase db, $LocationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                name: name,
                parentId: parentId,
                sortOrder: sortOrder,
                icon: icon,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String name,
                Value<String?> parentId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<String?> icon = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                name: name,
                parentId: parentId,
                sortOrder: sortOrder,
                icon: icon,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LocationsTable, LocationRow>(table),
                  $$LocationsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({parentId = false, booksRefs = false, loansRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (booksRefs) db.books,
                    if (loansRefs) db.loans,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (parentId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.parentId,
                            referencedTable: $$LocationsTableReferences
                                ._parentIdTable(db),
                            referencedColumn: $$LocationsTableReferences
                                ._parentIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (booksRefs)
                        await $_getPrefetchedDataByColumns<
                          LocationRow,
                          $LocationsTable,
                          BookRow,
                          $BooksTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocationsTableReferences
                              ._booksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).booksRefs,
                          currentColumn: 'id',
                          referencedColumn: 'location_id',
                          typedResults: items,
                        ),
                      if (loansRefs)
                        await $_getPrefetchedDataByColumns<
                          LocationRow,
                          $LocationsTable,
                          LoanRow,
                          $LoansTable
                        >(
                          currentTable: table,
                          referencedTable: $$LocationsTableReferences
                              ._loansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$LocationsTableReferences(
                                db,
                                table,
                                p0,
                              ).loansRefs,
                          currentColumn: 'id',
                          referencedColumn: 'previous_location_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$LocationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LocationsTable,
      LocationRow,
      $$LocationsTableFilterComposer,
      $$LocationsTableOrderingComposer,
      $$LocationsTableAnnotationComposer,
      $$LocationsTableCreateCompanionBuilder,
      $$LocationsTableUpdateCompanionBuilder,
      (LocationRow, $$LocationsTableReferences),
      LocationRow,
      PrefetchHooks Function({bool parentId, bool booksRefs, bool loansRefs})
    >;
typedef $$BooksTableCreateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String?> isbn13,
  Value<String?> olWorkKey,
  required String title,
  Value<String?> subtitle,
  Value<String> authors,
  required String titleKey,
  Value<String?> coverUrl,
  Value<String?> coverLocalPath,
  Value<int?> pages,
  Value<String> genre,
  Value<String> language,
  Value<Ownership> ownership,
  Value<ReadStatus> status,
  Value<int> currentPage,
  Value<int?> rating,
  Value<String?> locationId,
  Value<String?> ownerName,
  Value<String?> notes,
  Value<DateTime?> startedOn,
  Value<DateTime?> finishedOn,
  Value<int> rowid,
});
typedef $$BooksTableUpdateCompanionBuilder = BooksCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String?> isbn13,
  Value<String?> olWorkKey,
  Value<String> title,
  Value<String?> subtitle,
  Value<String> authors,
  Value<String> titleKey,
  Value<String?> coverUrl,
  Value<String?> coverLocalPath,
  Value<int?> pages,
  Value<String> genre,
  Value<String> language,
  Value<Ownership> ownership,
  Value<ReadStatus> status,
  Value<int> currentPage,
  Value<int?> rating,
  Value<String?> locationId,
  Value<String?> ownerName,
  Value<String?> notes,
  Value<DateTime?> startedOn,
  Value<DateTime?> finishedOn,
  Value<int> rowid,
});

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $LocationsTable _locationIdTable(_$AppDatabase db) =>
      db.locations.createAlias('books__location_id__locations__id');

  $$LocationsTableProcessedTableManager? get locationId {
    final $_column = $_itemColumn<String>('location_id');
    if ($_column == null) return null;
    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_locationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$ReadingLogsTable, List<ReadingLogRow>>
  _readingLogsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.readingLogs,
    aliasName: 'books__id__reading_logs__book_id',
  );

  $$ReadingLogsTableProcessedTableManager get readingLogsRefs {
    final manager = $$ReadingLogsTableTableManager(
      $_db,
      $_db.readingLogs,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_readingLogsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$QuotesTable, List<QuoteRow>> _quotesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.quotes,
    aliasName: 'books__id__quotes__book_id',
  );

  $$QuotesTableProcessedTableManager get quotesRefs {
    final manager = $$QuotesTableTableManager(
      $_db,
      $_db.quotes,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_quotesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$LoansTable, List<LoanRow>> _loansRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.loans,
    aliasName: 'books__id__loans__book_id',
  );

  $$LoansTableProcessedTableManager get loansRefs {
    final manager = $$LoansTableTableManager(
      $_db,
      $_db.loans,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_loansRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$BookTagsTable, List<BookTagRow>>
  _bookTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'books__id__book_tags__book_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CoverBlobsTable, List<CoverBlobRow>>
  _coverBlobsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.coverBlobs,
    aliasName: 'books__id__cover_blobs__book_id',
  );

  $$CoverBlobsTableProcessedTableManager get coverBlobsRefs {
    final manager = $$CoverBlobsTableTableManager(
      $_db,
      $_db.coverBlobs,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_coverBlobsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get olWorkKey => $composableBuilder(
    column: $table.olWorkKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get titleKey => $composableBuilder(
    column: $table.titleKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Ownership, Ownership, String> get ownership =>
      $composableBuilder(
        column: $table.ownership,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<ReadStatus, ReadStatus, String> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get startedOn =>
      $composableBuilder(
        column: $table.startedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get finishedOn =>
      $composableBuilder(
        column: $table.finishedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$LocationsTableFilterComposer get locationId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> readingLogsRefs(
    Expression<bool> Function($$ReadingLogsTableFilterComposer f) f,
  ) {
    final $$ReadingLogsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableFilterComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> quotesRefs(
    Expression<bool> Function($$QuotesTableFilterComposer f) f,
  ) {
    final $$QuotesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableFilterComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> loansRefs(
    Expression<bool> Function($$LoansTableFilterComposer f) f,
  ) {
    final $$LoansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableFilterComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> coverBlobsRefs(
    Expression<bool> Function($$CoverBlobsTableFilterComposer f) f,
  ) {
    final $$CoverBlobsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coverBlobs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoverBlobsTableFilterComposer(
            $db: $db,
            $table: $db.coverBlobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get isbn13 => $composableBuilder(
    column: $table.isbn13,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get olWorkKey => $composableBuilder(
    column: $table.olWorkKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get titleKey => $composableBuilder(
    column: $table.titleKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pages => $composableBuilder(
    column: $table.pages,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownership => $composableBuilder(
    column: $table.ownership,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ownerName => $composableBuilder(
    column: $table.ownerName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get finishedOn => $composableBuilder(
    column: $table.finishedOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$LocationsTableOrderingComposer get locationId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableOrderingComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get isbn13 =>
      $composableBuilder(column: $table.isbn13, builder: (column) => column);

  GeneratedColumn<String> get olWorkKey =>
      $composableBuilder(column: $table.olWorkKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);

  GeneratedColumn<String> get titleKey =>
      $composableBuilder(column: $table.titleKey, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<String> get coverLocalPath => $composableBuilder(
    column: $table.coverLocalPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pages =>
      $composableBuilder(column: $table.pages, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Ownership, String> get ownership =>
      $composableBuilder(column: $table.ownership, builder: (column) => column);

  GeneratedColumnWithTypeConverter<ReadStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get ownerName =>
      $composableBuilder(column: $table.ownerName, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get finishedOn =>
      $composableBuilder(
        column: $table.finishedOn,
        builder: (column) => column,
      );

  $$LocationsTableAnnotationComposer get locationId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.locationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> readingLogsRefs<T extends Object>(
    Expression<T> Function($$ReadingLogsTableAnnotationComposer a) f,
  ) {
    final $$ReadingLogsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.readingLogs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ReadingLogsTableAnnotationComposer(
            $db: $db,
            $table: $db.readingLogs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> quotesRefs<T extends Object>(
    Expression<T> Function($$QuotesTableAnnotationComposer a) f,
  ) {
    final $$QuotesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.quotes,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QuotesTableAnnotationComposer(
            $db: $db,
            $table: $db.quotes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> loansRefs<T extends Object>(
    Expression<T> Function($$LoansTableAnnotationComposer a) f,
  ) {
    final $$LoansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.loans,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LoansTableAnnotationComposer(
            $db: $db,
            $table: $db.loans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> coverBlobsRefs<T extends Object>(
    Expression<T> Function($$CoverBlobsTableAnnotationComposer a) f,
  ) {
    final $$CoverBlobsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.coverBlobs,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CoverBlobsTableAnnotationComposer(
            $db: $db,
            $table: $db.coverBlobs,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, $$BooksTableReferences),
          BookRow,
          PrefetchHooks Function({
            bool locationId,
            bool readingLogsRefs,
            bool quotesRefs,
            bool loansRefs,
            bool bookTagsRefs,
            bool coverBlobsRefs,
          })
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                Value<String?> olWorkKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> subtitle = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<String> titleKey = const Value.absent(),
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverLocalPath = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<Ownership> ownership = const Value.absent(),
                Value<ReadStatus> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> startedOn = const Value.absent(),
                Value<DateTime?> finishedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                isbn13: isbn13,
                olWorkKey: olWorkKey,
                title: title,
                subtitle: subtitle,
                authors: authors,
                titleKey: titleKey,
                coverUrl: coverUrl,
                coverLocalPath: coverLocalPath,
                pages: pages,
                genre: genre,
                language: language,
                ownership: ownership,
                status: status,
                currentPage: currentPage,
                rating: rating,
                locationId: locationId,
                ownerName: ownerName,
                notes: notes,
                startedOn: startedOn,
                finishedOn: finishedOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String?> isbn13 = const Value.absent(),
                Value<String?> olWorkKey = const Value.absent(),
                required String title,
                Value<String?> subtitle = const Value.absent(),
                Value<String> authors = const Value.absent(),
                required String titleKey,
                Value<String?> coverUrl = const Value.absent(),
                Value<String?> coverLocalPath = const Value.absent(),
                Value<int?> pages = const Value.absent(),
                Value<String> genre = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<Ownership> ownership = const Value.absent(),
                Value<ReadStatus> status = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> locationId = const Value.absent(),
                Value<String?> ownerName = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime?> startedOn = const Value.absent(),
                Value<DateTime?> finishedOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                isbn13: isbn13,
                olWorkKey: olWorkKey,
                title: title,
                subtitle: subtitle,
                authors: authors,
                titleKey: titleKey,
                coverUrl: coverUrl,
                coverLocalPath: coverLocalPath,
                pages: pages,
                genre: genre,
                language: language,
                ownership: ownership,
                status: status,
                currentPage: currentPage,
                rating: rating,
                locationId: locationId,
                ownerName: ownerName,
                notes: notes,
                startedOn: startedOn,
                finishedOn: finishedOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BooksTable, BookRow>(table),
                  $$BooksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                locationId = false,
                readingLogsRefs = false,
                quotesRefs = false,
                loansRefs = false,
                bookTagsRefs = false,
                coverBlobsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (readingLogsRefs) db.readingLogs,
                    if (quotesRefs) db.quotes,
                    if (loansRefs) db.loans,
                    if (bookTagsRefs) db.bookTags,
                    if (coverBlobsRefs) db.coverBlobs,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (locationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.locationId,
                            referencedTable: $$BooksTableReferences
                                ._locationIdTable(db),
                            referencedColumn: $$BooksTableReferences
                                ._locationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (readingLogsRefs)
                        await $_getPrefetchedDataByColumns<
                          BookRow,
                          $BooksTable,
                          ReadingLogRow,
                          $ReadingLogsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._readingLogsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).readingLogsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (quotesRefs)
                        await $_getPrefetchedDataByColumns<
                          BookRow,
                          $BooksTable,
                          QuoteRow,
                          $QuotesTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._quotesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).quotesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (loansRefs)
                        await $_getPrefetchedDataByColumns<
                          BookRow,
                          $BooksTable,
                          LoanRow,
                          $LoansTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._loansRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(db, table, p0).loansRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (bookTagsRefs)
                        await $_getPrefetchedDataByColumns<
                          BookRow,
                          $BooksTable,
                          BookTagRow,
                          $BookTagsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._bookTagsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).bookTagsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                      if (coverBlobsRefs)
                        await $_getPrefetchedDataByColumns<
                          BookRow,
                          $BooksTable,
                          CoverBlobRow,
                          $CoverBlobsTable
                        >(
                          currentTable: table,
                          referencedTable: $$BooksTableReferences
                              ._coverBlobsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$BooksTableReferences(
                                db,
                                table,
                                p0,
                              ).coverBlobsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'book_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, $$BooksTableReferences),
      BookRow,
      PrefetchHooks Function({
        bool locationId,
        bool readingLogsRefs,
        bool quotesRefs,
        bool loansRefs,
        bool bookTagsRefs,
        bool coverBlobsRefs,
      })
    >;
typedef $$ReadingLogsTableCreateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<String> id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rev,
      required String bookId,
      required DateTime date,
      required int pagesRead,
      required int fromPage,
      required int toPage,
      Value<int> rowid,
    });
typedef $$ReadingLogsTableUpdateCompanionBuilder =
    ReadingLogsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<int> rev,
      Value<String> bookId,
      Value<DateTime> date,
      Value<int> pagesRead,
      Value<int> fromPage,
      Value<int> toPage,
      Value<int> rowid,
    });

final class $$ReadingLogsTableReferences
    extends BaseReferences<_$AppDatabase, $ReadingLogsTable, ReadingLogRow> {
  $$ReadingLogsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('reading_logs__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ReadingLogsTableFilterComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromPage => $composableBuilder(
    column: $table.fromPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toPage => $composableBuilder(
    column: $table.toPage,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pagesRead => $composableBuilder(
    column: $table.pagesRead,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromPage => $composableBuilder(
    column: $table.fromPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toPage => $composableBuilder(
    column: $table.toPage,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReadingLogsTable> {
  $$ReadingLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get pagesRead =>
      $composableBuilder(column: $table.pagesRead, builder: (column) => column);

  GeneratedColumn<int> get fromPage =>
      $composableBuilder(column: $table.fromPage, builder: (column) => column);

  GeneratedColumn<int> get toPage =>
      $composableBuilder(column: $table.toPage, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ReadingLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReadingLogsTable,
          ReadingLogRow,
          $$ReadingLogsTableFilterComposer,
          $$ReadingLogsTableOrderingComposer,
          $$ReadingLogsTableAnnotationComposer,
          $$ReadingLogsTableCreateCompanionBuilder,
          $$ReadingLogsTableUpdateCompanionBuilder,
          (ReadingLogRow, $$ReadingLogsTableReferences),
          ReadingLogRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$ReadingLogsTableTableManager(_$AppDatabase db, $ReadingLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReadingLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReadingLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<int> pagesRead = const Value.absent(),
                Value<int> fromPage = const Value.absent(),
                Value<int> toPage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingLogsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                date: date,
                pagesRead: pagesRead,
                fromPage: fromPage,
                toPage: toPage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String bookId,
                required DateTime date,
                required int pagesRead,
                required int fromPage,
                required int toPage,
                Value<int> rowid = const Value.absent(),
              }) => ReadingLogsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                date: date,
                pagesRead: pagesRead,
                fromPage: fromPage,
                toPage: toPage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReadingLogsTable, ReadingLogRow>(table),
                  $$ReadingLogsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$ReadingLogsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$ReadingLogsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ReadingLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReadingLogsTable,
      ReadingLogRow,
      $$ReadingLogsTableFilterComposer,
      $$ReadingLogsTableOrderingComposer,
      $$ReadingLogsTableAnnotationComposer,
      $$ReadingLogsTableCreateCompanionBuilder,
      $$ReadingLogsTableUpdateCompanionBuilder,
      (ReadingLogRow, $$ReadingLogsTableReferences),
      ReadingLogRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$QuotesTableCreateCompanionBuilder = QuotesCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required String bookId,
  required String body,
  Value<int?> page,
  Value<bool> isFavourite,
  Value<int> rowid,
});
typedef $$QuotesTableUpdateCompanionBuilder = QuotesCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String> bookId,
  Value<String> body,
  Value<int?> page,
  Value<bool> isFavourite,
  Value<int> rowid,
});

final class $$QuotesTableReferences
    extends BaseReferences<_$AppDatabase, $QuotesTable, QuoteRow> {
  $$QuotesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('quotes__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QuotesTableFilterComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableOrderingComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get page => $composableBuilder(
    column: $table.page,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $QuotesTable> {
  $$QuotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<int> get page =>
      $composableBuilder(column: $table.page, builder: (column) => column);

  GeneratedColumn<bool> get isFavourite => $composableBuilder(
    column: $table.isFavourite,
    builder: (column) => column,
  );

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QuotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QuotesTable,
          QuoteRow,
          $$QuotesTableFilterComposer,
          $$QuotesTableOrderingComposer,
          $$QuotesTableAnnotationComposer,
          $$QuotesTableCreateCompanionBuilder,
          $$QuotesTableUpdateCompanionBuilder,
          (QuoteRow, $$QuotesTableReferences),
          QuoteRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$QuotesTableTableManager(_$AppDatabase db, $QuotesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int?> page = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                body: body,
                page: page,
                isFavourite: isFavourite,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String bookId,
                required String body,
                Value<int?> page = const Value.absent(),
                Value<bool> isFavourite = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuotesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                body: body,
                page: page,
                isFavourite: isFavourite,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$QuotesTable, QuoteRow>(table),
                  $$QuotesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$QuotesTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$QuotesTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$QuotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QuotesTable,
      QuoteRow,
      $$QuotesTableFilterComposer,
      $$QuotesTableOrderingComposer,
      $$QuotesTableAnnotationComposer,
      $$QuotesTableCreateCompanionBuilder,
      $$QuotesTableUpdateCompanionBuilder,
      (QuoteRow, $$QuotesTableReferences),
      QuoteRow,
      PrefetchHooks Function({bool bookId})
    >;
typedef $$LoansTableCreateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required String bookId,
  required LoanDirection direction,
  required String personName,
  Value<String?> personPhone,
  required DateTime startedOn,
  Value<DateTime?> dueOn,
  Value<DateTime?> returnedOn,
  Value<String?> previousLocationId,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$LoansTableUpdateCompanionBuilder = LoansCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String> bookId,
  Value<LoanDirection> direction,
  Value<String> personName,
  Value<String?> personPhone,
  Value<DateTime> startedOn,
  Value<DateTime?> dueOn,
  Value<DateTime?> returnedOn,
  Value<String?> previousLocationId,
  Value<String?> note,
  Value<int> rowid,
});

final class $$LoansTableReferences
    extends BaseReferences<_$AppDatabase, $LoansTable, LoanRow> {
  $$LoansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('loans__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $LocationsTable _previousLocationIdTable(_$AppDatabase db) =>
      db.locations.createAlias('loans__previous_location_id__locations__id');

  $$LocationsTableProcessedTableManager? get previousLocationId {
    final $_column = $_itemColumn<String>('previous_location_id');
    if ($_column == null) return null;
    final manager = $$LocationsTableTableManager(
      $_db,
      $_db.locations,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_previousLocationIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$LoansTableFilterComposer extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LoanDirection, LoanDirection, String>
  get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personPhone => $composableBuilder(
    column: $table.personPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DateTime, DateTime, String> get startedOn =>
      $composableBuilder(
        column: $table.startedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get dueOn =>
      $composableBuilder(
        column: $table.dueOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<DateTime?, DateTime, String> get returnedOn =>
      $composableBuilder(
        column: $table.returnedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableFilterComposer get previousLocationId {
    final $$LocationsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.previousLocationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableFilterComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableOrderingComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get direction => $composableBuilder(
    column: $table.direction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personPhone => $composableBuilder(
    column: $table.personPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startedOn => $composableBuilder(
    column: $table.startedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dueOn => $composableBuilder(
    column: $table.dueOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get returnedOn => $composableBuilder(
    column: $table.returnedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableOrderingComposer get previousLocationId {
    final $$LocationsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.previousLocationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableOrderingComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableAnnotationComposer
    extends Composer<_$AppDatabase, $LoansTable> {
  $$LoansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LoanDirection, String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personPhone => $composableBuilder(
    column: $table.personPhone,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DateTime, String> get startedOn =>
      $composableBuilder(column: $table.startedOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get dueOn =>
      $composableBuilder(column: $table.dueOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DateTime?, String> get returnedOn =>
      $composableBuilder(
        column: $table.returnedOn,
        builder: (column) => column,
      );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$LocationsTableAnnotationComposer get previousLocationId {
    final $$LocationsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.previousLocationId,
      referencedTable: $db.locations,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$LocationsTableAnnotationComposer(
            $db: $db,
            $table: $db.locations,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$LoansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LoansTable,
          LoanRow,
          $$LoansTableFilterComposer,
          $$LoansTableOrderingComposer,
          $$LoansTableAnnotationComposer,
          $$LoansTableCreateCompanionBuilder,
          $$LoansTableUpdateCompanionBuilder,
          (LoanRow, $$LoansTableReferences),
          LoanRow,
          PrefetchHooks Function({bool bookId, bool previousLocationId})
        > {
  $$LoansTableTableManager(_$AppDatabase db, $LoansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LoansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LoansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LoansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<LoanDirection> direction = const Value.absent(),
                Value<String> personName = const Value.absent(),
                Value<String?> personPhone = const Value.absent(),
                Value<DateTime> startedOn = const Value.absent(),
                Value<DateTime?> dueOn = const Value.absent(),
                Value<DateTime?> returnedOn = const Value.absent(),
                Value<String?> previousLocationId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                direction: direction,
                personName: personName,
                personPhone: personPhone,
                startedOn: startedOn,
                dueOn: dueOn,
                returnedOn: returnedOn,
                previousLocationId: previousLocationId,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String bookId,
                required LoanDirection direction,
                required String personName,
                Value<String?> personPhone = const Value.absent(),
                required DateTime startedOn,
                Value<DateTime?> dueOn = const Value.absent(),
                Value<DateTime?> returnedOn = const Value.absent(),
                Value<String?> previousLocationId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LoansCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                direction: direction,
                personName: personName,
                personPhone: personPhone,
                startedOn: startedOn,
                dueOn: dueOn,
                returnedOn: returnedOn,
                previousLocationId: previousLocationId,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LoansTable, LoanRow>(table),
                  $$LoansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({bookId = false, previousLocationId = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.bookId,
                            referencedTable: $$LoansTableReferences
                                ._bookIdTable(db),
                            referencedColumn: $$LoansTableReferences
                                ._bookIdTable(db)
                                .id,
                          ) as T;
                        }
                        if (previousLocationId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.previousLocationId,
                            referencedTable: $$LoansTableReferences
                                ._previousLocationIdTable(db),
                            referencedColumn: $$LoansTableReferences
                                ._previousLocationIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$LoansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LoansTable,
      LoanRow,
      $$LoansTableFilterComposer,
      $$LoansTableOrderingComposer,
      $$LoansTableAnnotationComposer,
      $$LoansTableCreateCompanionBuilder,
      $$LoansTableUpdateCompanionBuilder,
      (LoanRow, $$LoansTableReferences),
      LoanRow,
      PrefetchHooks Function({bool bookId, bool previousLocationId})
    >;
typedef $$GoalsTableCreateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required int year,
  required int targetBooks,
  Value<int> rowid,
});
typedef $$GoalsTableUpdateCompanionBuilder = GoalsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<int> year,
  Value<int> targetBooks,
  Value<int> rowid,
});

class $$GoalsTableFilterComposer extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetBooks => $composableBuilder(
    column: $table.targetBooks,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetBooks => $composableBuilder(
    column: $table.targetBooks,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GoalsTable> {
  $$GoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get targetBooks => $composableBuilder(
    column: $table.targetBooks,
    builder: (column) => column,
  );
}

class $$GoalsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GoalsTable,
          GoalRow,
          $$GoalsTableFilterComposer,
          $$GoalsTableOrderingComposer,
          $$GoalsTableAnnotationComposer,
          $$GoalsTableCreateCompanionBuilder,
          $$GoalsTableUpdateCompanionBuilder,
          (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
          GoalRow,
          PrefetchHooks Function()
        > {
  $$GoalsTableTableManager(_$AppDatabase db, $GoalsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<int> year = const Value.absent(),
                Value<int> targetBooks = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                year: year,
                targetBooks: targetBooks,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required int year,
                required int targetBooks,
                Value<int> rowid = const Value.absent(),
              }) => GoalsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                year: year,
                targetBooks: targetBooks,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GoalsTable, GoalRow>(table),
                  BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GoalsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GoalsTable,
      GoalRow,
      $$GoalsTableFilterComposer,
      $$GoalsTableOrderingComposer,
      $$GoalsTableAnnotationComposer,
      $$GoalsTableCreateCompanionBuilder,
      $$GoalsTableUpdateCompanionBuilder,
      (GoalRow, BaseReferences<_$AppDatabase, $GoalsTable, GoalRow>),
      GoalRow,
      PrefetchHooks Function()
    >;
typedef $$TagsTableCreateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required String name,
  Value<int> rowid,
});
typedef $$TagsTableUpdateCompanionBuilder = TagsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String> name,
  Value<int> rowid,
});

final class $$TagsTableReferences
    extends BaseReferences<_$AppDatabase, $TagsTable, TagRow> {
  $$TagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$BookTagsTable, List<BookTagRow>>
  _bookTagsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.bookTags,
    aliasName: 'tags__id__book_tags__tag_id',
  );

  $$BookTagsTableProcessedTableManager get bookTagsRefs {
    final manager = $$BookTagsTableTableManager(
      $_db,
      $_db.bookTags,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_bookTagsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> bookTagsRefs(
    Expression<bool> Function($$BookTagsTableFilterComposer f) f,
  ) {
    final $$BookTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableFilterComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> bookTagsRefs<T extends Object>(
    Expression<T> Function($$BookTagsTableAnnotationComposer a) f,
  ) {
    final $$BookTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.bookTags,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BookTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.bookTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          TagRow,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (TagRow, $$TagsTableReferences),
          TagRow,
          PrefetchHooks Function({bool bookTagsRefs})
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                name: name,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String name,
                Value<int> rowid = const Value.absent(),
              }) => TagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                name: name,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TagsTable, TagRow>(table),
                  $$TagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookTagsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (bookTagsRefs) db.bookTags],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (bookTagsRefs)
                    await $_getPrefetchedDataByColumns<
                      TagRow,
                      $TagsTable,
                      BookTagRow,
                      $BookTagsTable
                    >(
                      currentTable: table,
                      referencedTable: $$TagsTableReferences._bookTagsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$TagsTableReferences(db, table, p0).bookTagsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'tag_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      TagRow,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (TagRow, $$TagsTableReferences),
      TagRow,
      PrefetchHooks Function({bool bookTagsRefs})
    >;
typedef $$BookTagsTableCreateCompanionBuilder = BookTagsCompanion Function({
  Value<String> id,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  required String bookId,
  required String tagId,
  Value<int> rowid,
});
typedef $$BookTagsTableUpdateCompanionBuilder = BookTagsCompanion Function({
  Value<String> id,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<DateTime?> deletedAt,
  Value<int> rev,
  Value<String> bookId,
  Value<String> tagId,
  Value<int> rowid,
});

final class $$BookTagsTableReferences
    extends BaseReferences<_$AppDatabase, $BookTagsTable, BookTagRow> {
  $$BookTagsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('book_tags__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TagsTable _tagIdTable(_$AppDatabase db) =>
      db.tags.createAlias('book_tags__tag_id__tags__id');

  $$TagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<String>('tag_id')!;

    final manager = $$TagsTableTableManager(
      $_db,
      $_db.tags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$BookTagsTableFilterComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableFilterComposer get tagId {
    final $$TagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableFilterComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rev => $composableBuilder(
    column: $table.rev,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableOrderingComposer get tagId {
    final $$TagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableOrderingComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BookTagsTable> {
  $$BookTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<int> get rev =>
      $composableBuilder(column: $table.rev, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TagsTableAnnotationComposer get tagId {
    final $$TagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.tags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TagsTableAnnotationComposer(
            $db: $db,
            $table: $db.tags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$BookTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BookTagsTable,
          BookTagRow,
          $$BookTagsTableFilterComposer,
          $$BookTagsTableOrderingComposer,
          $$BookTagsTableAnnotationComposer,
          $$BookTagsTableCreateCompanionBuilder,
          $$BookTagsTableUpdateCompanionBuilder,
          (BookTagRow, $$BookTagsTableReferences),
          BookTagRow,
          PrefetchHooks Function({bool bookId, bool tagId})
        > {
  $$BookTagsTableTableManager(_$AppDatabase db, $BookTagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BookTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BookTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BookTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                Value<String> bookId = const Value.absent(),
                Value<String> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BookTagsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<int> rev = const Value.absent(),
                required String bookId,
                required String tagId,
                Value<int> rowid = const Value.absent(),
              }) => BookTagsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                rev: rev,
                bookId: bookId,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BookTagsTable, BookTagRow>(table),
                  $$BookTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false, tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$BookTagsTableReferences._bookIdTable(
                          db,
                        ),
                        referencedColumn: $$BookTagsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$BookTagsTableReferences._tagIdTable(
                          db,
                        ),
                        referencedColumn: $$BookTagsTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$BookTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BookTagsTable,
      BookTagRow,
      $$BookTagsTableFilterComposer,
      $$BookTagsTableOrderingComposer,
      $$BookTagsTableAnnotationComposer,
      $$BookTagsTableCreateCompanionBuilder,
      $$BookTagsTableUpdateCompanionBuilder,
      (BookTagRow, $$BookTagsTableReferences),
      BookTagRow,
      PrefetchHooks Function({bool bookId, bool tagId})
    >;
typedef $BooksFtsCreateCompanionBuilder = BooksFtsCompanion Function({
  required String title,
  required String subtitle,
  required String authors,
  Value<int> rowid,
});
typedef $BooksFtsUpdateCompanionBuilder = BooksFtsCompanion Function({
  Value<String> title,
  Value<String> subtitle,
  Value<String> authors,
  Value<int> rowid,
});

class $BooksFtsFilterComposer extends Composer<_$AppDatabase, BooksFts> {
  $BooksFtsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnFilters(column),
  );
}

class $BooksFtsOrderingComposer extends Composer<_$AppDatabase, BooksFts> {
  $BooksFtsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subtitle => $composableBuilder(
    column: $table.subtitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get authors => $composableBuilder(
    column: $table.authors,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BooksFtsAnnotationComposer extends Composer<_$AppDatabase, BooksFts> {
  $BooksFtsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get subtitle =>
      $composableBuilder(column: $table.subtitle, builder: (column) => column);

  GeneratedColumn<String> get authors =>
      $composableBuilder(column: $table.authors, builder: (column) => column);
}

class $BooksFtsTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          BooksFts,
          BooksFt,
          $BooksFtsFilterComposer,
          $BooksFtsOrderingComposer,
          $BooksFtsAnnotationComposer,
          $BooksFtsCreateCompanionBuilder,
          $BooksFtsUpdateCompanionBuilder,
          (BooksFt, BaseReferences<_$AppDatabase, BooksFts, BooksFt>),
          BooksFt,
          PrefetchHooks Function()
        > {
  $BooksFtsTableManager(_$AppDatabase db, BooksFts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BooksFtsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BooksFtsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BooksFtsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> title = const Value.absent(),
                Value<String> subtitle = const Value.absent(),
                Value<String> authors = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BooksFtsCompanion(
                title: title,
                subtitle: subtitle,
                authors: authors,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String title,
                required String subtitle,
                required String authors,
                Value<int> rowid = const Value.absent(),
              }) => BooksFtsCompanion.insert(
                title: title,
                subtitle: subtitle,
                authors: authors,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<BooksFts, BooksFt>(table),
                  BaseReferences<_$AppDatabase, BooksFts, BooksFt>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BooksFtsProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      BooksFts,
      BooksFt,
      $BooksFtsFilterComposer,
      $BooksFtsOrderingComposer,
      $BooksFtsAnnotationComposer,
      $BooksFtsCreateCompanionBuilder,
      $BooksFtsUpdateCompanionBuilder,
      (BooksFt, BaseReferences<_$AppDatabase, BooksFts, BooksFt>),
      BooksFt,
      PrefetchHooks Function()
    >;
typedef $$LookupCacheTableCreateCompanionBuilder =
    LookupCacheCompanion Function({
      required String key,
      required String payloadJson,
      required DateTime fetchedAt,
      Value<bool> isNotFound,
      Value<int> rowid,
    });
typedef $$LookupCacheTableUpdateCompanionBuilder =
    LookupCacheCompanion Function({
      Value<String> key,
      Value<String> payloadJson,
      Value<DateTime> fetchedAt,
      Value<bool> isNotFound,
      Value<int> rowid,
    });

class $$LookupCacheTableFilterComposer
    extends Composer<_$AppDatabase, $LookupCacheTable> {
  $$LookupCacheTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isNotFound => $composableBuilder(
    column: $table.isNotFound,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LookupCacheTableOrderingComposer
    extends Composer<_$AppDatabase, $LookupCacheTable> {
  $$LookupCacheTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fetchedAt => $composableBuilder(
    column: $table.fetchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isNotFound => $composableBuilder(
    column: $table.isNotFound,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LookupCacheTableAnnotationComposer
    extends Composer<_$AppDatabase, $LookupCacheTable> {
  $$LookupCacheTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get payloadJson => $composableBuilder(
    column: $table.payloadJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fetchedAt =>
      $composableBuilder(column: $table.fetchedAt, builder: (column) => column);

  GeneratedColumn<bool> get isNotFound => $composableBuilder(
    column: $table.isNotFound,
    builder: (column) => column,
  );
}

class $$LookupCacheTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $LookupCacheTable,
          LookupCacheRow,
          $$LookupCacheTableFilterComposer,
          $$LookupCacheTableOrderingComposer,
          $$LookupCacheTableAnnotationComposer,
          $$LookupCacheTableCreateCompanionBuilder,
          $$LookupCacheTableUpdateCompanionBuilder,
          (
            LookupCacheRow,
            BaseReferences<_$AppDatabase, $LookupCacheTable, LookupCacheRow>,
          ),
          LookupCacheRow,
          PrefetchHooks Function()
        > {
  $$LookupCacheTableTableManager(_$AppDatabase db, $LookupCacheTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LookupCacheTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LookupCacheTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LookupCacheTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> payloadJson = const Value.absent(),
                Value<DateTime> fetchedAt = const Value.absent(),
                Value<bool> isNotFound = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LookupCacheCompanion(
                key: key,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                isNotFound: isNotFound,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String payloadJson,
                required DateTime fetchedAt,
                Value<bool> isNotFound = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LookupCacheCompanion.insert(
                key: key,
                payloadJson: payloadJson,
                fetchedAt: fetchedAt,
                isNotFound: isNotFound,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$LookupCacheTable, LookupCacheRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $LookupCacheTable,
                    LookupCacheRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LookupCacheTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $LookupCacheTable,
      LookupCacheRow,
      $$LookupCacheTableFilterComposer,
      $$LookupCacheTableOrderingComposer,
      $$LookupCacheTableAnnotationComposer,
      $$LookupCacheTableCreateCompanionBuilder,
      $$LookupCacheTableUpdateCompanionBuilder,
      (
        LookupCacheRow,
        BaseReferences<_$AppDatabase, $LookupCacheTable, LookupCacheRow>,
      ),
      LookupCacheRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaRow,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaRow,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>,
          ),
          AppMetaRow,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaRow>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaRow,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaRow, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaRow>),
      AppMetaRow,
      PrefetchHooks Function()
    >;
typedef $$CoverBlobsTableCreateCompanionBuilder = CoverBlobsCompanion Function({
  required String bookId,
  required Uint8List bytes,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$CoverBlobsTableUpdateCompanionBuilder = CoverBlobsCompanion Function({
  Value<String> bookId,
  Value<Uint8List> bytes,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$CoverBlobsTableReferences
    extends BaseReferences<_$AppDatabase, $CoverBlobsTable, CoverBlobRow> {
  $$CoverBlobsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('cover_blobs__book_id__books__id');

  $$BooksTableProcessedTableManager get bookId {
    final $_column = $_itemColumn<String>('book_id')!;

    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CoverBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $CoverBlobsTable> {
  $$CoverBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoverBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $CoverBlobsTable> {
  $$CoverBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<Uint8List> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoverBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CoverBlobsTable> {
  $$CoverBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<Uint8List> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CoverBlobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CoverBlobsTable,
          CoverBlobRow,
          $$CoverBlobsTableFilterComposer,
          $$CoverBlobsTableOrderingComposer,
          $$CoverBlobsTableAnnotationComposer,
          $$CoverBlobsTableCreateCompanionBuilder,
          $$CoverBlobsTableUpdateCompanionBuilder,
          (CoverBlobRow, $$CoverBlobsTableReferences),
          CoverBlobRow,
          PrefetchHooks Function({bool bookId})
        > {
  $$CoverBlobsTableTableManager(_$AppDatabase db, $CoverBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CoverBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CoverBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CoverBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> bookId = const Value.absent(),
                Value<Uint8List> bytes = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CoverBlobsCompanion(
                bookId: bookId,
                bytes: bytes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String bookId,
                required Uint8List bytes,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => CoverBlobsCompanion.insert(
                bookId: bookId,
                bytes: bytes,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CoverBlobsTable, CoverBlobRow>(table),
                  $$CoverBlobsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({bookId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (bookId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.bookId,
                        referencedTable: $$CoverBlobsTableReferences
                            ._bookIdTable(db),
                        referencedColumn: $$CoverBlobsTableReferences
                            ._bookIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CoverBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CoverBlobsTable,
      CoverBlobRow,
      $$CoverBlobsTableFilterComposer,
      $$CoverBlobsTableOrderingComposer,
      $$CoverBlobsTableAnnotationComposer,
      $$CoverBlobsTableCreateCompanionBuilder,
      $$CoverBlobsTableUpdateCompanionBuilder,
      (CoverBlobRow, $$CoverBlobsTableReferences),
      CoverBlobRow,
      PrefetchHooks Function({bool bookId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LocationsTableTableManager get locations =>
      $$LocationsTableTableManager(_db, _db.locations);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ReadingLogsTableTableManager get readingLogs =>
      $$ReadingLogsTableTableManager(_db, _db.readingLogs);
  $$QuotesTableTableManager get quotes =>
      $$QuotesTableTableManager(_db, _db.quotes);
  $$LoansTableTableManager get loans =>
      $$LoansTableTableManager(_db, _db.loans);
  $$GoalsTableTableManager get goals =>
      $$GoalsTableTableManager(_db, _db.goals);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$BookTagsTableTableManager get bookTags =>
      $$BookTagsTableTableManager(_db, _db.bookTags);
  $BooksFtsTableManager get booksFts =>
      $BooksFtsTableManager(_db, _db.booksFts);
  $$LookupCacheTableTableManager get lookupCache =>
      $$LookupCacheTableTableManager(_db, _db.lookupCache);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
  $$CoverBlobsTableTableManager get coverBlobs =>
      $$CoverBlobsTableTableManager(_db, _db.coverBlobs);
}
