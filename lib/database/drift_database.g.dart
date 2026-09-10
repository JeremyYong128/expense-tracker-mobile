// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'colorHex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#9E9E9E'),
  );
  static const VerificationMeta _iconStringMeta = const VerificationMeta(
    'iconString',
  );
  @override
  late final GeneratedColumn<String> iconString = GeneratedColumn<String>(
    'iconString',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'isActive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isActive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isExpenseMeta = const VerificationMeta(
    'isExpense',
  );
  @override
  late final GeneratedColumn<bool> isExpense = GeneratedColumn<bool>(
    'isExpense',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isExpense" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'isIncome',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isIncome" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorHex,
    iconString,
    isActive,
    isExpense,
    isIncome,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(
    Insertable<CategoryTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('colorHex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['colorHex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('iconString')) {
      context.handle(
        _iconStringMeta,
        iconString.isAcceptableOrUnknown(data['iconString']!, _iconStringMeta),
      );
    }
    if (data.containsKey('isActive')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['isActive']!, _isActiveMeta),
      );
    }
    if (data.containsKey('isExpense')) {
      context.handle(
        _isExpenseMeta,
        isExpense.isAcceptableOrUnknown(data['isExpense']!, _isExpenseMeta),
      );
    }
    if (data.containsKey('isIncome')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['isIncome']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colorHex'],
      )!,
      iconString: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}iconString'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isActive'],
      )!,
      isExpense: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isExpense'],
      )!,
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isIncome'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryTableData extends DataClass
    implements Insertable<CategoryTableData> {
  final int id;
  final String name;
  final String colorHex;
  final String? iconString;
  final bool isActive;
  final bool isExpense;
  final bool isIncome;
  final int sortOrder;
  const CategoryTableData({
    required this.id,
    required this.name,
    required this.colorHex,
    this.iconString,
    required this.isActive,
    required this.isExpense,
    required this.isIncome,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['colorHex'] = Variable<String>(colorHex);
    if (!nullToAbsent || iconString != null) {
      map['iconString'] = Variable<String>(iconString);
    }
    map['isActive'] = Variable<bool>(isActive);
    map['isExpense'] = Variable<bool>(isExpense);
    map['isIncome'] = Variable<bool>(isIncome);
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      name: Value(name),
      colorHex: Value(colorHex),
      iconString: iconString == null && nullToAbsent
          ? const Value.absent()
          : Value(iconString),
      isActive: Value(isActive),
      isExpense: Value(isExpense),
      isIncome: Value(isIncome),
      sortOrder: Value(sortOrder),
    );
  }

  factory CategoryTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      iconString: serializer.fromJson<String?>(json['iconString']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      isExpense: serializer.fromJson<bool>(json['isExpense']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'colorHex': serializer.toJson<String>(colorHex),
      'iconString': serializer.toJson<String?>(iconString),
      'isActive': serializer.toJson<bool>(isActive),
      'isExpense': serializer.toJson<bool>(isExpense),
      'isIncome': serializer.toJson<bool>(isIncome),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CategoryTableData copyWith({
    int? id,
    String? name,
    String? colorHex,
    Value<String?> iconString = const Value.absent(),
    bool? isActive,
    bool? isExpense,
    bool? isIncome,
    int? sortOrder,
  }) => CategoryTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    colorHex: colorHex ?? this.colorHex,
    iconString: iconString.present ? iconString.value : this.iconString,
    isActive: isActive ?? this.isActive,
    isExpense: isExpense ?? this.isExpense,
    isIncome: isIncome ?? this.isIncome,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CategoryTableData copyWithCompanion(CategoriesCompanion data) {
    return CategoryTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      iconString: data.iconString.present
          ? data.iconString.value
          : this.iconString,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      isExpense: data.isExpense.present ? data.isExpense.value : this.isExpense,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconString: $iconString, ')
          ..write('isActive: $isActive, ')
          ..write('isExpense: $isExpense, ')
          ..write('isIncome: $isIncome, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    colorHex,
    iconString,
    isActive,
    isExpense,
    isIncome,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.colorHex == this.colorHex &&
          other.iconString == this.iconString &&
          other.isActive == this.isActive &&
          other.isExpense == this.isExpense &&
          other.isIncome == this.isIncome &&
          other.sortOrder == this.sortOrder);
}

class CategoriesCompanion extends UpdateCompanion<CategoryTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> colorHex;
  final Value<String?> iconString;
  final Value<bool> isActive;
  final Value<bool> isExpense;
  final Value<bool> isIncome;
  final Value<int> sortOrder;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.iconString = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CategoriesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.colorHex = const Value.absent(),
    this.iconString = const Value.absent(),
    this.isActive = const Value.absent(),
    this.isExpense = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name);
  static Insertable<CategoryTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? colorHex,
    Expression<String>? iconString,
    Expression<bool>? isActive,
    Expression<bool>? isExpense,
    Expression<bool>? isIncome,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorHex != null) 'colorHex': colorHex,
      if (iconString != null) 'iconString': iconString,
      if (isActive != null) 'isActive': isActive,
      if (isExpense != null) 'isExpense': isExpense,
      if (isIncome != null) 'isIncome': isIncome,
      if (sortOrder != null) 'sortOrder': sortOrder,
    });
  }

  CategoriesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? colorHex,
    Value<String?>? iconString,
    Value<bool>? isActive,
    Value<bool>? isExpense,
    Value<bool>? isIncome,
    Value<int>? sortOrder,
  }) {
    return CategoriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorHex: colorHex ?? this.colorHex,
      iconString: iconString ?? this.iconString,
      isActive: isActive ?? this.isActive,
      isExpense: isExpense ?? this.isExpense,
      isIncome: isIncome ?? this.isIncome,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorHex.present) {
      map['colorHex'] = Variable<String>(colorHex.value);
    }
    if (iconString.present) {
      map['iconString'] = Variable<String>(iconString.value);
    }
    if (isActive.present) {
      map['isActive'] = Variable<bool>(isActive.value);
    }
    if (isExpense.present) {
      map['isExpense'] = Variable<bool>(isExpense.value);
    }
    if (isIncome.present) {
      map['isIncome'] = Variable<bool>(isIncome.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorHex: $colorHex, ')
          ..write('iconString: $iconString, ')
          ..write('isActive: $isActive, ')
          ..write('isExpense: $isExpense, ')
          ..write('isIncome: $isIncome, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $CardsTable extends Cards with TableInfo<$CardsTable, CardTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
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
  static const VerificationMeta _rewardTypeMeta = const VerificationMeta(
    'rewardType',
  );
  @override
  late final GeneratedColumn<String> rewardType = GeneratedColumn<String>(
    'rewardType',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rewardRateMeta = const VerificationMeta(
    'rewardRate',
  );
  @override
  late final GeneratedColumn<double> rewardRate = GeneratedColumn<double>(
    'rewardRate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorHexMeta = const VerificationMeta(
    'colorHex',
  );
  @override
  late final GeneratedColumn<String> colorHex = GeneratedColumn<String>(
    'colorHex',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('#9E9E9E'),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'isActive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isActive" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    rewardType,
    rewardRate,
    colorHex,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<CardTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('rewardType')) {
      context.handle(
        _rewardTypeMeta,
        rewardType.isAcceptableOrUnknown(data['rewardType']!, _rewardTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardTypeMeta);
    }
    if (data.containsKey('rewardRate')) {
      context.handle(
        _rewardRateMeta,
        rewardRate.isAcceptableOrUnknown(data['rewardRate']!, _rewardRateMeta),
      );
    } else if (isInserting) {
      context.missing(_rewardRateMeta);
    }
    if (data.containsKey('colorHex')) {
      context.handle(
        _colorHexMeta,
        colorHex.isAcceptableOrUnknown(data['colorHex']!, _colorHexMeta),
      );
    }
    if (data.containsKey('isActive')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['isActive']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CardTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CardTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      rewardType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rewardType'],
      )!,
      rewardRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rewardRate'],
      )!,
      colorHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colorHex'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isActive'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $CardsTable createAlias(String alias) {
    return $CardsTable(attachedDatabase, alias);
  }
}

class CardTableData extends DataClass implements Insertable<CardTableData> {
  final int id;
  final String name;
  final String rewardType;
  final double rewardRate;
  final String colorHex;
  final bool isActive;
  final int sortOrder;
  const CardTableData({
    required this.id,
    required this.name,
    required this.rewardType,
    required this.rewardRate,
    required this.colorHex,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['rewardType'] = Variable<String>(rewardType);
    map['rewardRate'] = Variable<double>(rewardRate);
    map['colorHex'] = Variable<String>(colorHex);
    map['isActive'] = Variable<bool>(isActive);
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  CardsCompanion toCompanion(bool nullToAbsent) {
    return CardsCompanion(
      id: Value(id),
      name: Value(name),
      rewardType: Value(rewardType),
      rewardRate: Value(rewardRate),
      colorHex: Value(colorHex),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory CardTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CardTableData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      rewardType: serializer.fromJson<String>(json['rewardType']),
      rewardRate: serializer.fromJson<double>(json['rewardRate']),
      colorHex: serializer.fromJson<String>(json['colorHex']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'rewardType': serializer.toJson<String>(rewardType),
      'rewardRate': serializer.toJson<double>(rewardRate),
      'colorHex': serializer.toJson<String>(colorHex),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  CardTableData copyWith({
    int? id,
    String? name,
    String? rewardType,
    double? rewardRate,
    String? colorHex,
    bool? isActive,
    int? sortOrder,
  }) => CardTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    rewardType: rewardType ?? this.rewardType,
    rewardRate: rewardRate ?? this.rewardRate,
    colorHex: colorHex ?? this.colorHex,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  CardTableData copyWithCompanion(CardsCompanion data) {
    return CardTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      rewardType: data.rewardType.present
          ? data.rewardType.value
          : this.rewardType,
      rewardRate: data.rewardRate.present
          ? data.rewardRate.value
          : this.rewardRate,
      colorHex: data.colorHex.present ? data.colorHex.value : this.colorHex,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CardTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardRate: $rewardRate, ')
          ..write('colorHex: $colorHex, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    rewardType,
    rewardRate,
    colorHex,
    isActive,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CardTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.rewardType == this.rewardType &&
          other.rewardRate == this.rewardRate &&
          other.colorHex == this.colorHex &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class CardsCompanion extends UpdateCompanion<CardTableData> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> rewardType;
  final Value<double> rewardRate;
  final Value<String> colorHex;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  const CardsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.rewardType = const Value.absent(),
    this.rewardRate = const Value.absent(),
    this.colorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  CardsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String rewardType,
    required double rewardRate,
    this.colorHex = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : name = Value(name),
       rewardType = Value(rewardType),
       rewardRate = Value(rewardRate);
  static Insertable<CardTableData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? rewardType,
    Expression<double>? rewardRate,
    Expression<String>? colorHex,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (rewardType != null) 'rewardType': rewardType,
      if (rewardRate != null) 'rewardRate': rewardRate,
      if (colorHex != null) 'colorHex': colorHex,
      if (isActive != null) 'isActive': isActive,
      if (sortOrder != null) 'sortOrder': sortOrder,
    });
  }

  CardsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? rewardType,
    Value<double>? rewardRate,
    Value<String>? colorHex,
    Value<bool>? isActive,
    Value<int>? sortOrder,
  }) {
    return CardsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      rewardType: rewardType ?? this.rewardType,
      rewardRate: rewardRate ?? this.rewardRate,
      colorHex: colorHex ?? this.colorHex,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (rewardType.present) {
      map['rewardType'] = Variable<String>(rewardType.value);
    }
    if (rewardRate.present) {
      map['rewardRate'] = Variable<double>(rewardRate.value);
    }
    if (colorHex.present) {
      map['colorHex'] = Variable<String>(colorHex.value);
    }
    if (isActive.present) {
      map['isActive'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CardsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('rewardType: $rewardType, ')
          ..write('rewardRate: $rewardRate, ')
          ..write('colorHex: $colorHex, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $RecurringTransactionsTable extends RecurringTransactions
    with TableInfo<$RecurringTransactionsTable, RecurringTransactionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringTransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'categoryId',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES categories(id) ON DELETE RESTRICT',
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
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'isIncome',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isIncome" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rewardAmountMeta = const VerificationMeta(
    'rewardAmount',
  );
  @override
  late final GeneratedColumn<double> rewardAmount = GeneratedColumn<double>(
    'reward_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalMeta = const VerificationMeta(
    'interval',
  );
  @override
  late final GeneratedColumn<int> interval = GeneratedColumn<int>(
    'interval',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
    'startDate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nextDueDateMeta = const VerificationMeta(
    'nextDueDate',
  );
  @override
  late final GeneratedColumn<String> nextDueDate = GeneratedColumn<String>(
    'nextDueDate',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'cardId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES cards(id) ON DELETE SET NULL',
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sortOrder',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    title,
    categoryId,
    note,
    isIncome,
    rewardAmount,
    interval,
    period,
    startDate,
    nextDueDate,
    cardId,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecurringTransactionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('categoryId')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['categoryId']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('isIncome')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['isIncome']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('reward_amount')) {
      context.handle(
        _rewardAmountMeta,
        rewardAmount.isAcceptableOrUnknown(
          data['reward_amount']!,
          _rewardAmountMeta,
        ),
      );
    }
    if (data.containsKey('interval')) {
      context.handle(
        _intervalMeta,
        interval.isAcceptableOrUnknown(data['interval']!, _intervalMeta),
      );
    } else if (isInserting) {
      context.missing(_intervalMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    } else if (isInserting) {
      context.missing(_periodMeta);
    }
    if (data.containsKey('startDate')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['startDate']!, _startDateMeta),
      );
    }
    if (data.containsKey('nextDueDate')) {
      context.handle(
        _nextDueDateMeta,
        nextDueDate.isAcceptableOrUnknown(
          data['nextDueDate']!,
          _nextDueDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('cardId')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['cardId']!, _cardIdMeta),
      );
    }
    if (data.containsKey('sortOrder')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sortOrder']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringTransactionTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringTransactionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoryId'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isIncome'],
      )!,
      rewardAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reward_amount'],
      ),
      interval: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}startDate'],
      )!,
      nextDueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nextDueDate'],
      )!,
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardId'],
      ),
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sortOrder'],
      )!,
    );
  }

  @override
  $RecurringTransactionsTable createAlias(String alias) {
    return $RecurringTransactionsTable(attachedDatabase, alias);
  }
}

class RecurringTransactionTableData extends DataClass
    implements Insertable<RecurringTransactionTableData> {
  final int id;
  final double amount;
  final String title;
  final int categoryId;
  final String? note;
  final bool isIncome;
  final double? rewardAmount;
  final int interval;
  final String period;
  final String startDate;
  final String nextDueDate;
  final int? cardId;
  final int sortOrder;
  const RecurringTransactionTableData({
    required this.id,
    required this.amount,
    required this.title,
    required this.categoryId,
    this.note,
    required this.isIncome,
    this.rewardAmount,
    required this.interval,
    required this.period,
    required this.startDate,
    required this.nextDueDate,
    this.cardId,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['title'] = Variable<String>(title);
    map['categoryId'] = Variable<int>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['isIncome'] = Variable<bool>(isIncome);
    if (!nullToAbsent || rewardAmount != null) {
      map['reward_amount'] = Variable<double>(rewardAmount);
    }
    map['interval'] = Variable<int>(interval);
    map['period'] = Variable<String>(period);
    map['startDate'] = Variable<String>(startDate);
    map['nextDueDate'] = Variable<String>(nextDueDate);
    if (!nullToAbsent || cardId != null) {
      map['cardId'] = Variable<int>(cardId);
    }
    map['sortOrder'] = Variable<int>(sortOrder);
    return map;
  }

  RecurringTransactionsCompanion toCompanion(bool nullToAbsent) {
    return RecurringTransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      title: Value(title),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isIncome: Value(isIncome),
      rewardAmount: rewardAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardAmount),
      interval: Value(interval),
      period: Value(period),
      startDate: Value(startDate),
      nextDueDate: Value(nextDueDate),
      cardId: cardId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardId),
      sortOrder: Value(sortOrder),
    );
  }

  factory RecurringTransactionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringTransactionTableData(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      title: serializer.fromJson<String>(json['title']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      rewardAmount: serializer.fromJson<double?>(json['rewardAmount']),
      interval: serializer.fromJson<int>(json['interval']),
      period: serializer.fromJson<String>(json['period']),
      startDate: serializer.fromJson<String>(json['startDate']),
      nextDueDate: serializer.fromJson<String>(json['nextDueDate']),
      cardId: serializer.fromJson<int?>(json['cardId']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'title': serializer.toJson<String>(title),
      'categoryId': serializer.toJson<int>(categoryId),
      'note': serializer.toJson<String?>(note),
      'isIncome': serializer.toJson<bool>(isIncome),
      'rewardAmount': serializer.toJson<double?>(rewardAmount),
      'interval': serializer.toJson<int>(interval),
      'period': serializer.toJson<String>(period),
      'startDate': serializer.toJson<String>(startDate),
      'nextDueDate': serializer.toJson<String>(nextDueDate),
      'cardId': serializer.toJson<int?>(cardId),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  RecurringTransactionTableData copyWith({
    int? id,
    double? amount,
    String? title,
    int? categoryId,
    Value<String?> note = const Value.absent(),
    bool? isIncome,
    Value<double?> rewardAmount = const Value.absent(),
    int? interval,
    String? period,
    String? startDate,
    String? nextDueDate,
    Value<int?> cardId = const Value.absent(),
    int? sortOrder,
  }) => RecurringTransactionTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    title: title ?? this.title,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    isIncome: isIncome ?? this.isIncome,
    rewardAmount: rewardAmount.present ? rewardAmount.value : this.rewardAmount,
    interval: interval ?? this.interval,
    period: period ?? this.period,
    startDate: startDate ?? this.startDate,
    nextDueDate: nextDueDate ?? this.nextDueDate,
    cardId: cardId.present ? cardId.value : this.cardId,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  RecurringTransactionTableData copyWithCompanion(
    RecurringTransactionsCompanion data,
  ) {
    return RecurringTransactionTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      title: data.title.present ? data.title.value : this.title,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      rewardAmount: data.rewardAmount.present
          ? data.rewardAmount.value
          : this.rewardAmount,
      interval: data.interval.present ? data.interval.value : this.interval,
      period: data.period.present ? data.period.value : this.period,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      nextDueDate: data.nextDueDate.present
          ? data.nextDueDate.value
          : this.nextDueDate,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('isIncome: $isIncome, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('interval: $interval, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('cardId: $cardId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    title,
    categoryId,
    note,
    isIncome,
    rewardAmount,
    interval,
    period,
    startDate,
    nextDueDate,
    cardId,
    sortOrder,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringTransactionTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.title == this.title &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.isIncome == this.isIncome &&
          other.rewardAmount == this.rewardAmount &&
          other.interval == this.interval &&
          other.period == this.period &&
          other.startDate == this.startDate &&
          other.nextDueDate == this.nextDueDate &&
          other.cardId == this.cardId &&
          other.sortOrder == this.sortOrder);
}

class RecurringTransactionsCompanion
    extends UpdateCompanion<RecurringTransactionTableData> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> title;
  final Value<int> categoryId;
  final Value<String?> note;
  final Value<bool> isIncome;
  final Value<double?> rewardAmount;
  final Value<int> interval;
  final Value<String> period;
  final Value<String> startDate;
  final Value<String> nextDueDate;
  final Value<int?> cardId;
  final Value<int> sortOrder;
  const RecurringTransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.title = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.interval = const Value.absent(),
    this.period = const Value.absent(),
    this.startDate = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.cardId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  });
  RecurringTransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String title,
    required int categoryId,
    this.note = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    required int interval,
    required String period,
    this.startDate = const Value.absent(),
    required String nextDueDate,
    this.cardId = const Value.absent(),
    this.sortOrder = const Value.absent(),
  }) : amount = Value(amount),
       title = Value(title),
       categoryId = Value(categoryId),
       interval = Value(interval),
       period = Value(period),
       nextDueDate = Value(nextDueDate);
  static Insertable<RecurringTransactionTableData> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? title,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<bool>? isIncome,
    Expression<double>? rewardAmount,
    Expression<int>? interval,
    Expression<String>? period,
    Expression<String>? startDate,
    Expression<String>? nextDueDate,
    Expression<int>? cardId,
    Expression<int>? sortOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (title != null) 'title': title,
      if (categoryId != null) 'categoryId': categoryId,
      if (note != null) 'note': note,
      if (isIncome != null) 'isIncome': isIncome,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (interval != null) 'interval': interval,
      if (period != null) 'period': period,
      if (startDate != null) 'startDate': startDate,
      if (nextDueDate != null) 'nextDueDate': nextDueDate,
      if (cardId != null) 'cardId': cardId,
      if (sortOrder != null) 'sortOrder': sortOrder,
    });
  }

  RecurringTransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<String>? title,
    Value<int>? categoryId,
    Value<String?>? note,
    Value<bool>? isIncome,
    Value<double?>? rewardAmount,
    Value<int>? interval,
    Value<String>? period,
    Value<String>? startDate,
    Value<String>? nextDueDate,
    Value<int?>? cardId,
    Value<int>? sortOrder,
  }) {
    return RecurringTransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      interval: interval ?? this.interval,
      period: period ?? this.period,
      startDate: startDate ?? this.startDate,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      cardId: cardId ?? this.cardId,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (categoryId.present) {
      map['categoryId'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isIncome.present) {
      map['isIncome'] = Variable<bool>(isIncome.value);
    }
    if (rewardAmount.present) {
      map['reward_amount'] = Variable<double>(rewardAmount.value);
    }
    if (interval.present) {
      map['interval'] = Variable<int>(interval.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDate.present) {
      map['startDate'] = Variable<String>(startDate.value);
    }
    if (nextDueDate.present) {
      map['nextDueDate'] = Variable<String>(nextDueDate.value);
    }
    if (cardId.present) {
      map['cardId'] = Variable<int>(cardId.value);
    }
    if (sortOrder.present) {
      map['sortOrder'] = Variable<int>(sortOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringTransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('title: $title, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('isIncome: $isIncome, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('interval: $interval, ')
          ..write('period: $period, ')
          ..write('startDate: $startDate, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('cardId: $cardId, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }
}

class $TransactionsTable extends Transactions
    with TableInfo<$TransactionsTable, TransactionTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TransactionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryIdMeta = const VerificationMeta(
    'categoryId',
  );
  @override
  late final GeneratedColumn<int> categoryId = GeneratedColumn<int>(
    'categoryId',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES categories(id) ON DELETE RESTRICT',
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
  static const VerificationMeta _isIncomeMeta = const VerificationMeta(
    'isIncome',
  );
  @override
  late final GeneratedColumn<bool> isIncome = GeneratedColumn<bool>(
    'isIncome',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("isIncome" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _rewardAmountMeta = const VerificationMeta(
    'rewardAmount',
  );
  @override
  late final GeneratedColumn<double> rewardAmount = GeneratedColumn<double>(
    'reward_amount',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recurringIdMeta = const VerificationMeta(
    'recurringId',
  );
  @override
  late final GeneratedColumn<int> recurringId = GeneratedColumn<int>(
    'recurringId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints:
        'REFERENCES recurring_transactions(id) ON DELETE SET NULL',
  );
  static const VerificationMeta _cardIdMeta = const VerificationMeta('cardId');
  @override
  late final GeneratedColumn<int> cardId = GeneratedColumn<int>(
    'cardId',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES cards(id) ON DELETE SET NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    amount,
    title,
    date,
    categoryId,
    note,
    isIncome,
    rewardAmount,
    recurringId,
    cardId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<TransactionTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('categoryId')) {
      context.handle(
        _categoryIdMeta,
        categoryId.isAcceptableOrUnknown(data['categoryId']!, _categoryIdMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('isIncome')) {
      context.handle(
        _isIncomeMeta,
        isIncome.isAcceptableOrUnknown(data['isIncome']!, _isIncomeMeta),
      );
    }
    if (data.containsKey('reward_amount')) {
      context.handle(
        _rewardAmountMeta,
        rewardAmount.isAcceptableOrUnknown(
          data['reward_amount']!,
          _rewardAmountMeta,
        ),
      );
    }
    if (data.containsKey('recurringId')) {
      context.handle(
        _recurringIdMeta,
        recurringId.isAcceptableOrUnknown(
          data['recurringId']!,
          _recurringIdMeta,
        ),
      );
    }
    if (data.containsKey('cardId')) {
      context.handle(
        _cardIdMeta,
        cardId.isAcceptableOrUnknown(data['cardId']!, _cardIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TransactionTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TransactionTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      categoryId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoryId'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isIncome: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}isIncome'],
      )!,
      rewardAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}reward_amount'],
      ),
      recurringId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}recurringId'],
      ),
      cardId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cardId'],
      ),
    );
  }

  @override
  $TransactionsTable createAlias(String alias) {
    return $TransactionsTable(attachedDatabase, alias);
  }
}

class TransactionTableData extends DataClass
    implements Insertable<TransactionTableData> {
  final int id;
  final double amount;
  final String title;
  final String date;
  final int categoryId;
  final String? note;
  final bool isIncome;
  final double? rewardAmount;
  final int? recurringId;
  final int? cardId;
  const TransactionTableData({
    required this.id,
    required this.amount,
    required this.title,
    required this.date,
    required this.categoryId,
    this.note,
    required this.isIncome,
    this.rewardAmount,
    this.recurringId,
    this.cardId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['amount'] = Variable<double>(amount);
    map['title'] = Variable<String>(title);
    map['date'] = Variable<String>(date);
    map['categoryId'] = Variable<int>(categoryId);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['isIncome'] = Variable<bool>(isIncome);
    if (!nullToAbsent || rewardAmount != null) {
      map['reward_amount'] = Variable<double>(rewardAmount);
    }
    if (!nullToAbsent || recurringId != null) {
      map['recurringId'] = Variable<int>(recurringId);
    }
    if (!nullToAbsent || cardId != null) {
      map['cardId'] = Variable<int>(cardId);
    }
    return map;
  }

  TransactionsCompanion toCompanion(bool nullToAbsent) {
    return TransactionsCompanion(
      id: Value(id),
      amount: Value(amount),
      title: Value(title),
      date: Value(date),
      categoryId: Value(categoryId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isIncome: Value(isIncome),
      rewardAmount: rewardAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(rewardAmount),
      recurringId: recurringId == null && nullToAbsent
          ? const Value.absent()
          : Value(recurringId),
      cardId: cardId == null && nullToAbsent
          ? const Value.absent()
          : Value(cardId),
    );
  }

  factory TransactionTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TransactionTableData(
      id: serializer.fromJson<int>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      title: serializer.fromJson<String>(json['title']),
      date: serializer.fromJson<String>(json['date']),
      categoryId: serializer.fromJson<int>(json['categoryId']),
      note: serializer.fromJson<String?>(json['note']),
      isIncome: serializer.fromJson<bool>(json['isIncome']),
      rewardAmount: serializer.fromJson<double?>(json['rewardAmount']),
      recurringId: serializer.fromJson<int?>(json['recurringId']),
      cardId: serializer.fromJson<int?>(json['cardId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'amount': serializer.toJson<double>(amount),
      'title': serializer.toJson<String>(title),
      'date': serializer.toJson<String>(date),
      'categoryId': serializer.toJson<int>(categoryId),
      'note': serializer.toJson<String?>(note),
      'isIncome': serializer.toJson<bool>(isIncome),
      'rewardAmount': serializer.toJson<double?>(rewardAmount),
      'recurringId': serializer.toJson<int?>(recurringId),
      'cardId': serializer.toJson<int?>(cardId),
    };
  }

  TransactionTableData copyWith({
    int? id,
    double? amount,
    String? title,
    String? date,
    int? categoryId,
    Value<String?> note = const Value.absent(),
    bool? isIncome,
    Value<double?> rewardAmount = const Value.absent(),
    Value<int?> recurringId = const Value.absent(),
    Value<int?> cardId = const Value.absent(),
  }) => TransactionTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    title: title ?? this.title,
    date: date ?? this.date,
    categoryId: categoryId ?? this.categoryId,
    note: note.present ? note.value : this.note,
    isIncome: isIncome ?? this.isIncome,
    rewardAmount: rewardAmount.present ? rewardAmount.value : this.rewardAmount,
    recurringId: recurringId.present ? recurringId.value : this.recurringId,
    cardId: cardId.present ? cardId.value : this.cardId,
  );
  TransactionTableData copyWithCompanion(TransactionsCompanion data) {
    return TransactionTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      title: data.title.present ? data.title.value : this.title,
      date: data.date.present ? data.date.value : this.date,
      categoryId: data.categoryId.present
          ? data.categoryId.value
          : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      isIncome: data.isIncome.present ? data.isIncome.value : this.isIncome,
      rewardAmount: data.rewardAmount.present
          ? data.rewardAmount.value
          : this.rewardAmount,
      recurringId: data.recurringId.present
          ? data.recurringId.value
          : this.recurringId,
      cardId: data.cardId.present ? data.cardId.value : this.cardId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TransactionTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('isIncome: $isIncome, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('recurringId: $recurringId, ')
          ..write('cardId: $cardId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    amount,
    title,
    date,
    categoryId,
    note,
    isIncome,
    rewardAmount,
    recurringId,
    cardId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TransactionTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.title == this.title &&
          other.date == this.date &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.isIncome == this.isIncome &&
          other.rewardAmount == this.rewardAmount &&
          other.recurringId == this.recurringId &&
          other.cardId == this.cardId);
}

class TransactionsCompanion extends UpdateCompanion<TransactionTableData> {
  final Value<int> id;
  final Value<double> amount;
  final Value<String> title;
  final Value<String> date;
  final Value<int> categoryId;
  final Value<String?> note;
  final Value<bool> isIncome;
  final Value<double?> rewardAmount;
  final Value<int?> recurringId;
  final Value<int?> cardId;
  const TransactionsCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.title = const Value.absent(),
    this.date = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.cardId = const Value.absent(),
  });
  TransactionsCompanion.insert({
    this.id = const Value.absent(),
    required double amount,
    required String title,
    required String date,
    required int categoryId,
    this.note = const Value.absent(),
    this.isIncome = const Value.absent(),
    this.rewardAmount = const Value.absent(),
    this.recurringId = const Value.absent(),
    this.cardId = const Value.absent(),
  }) : amount = Value(amount),
       title = Value(title),
       date = Value(date),
       categoryId = Value(categoryId);
  static Insertable<TransactionTableData> custom({
    Expression<int>? id,
    Expression<double>? amount,
    Expression<String>? title,
    Expression<String>? date,
    Expression<int>? categoryId,
    Expression<String>? note,
    Expression<bool>? isIncome,
    Expression<double>? rewardAmount,
    Expression<int>? recurringId,
    Expression<int>? cardId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (title != null) 'title': title,
      if (date != null) 'date': date,
      if (categoryId != null) 'categoryId': categoryId,
      if (note != null) 'note': note,
      if (isIncome != null) 'isIncome': isIncome,
      if (rewardAmount != null) 'reward_amount': rewardAmount,
      if (recurringId != null) 'recurringId': recurringId,
      if (cardId != null) 'cardId': cardId,
    });
  }

  TransactionsCompanion copyWith({
    Value<int>? id,
    Value<double>? amount,
    Value<String>? title,
    Value<String>? date,
    Value<int>? categoryId,
    Value<String?>? note,
    Value<bool>? isIncome,
    Value<double?>? rewardAmount,
    Value<int?>? recurringId,
    Value<int?>? cardId,
  }) {
    return TransactionsCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      title: title ?? this.title,
      date: date ?? this.date,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      isIncome: isIncome ?? this.isIncome,
      rewardAmount: rewardAmount ?? this.rewardAmount,
      recurringId: recurringId ?? this.recurringId,
      cardId: cardId ?? this.cardId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (categoryId.present) {
      map['categoryId'] = Variable<int>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isIncome.present) {
      map['isIncome'] = Variable<bool>(isIncome.value);
    }
    if (rewardAmount.present) {
      map['reward_amount'] = Variable<double>(rewardAmount.value);
    }
    if (recurringId.present) {
      map['recurringId'] = Variable<int>(recurringId.value);
    }
    if (cardId.present) {
      map['cardId'] = Variable<int>(cardId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TransactionsCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('title: $title, ')
          ..write('date: $date, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('isIncome: $isIncome, ')
          ..write('rewardAmount: $rewardAmount, ')
          ..write('recurringId: $recurringId, ')
          ..write('cardId: $cardId')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $CardsTable cards = $CardsTable(this);
  late final $RecurringTransactionsTable recurringTransactions =
      $RecurringTransactionsTable(this);
  late final $TransactionsTable transactions = $TransactionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    categories,
    cards,
    recurringTransactions,
    transactions,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recurring_transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'recurring_transactions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'cards',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('transactions', kind: UpdateKind.update)],
    ),
  ]);
}

typedef $$CategoriesTableCreateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      required String name,
      Value<String> colorHex,
      Value<String?> iconString,
      Value<bool> isActive,
      Value<bool> isExpense,
      Value<bool> isIncome,
      Value<int> sortOrder,
    });
typedef $$CategoriesTableUpdateCompanionBuilder =
    CategoriesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> colorHex,
      Value<String?> iconString,
      Value<bool> isActive,
      Value<bool> isExpense,
      Value<bool> isIncome,
      Value<int> sortOrder,
    });

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryTableData> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransactionTableData>
  >
  _recurringTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: 'categories__id__recurring_transactions__categoryId',
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionTableData>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'categories__id__transactions__categoryId',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.categoryId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconString => $composableBuilder(
    column: $table.iconString,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconString => $composableBuilder(
    column: $table.iconString,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExpense => $composableBuilder(
    column: $table.isExpense,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<String> get iconString => $composableBuilder(
    column: $table.iconString,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<bool> get isExpense =>
      $composableBuilder(column: $table.isExpense, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.categoryId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.categoryId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CategoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriesTable,
          CategoryTableData,
          $$CategoriesTableFilterComposer,
          $$CategoriesTableOrderingComposer,
          $$CategoriesTableAnnotationComposer,
          $$CategoriesTableCreateCompanionBuilder,
          $$CategoriesTableUpdateCompanionBuilder,
          (CategoryTableData, $$CategoriesTableReferences),
          CategoryTableData,
          PrefetchHooks Function({
            bool recurringTransactionsRefs,
            bool transactionsRefs,
          })
        > {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<String?> iconString = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion(
                id: id,
                name: name,
                colorHex: colorHex,
                iconString: iconString,
                isActive: isActive,
                isExpense: isExpense,
                isIncome: isIncome,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String> colorHex = const Value.absent(),
                Value<String?> iconString = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<bool> isExpense = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CategoriesCompanion.insert(
                id: id,
                name: name,
                colorHex: colorHex,
                iconString: iconString,
                isActive: isActive,
                isExpense: isExpense,
                isIncome: isIncome,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CategoriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({recurringTransactionsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          CategoryTableData,
                          $CategoriesTable,
                          RecurringTransactionTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CategoryTableData,
                          $CategoriesTable,
                          TransactionTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CategoriesTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CategoriesTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.categoryId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CategoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriesTable,
      CategoryTableData,
      $$CategoriesTableFilterComposer,
      $$CategoriesTableOrderingComposer,
      $$CategoriesTableAnnotationComposer,
      $$CategoriesTableCreateCompanionBuilder,
      $$CategoriesTableUpdateCompanionBuilder,
      (CategoryTableData, $$CategoriesTableReferences),
      CategoryTableData,
      PrefetchHooks Function({
        bool recurringTransactionsRefs,
        bool transactionsRefs,
      })
    >;
typedef $$CardsTableCreateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      required String name,
      required String rewardType,
      required double rewardRate,
      Value<String> colorHex,
      Value<bool> isActive,
      Value<int> sortOrder,
    });
typedef $$CardsTableUpdateCompanionBuilder =
    CardsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> rewardType,
      Value<double> rewardRate,
      Value<String> colorHex,
      Value<bool> isActive,
      Value<int> sortOrder,
    });

final class $$CardsTableReferences
    extends BaseReferences<_$AppDatabase, $CardsTable, CardTableData> {
  $$CardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $RecurringTransactionsTable,
    List<RecurringTransactionTableData>
  >
  _recurringTransactionsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.recurringTransactions,
        aliasName: 'cards__id__recurring_transactions__cardId',
      );

  $$RecurringTransactionsTableProcessedTableManager
  get recurringTransactionsRefs {
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _recurringTransactionsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionTableData>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'cards__id__transactions__cardId',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.cardId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CardsTableFilterComposer extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rewardRate => $composableBuilder(
    column: $table.rewardRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> recurringTransactionsRefs(
    Expression<bool> Function($$RecurringTransactionsTableFilterComposer f) f,
  ) {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.cardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableOrderingComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rewardRate => $composableBuilder(
    column: $table.rewardRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colorHex => $composableBuilder(
    column: $table.colorHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CardsTable> {
  $$CardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get rewardType => $composableBuilder(
    column: $table.rewardType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get rewardRate => $composableBuilder(
    column: $table.rewardRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get colorHex =>
      $composableBuilder(column: $table.colorHex, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> recurringTransactionsRefs<T extends Object>(
    Expression<T> Function($$RecurringTransactionsTableAnnotationComposer a) f,
  ) {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.cardId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.cardId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CardsTable,
          CardTableData,
          $$CardsTableFilterComposer,
          $$CardsTableOrderingComposer,
          $$CardsTableAnnotationComposer,
          $$CardsTableCreateCompanionBuilder,
          $$CardsTableUpdateCompanionBuilder,
          (CardTableData, $$CardsTableReferences),
          CardTableData,
          PrefetchHooks Function({
            bool recurringTransactionsRefs,
            bool transactionsRefs,
          })
        > {
  $$CardsTableTableManager(_$AppDatabase db, $CardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> rewardType = const Value.absent(),
                Value<double> rewardRate = const Value.absent(),
                Value<String> colorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CardsCompanion(
                id: id,
                name: name,
                rewardType: rewardType,
                rewardRate: rewardRate,
                colorHex: colorHex,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String rewardType,
                required double rewardRate,
                Value<String> colorHex = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => CardsCompanion.insert(
                id: id,
                name: name,
                rewardType: rewardType,
                rewardRate: rewardRate,
                colorHex: colorHex,
                isActive: isActive,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$CardsTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({recurringTransactionsRefs = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (recurringTransactionsRefs) db.recurringTransactions,
                    if (transactionsRefs) db.transactions,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (recurringTransactionsRefs)
                        await $_getPrefetchedData<
                          CardTableData,
                          $CardsTable,
                          RecurringTransactionTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._recurringTransactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).recurringTransactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          CardTableData,
                          $CardsTable,
                          TransactionTableData
                        >(
                          currentTable: table,
                          referencedTable: $$CardsTableReferences
                              ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CardsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.cardId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CardsTable,
      CardTableData,
      $$CardsTableFilterComposer,
      $$CardsTableOrderingComposer,
      $$CardsTableAnnotationComposer,
      $$CardsTableCreateCompanionBuilder,
      $$CardsTableUpdateCompanionBuilder,
      (CardTableData, $$CardsTableReferences),
      CardTableData,
      PrefetchHooks Function({
        bool recurringTransactionsRefs,
        bool transactionsRefs,
      })
    >;
typedef $$RecurringTransactionsTableCreateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required String title,
      required int categoryId,
      Value<String?> note,
      Value<bool> isIncome,
      Value<double?> rewardAmount,
      required int interval,
      required String period,
      Value<String> startDate,
      required String nextDueDate,
      Value<int?> cardId,
      Value<int> sortOrder,
    });
typedef $$RecurringTransactionsTableUpdateCompanionBuilder =
    RecurringTransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<String> title,
      Value<int> categoryId,
      Value<String?> note,
      Value<bool> isIncome,
      Value<double?> rewardAmount,
      Value<int> interval,
      Value<String> period,
      Value<String> startDate,
      Value<String> nextDueDate,
      Value<int?> cardId,
      Value<int> sortOrder,
    });

final class $$RecurringTransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransactionTableData
        > {
  $$RecurringTransactionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) => db.categories
      .createAlias('recurring_transactions__categoryId__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('categoryId')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('recurring_transactions__cardId__cards__id');

  $$CardsTableProcessedTableManager? get cardId {
    final $_column = $_itemColumn<int>('cardId');
    if ($_column == null) return null;
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TransactionsTable, List<TransactionTableData>>
  _transactionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.transactions,
    aliasName: 'recurring_transactions__id__transactions__recurringId',
  );

  $$TransactionsTableProcessedTableManager get transactionsRefs {
    final manager = $$TransactionsTableTableManager(
      $_db,
      $_db.transactions,
    ).filter((f) => f.recurringId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_transactionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$RecurringTransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> transactionsRefs(
    Expression<bool> Function($$TransactionsTableFilterComposer f) f,
  ) {
    final $$TransactionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableFilterComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get interval => $composableBuilder(
    column: $table.interval,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecurringTransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringTransactionsTable> {
  $$RecurringTransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get interval =>
      $composableBuilder(column: $table.interval, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<String> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);

  GeneratedColumn<String> get nextDueDate => $composableBuilder(
    column: $table.nextDueDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> transactionsRefs<T extends Object>(
    Expression<T> Function($$TransactionsTableAnnotationComposer a) f,
  ) {
    final $$TransactionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.transactions,
      getReferencedColumn: (t) => t.recurringId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TransactionsTableAnnotationComposer(
            $db: $db,
            $table: $db.transactions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$RecurringTransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecurringTransactionsTable,
          RecurringTransactionTableData,
          $$RecurringTransactionsTableFilterComposer,
          $$RecurringTransactionsTableOrderingComposer,
          $$RecurringTransactionsTableAnnotationComposer,
          $$RecurringTransactionsTableCreateCompanionBuilder,
          $$RecurringTransactionsTableUpdateCompanionBuilder,
          (
            RecurringTransactionTableData,
            $$RecurringTransactionsTableReferences,
          ),
          RecurringTransactionTableData,
          PrefetchHooks Function({
            bool categoryId,
            bool cardId,
            bool transactionsRefs,
          })
        > {
  $$RecurringTransactionsTableTableManager(
    _$AppDatabase db,
    $RecurringTransactionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringTransactionsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$RecurringTransactionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$RecurringTransactionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<double?> rewardAmount = const Value.absent(),
                Value<int> interval = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<String> startDate = const Value.absent(),
                Value<String> nextDueDate = const Value.absent(),
                Value<int?> cardId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RecurringTransactionsCompanion(
                id: id,
                amount: amount,
                title: title,
                categoryId: categoryId,
                note: note,
                isIncome: isIncome,
                rewardAmount: rewardAmount,
                interval: interval,
                period: period,
                startDate: startDate,
                nextDueDate: nextDueDate,
                cardId: cardId,
                sortOrder: sortOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required String title,
                required int categoryId,
                Value<String?> note = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<double?> rewardAmount = const Value.absent(),
                required int interval,
                required String period,
                Value<String> startDate = const Value.absent(),
                required String nextDueDate,
                Value<int?> cardId = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
              }) => RecurringTransactionsCompanion.insert(
                id: id,
                amount: amount,
                title: title,
                categoryId: categoryId,
                note: note,
                isIncome: isIncome,
                rewardAmount: rewardAmount,
                interval: interval,
                period: period,
                startDate: startDate,
                nextDueDate: nextDueDate,
                cardId: cardId,
                sortOrder: sortOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RecurringTransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, cardId = false, transactionsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (transactionsRefs) db.transactions,
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (cardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cardId,
                                    referencedTable:
                                        $$RecurringTransactionsTableReferences
                                            ._cardIdTable(db),
                                    referencedColumn:
                                        $$RecurringTransactionsTableReferences
                                            ._cardIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (transactionsRefs)
                        await $_getPrefetchedData<
                          RecurringTransactionTableData,
                          $RecurringTransactionsTable,
                          TransactionTableData
                        >(
                          currentTable: table,
                          referencedTable:
                              $$RecurringTransactionsTableReferences
                                  ._transactionsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$RecurringTransactionsTableReferences(
                                db,
                                table,
                                p0,
                              ).transactionsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.recurringId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$RecurringTransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecurringTransactionsTable,
      RecurringTransactionTableData,
      $$RecurringTransactionsTableFilterComposer,
      $$RecurringTransactionsTableOrderingComposer,
      $$RecurringTransactionsTableAnnotationComposer,
      $$RecurringTransactionsTableCreateCompanionBuilder,
      $$RecurringTransactionsTableUpdateCompanionBuilder,
      (RecurringTransactionTableData, $$RecurringTransactionsTableReferences),
      RecurringTransactionTableData,
      PrefetchHooks Function({
        bool categoryId,
        bool cardId,
        bool transactionsRefs,
      })
    >;
typedef $$TransactionsTableCreateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      required double amount,
      required String title,
      required String date,
      required int categoryId,
      Value<String?> note,
      Value<bool> isIncome,
      Value<double?> rewardAmount,
      Value<int?> recurringId,
      Value<int?> cardId,
    });
typedef $$TransactionsTableUpdateCompanionBuilder =
    TransactionsCompanion Function({
      Value<int> id,
      Value<double> amount,
      Value<String> title,
      Value<String> date,
      Value<int> categoryId,
      Value<String?> note,
      Value<bool> isIncome,
      Value<double?> rewardAmount,
      Value<int?> recurringId,
      Value<int?> cardId,
    });

final class $$TransactionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TransactionsTable,
          TransactionTableData
        > {
  $$TransactionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias('transactions__categoryId__categories__id');

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<int>('categoryId')!;

    final manager = $$CategoriesTableTableManager(
      $_db,
      $_db.categories,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $RecurringTransactionsTable _recurringIdTable(_$AppDatabase db) => db
      .recurringTransactions
      .createAlias('transactions__recurringId__recurring_transactions__id');

  $$RecurringTransactionsTableProcessedTableManager? get recurringId {
    final $_column = $_itemColumn<int>('recurringId');
    if ($_column == null) return null;
    final manager = $$RecurringTransactionsTableTableManager(
      $_db,
      $_db.recurringTransactions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_recurringIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CardsTable _cardIdTable(_$AppDatabase db) =>
      db.cards.createAlias('transactions__cardId__cards__id');

  $$CardsTableProcessedTableManager? get cardId {
    final $_column = $_itemColumn<int>('cardId');
    if ($_column == null) return null;
    final manager = $$CardsTableTableManager(
      $_db,
      $_db.cards,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_cardIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TransactionsTableFilterComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnFilters(column),
  );

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableFilterComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableFilterComposer get recurringId {
    final $$RecurringTransactionsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableFilterComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardsTableFilterComposer get cardId {
    final $$CardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableFilterComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableOrderingComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIncome => $composableBuilder(
    column: $table.isIncome,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => ColumnOrderings(column),
  );

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableOrderingComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableOrderingComposer get recurringId {
    final $$RecurringTransactionsTableOrderingComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableOrderingComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardsTableOrderingComposer get cardId {
    final $$CardsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableOrderingComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TransactionsTable> {
  $$TransactionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isIncome =>
      $composableBuilder(column: $table.isIncome, builder: (column) => column);

  GeneratedColumn<double> get rewardAmount => $composableBuilder(
    column: $table.rewardAmount,
    builder: (column) => column,
  );

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.categoryId,
      referencedTable: $db.categories,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CategoriesTableAnnotationComposer(
            $db: $db,
            $table: $db.categories,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$RecurringTransactionsTableAnnotationComposer get recurringId {
    final $$RecurringTransactionsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.recurringId,
          referencedTable: $db.recurringTransactions,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$RecurringTransactionsTableAnnotationComposer(
                $db: $db,
                $table: $db.recurringTransactions,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }

  $$CardsTableAnnotationComposer get cardId {
    final $$CardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.cardId,
      referencedTable: $db.cards,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CardsTableAnnotationComposer(
            $db: $db,
            $table: $db.cards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TransactionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TransactionsTable,
          TransactionTableData,
          $$TransactionsTableFilterComposer,
          $$TransactionsTableOrderingComposer,
          $$TransactionsTableAnnotationComposer,
          $$TransactionsTableCreateCompanionBuilder,
          $$TransactionsTableUpdateCompanionBuilder,
          (TransactionTableData, $$TransactionsTableReferences),
          TransactionTableData,
          PrefetchHooks Function({
            bool categoryId,
            bool recurringId,
            bool cardId,
          })
        > {
  $$TransactionsTableTableManager(_$AppDatabase db, $TransactionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TransactionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TransactionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TransactionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> categoryId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<double?> rewardAmount = const Value.absent(),
                Value<int?> recurringId = const Value.absent(),
                Value<int?> cardId = const Value.absent(),
              }) => TransactionsCompanion(
                id: id,
                amount: amount,
                title: title,
                date: date,
                categoryId: categoryId,
                note: note,
                isIncome: isIncome,
                rewardAmount: rewardAmount,
                recurringId: recurringId,
                cardId: cardId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required double amount,
                required String title,
                required String date,
                required int categoryId,
                Value<String?> note = const Value.absent(),
                Value<bool> isIncome = const Value.absent(),
                Value<double?> rewardAmount = const Value.absent(),
                Value<int?> recurringId = const Value.absent(),
                Value<int?> cardId = const Value.absent(),
              }) => TransactionsCompanion.insert(
                id: id,
                amount: amount,
                title: title,
                date: date,
                categoryId: categoryId,
                note: note,
                isIncome: isIncome,
                rewardAmount: rewardAmount,
                recurringId: recurringId,
                cardId: cardId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TransactionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({categoryId = false, recurringId = false, cardId = false}) {
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
                        if (categoryId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.categoryId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._categoryIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (recurringId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.recurringId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._recurringIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._recurringIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (cardId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.cardId,
                                    referencedTable:
                                        $$TransactionsTableReferences
                                            ._cardIdTable(db),
                                    referencedColumn:
                                        $$TransactionsTableReferences
                                            ._cardIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$TransactionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TransactionsTable,
      TransactionTableData,
      $$TransactionsTableFilterComposer,
      $$TransactionsTableOrderingComposer,
      $$TransactionsTableAnnotationComposer,
      $$TransactionsTableCreateCompanionBuilder,
      $$TransactionsTableUpdateCompanionBuilder,
      (TransactionTableData, $$TransactionsTableReferences),
      TransactionTableData,
      PrefetchHooks Function({bool categoryId, bool recurringId, bool cardId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$CardsTableTableManager get cards =>
      $$CardsTableTableManager(_db, _db.cards);
  $$RecurringTransactionsTableTableManager get recurringTransactions =>
      $$RecurringTransactionsTableTableManager(_db, _db.recurringTransactions);
  $$TransactionsTableTableManager get transactions =>
      $$TransactionsTableTableManager(_db, _db.transactions);
}
