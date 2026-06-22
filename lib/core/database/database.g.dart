// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $AcneSpotsTable extends AcneSpots
    with TableInfo<$AcneSpotsTable, AcneSpot> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcneSpotsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _faceRegionMeta = const VerificationMeta(
    'faceRegion',
  );
  @override
  late final GeneratedColumn<String> faceRegion = GeneratedColumn<String>(
    'face_region',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    faceRegion,
    createdAt,
    note,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'acne_spots';
  @override
  VerificationContext validateIntegrity(
    Insertable<AcneSpot> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('face_region')) {
      context.handle(
        _faceRegionMeta,
        faceRegion.isAcceptableOrUnknown(data['face_region']!, _faceRegionMeta),
      );
    } else if (isInserting) {
      context.missing(_faceRegionMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AcneSpot map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AcneSpot(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      faceRegion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}face_region'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  $AcneSpotsTable createAlias(String alias) {
    return $AcneSpotsTable(attachedDatabase, alias);
  }
}

class AcneSpot extends DataClass implements Insertable<AcneSpot> {
  final String id;
  final String title;
  final String faceRegion;
  final DateTime createdAt;
  final String note;
  final String status;
  const AcneSpot({
    required this.id,
    required this.title,
    required this.faceRegion,
    required this.createdAt,
    required this.note,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['face_region'] = Variable<String>(faceRegion);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['note'] = Variable<String>(note);
    map['status'] = Variable<String>(status);
    return map;
  }

  AcneSpotsCompanion toCompanion(bool nullToAbsent) {
    return AcneSpotsCompanion(
      id: Value(id),
      title: Value(title),
      faceRegion: Value(faceRegion),
      createdAt: Value(createdAt),
      note: Value(note),
      status: Value(status),
    );
  }

  factory AcneSpot.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AcneSpot(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      faceRegion: serializer.fromJson<String>(json['faceRegion']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      note: serializer.fromJson<String>(json['note']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'faceRegion': serializer.toJson<String>(faceRegion),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'note': serializer.toJson<String>(note),
      'status': serializer.toJson<String>(status),
    };
  }

  AcneSpot copyWith({
    String? id,
    String? title,
    String? faceRegion,
    DateTime? createdAt,
    String? note,
    String? status,
  }) => AcneSpot(
    id: id ?? this.id,
    title: title ?? this.title,
    faceRegion: faceRegion ?? this.faceRegion,
    createdAt: createdAt ?? this.createdAt,
    note: note ?? this.note,
    status: status ?? this.status,
  );
  AcneSpot copyWithCompanion(AcneSpotsCompanion data) {
    return AcneSpot(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      faceRegion: data.faceRegion.present
          ? data.faceRegion.value
          : this.faceRegion,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AcneSpot(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('faceRegion: $faceRegion, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, faceRegion, createdAt, note, status);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AcneSpot &&
          other.id == this.id &&
          other.title == this.title &&
          other.faceRegion == this.faceRegion &&
          other.createdAt == this.createdAt &&
          other.note == this.note &&
          other.status == this.status);
}

class AcneSpotsCompanion extends UpdateCompanion<AcneSpot> {
  final Value<String> id;
  final Value<String> title;
  final Value<String> faceRegion;
  final Value<DateTime> createdAt;
  final Value<String> note;
  final Value<String> status;
  final Value<int> rowid;
  const AcneSpotsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.faceRegion = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AcneSpotsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String faceRegion,
    required DateTime createdAt,
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       faceRegion = Value(faceRegion),
       createdAt = Value(createdAt);
  static Insertable<AcneSpot> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? faceRegion,
    Expression<DateTime>? createdAt,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (faceRegion != null) 'face_region': faceRegion,
      if (createdAt != null) 'created_at': createdAt,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AcneSpotsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<String>? faceRegion,
    Value<DateTime>? createdAt,
    Value<String>? note,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return AcneSpotsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      faceRegion: faceRegion ?? this.faceRegion,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (faceRegion.present) {
      map['face_region'] = Variable<String>(faceRegion.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcneSpotsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('faceRegion: $faceRegion, ')
          ..write('createdAt: $createdAt, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CheckInRecordsTable extends CheckInRecords
    with TableInfo<$CheckInRecordsTable, CheckInRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckInRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _spotIdMeta = const VerificationMeta('spotId');
  @override
  late final GeneratedColumn<String> spotId = GeneratedColumn<String>(
    'spot_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES acne_spots (id)',
    ),
  );
  static const VerificationMeta _checkInDateMeta = const VerificationMeta(
    'checkInDate',
  );
  @override
  late final GeneratedColumn<DateTime> checkInDate = GeneratedColumn<DateTime>(
    'check_in_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _phaseMeta = const VerificationMeta('phase');
  @override
  late final GeneratedColumn<String> phase = GeneratedColumn<String>(
    'phase',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, spotId, checkInDate, note, phase];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'check_in_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckInRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('spot_id')) {
      context.handle(
        _spotIdMeta,
        spotId.isAcceptableOrUnknown(data['spot_id']!, _spotIdMeta),
      );
    } else if (isInserting) {
      context.missing(_spotIdMeta);
    }
    if (data.containsKey('check_in_date')) {
      context.handle(
        _checkInDateMeta,
        checkInDate.isAcceptableOrUnknown(
          data['check_in_date']!,
          _checkInDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_checkInDateMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('phase')) {
      context.handle(
        _phaseMeta,
        phase.isAcceptableOrUnknown(data['phase']!, _phaseMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CheckInRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckInRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      spotId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}spot_id'],
      )!,
      checkInDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}check_in_date'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      )!,
      phase: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phase'],
      )!,
    );
  }

  @override
  $CheckInRecordsTable createAlias(String alias) {
    return $CheckInRecordsTable(attachedDatabase, alias);
  }
}

class CheckInRecord extends DataClass implements Insertable<CheckInRecord> {
  final String id;
  final String spotId;
  final DateTime checkInDate;
  final String note;
  final String phase;
  const CheckInRecord({
    required this.id,
    required this.spotId,
    required this.checkInDate,
    required this.note,
    required this.phase,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['spot_id'] = Variable<String>(spotId);
    map['check_in_date'] = Variable<DateTime>(checkInDate);
    map['note'] = Variable<String>(note);
    map['phase'] = Variable<String>(phase);
    return map;
  }

  CheckInRecordsCompanion toCompanion(bool nullToAbsent) {
    return CheckInRecordsCompanion(
      id: Value(id),
      spotId: Value(spotId),
      checkInDate: Value(checkInDate),
      note: Value(note),
      phase: Value(phase),
    );
  }

  factory CheckInRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckInRecord(
      id: serializer.fromJson<String>(json['id']),
      spotId: serializer.fromJson<String>(json['spotId']),
      checkInDate: serializer.fromJson<DateTime>(json['checkInDate']),
      note: serializer.fromJson<String>(json['note']),
      phase: serializer.fromJson<String>(json['phase']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'spotId': serializer.toJson<String>(spotId),
      'checkInDate': serializer.toJson<DateTime>(checkInDate),
      'note': serializer.toJson<String>(note),
      'phase': serializer.toJson<String>(phase),
    };
  }

  CheckInRecord copyWith({
    String? id,
    String? spotId,
    DateTime? checkInDate,
    String? note,
    String? phase,
  }) => CheckInRecord(
    id: id ?? this.id,
    spotId: spotId ?? this.spotId,
    checkInDate: checkInDate ?? this.checkInDate,
    note: note ?? this.note,
    phase: phase ?? this.phase,
  );
  CheckInRecord copyWithCompanion(CheckInRecordsCompanion data) {
    return CheckInRecord(
      id: data.id.present ? data.id.value : this.id,
      spotId: data.spotId.present ? data.spotId.value : this.spotId,
      checkInDate: data.checkInDate.present
          ? data.checkInDate.value
          : this.checkInDate,
      note: data.note.present ? data.note.value : this.note,
      phase: data.phase.present ? data.phase.value : this.phase,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRecord(')
          ..write('id: $id, ')
          ..write('spotId: $spotId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('note: $note, ')
          ..write('phase: $phase')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, spotId, checkInDate, note, phase);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckInRecord &&
          other.id == this.id &&
          other.spotId == this.spotId &&
          other.checkInDate == this.checkInDate &&
          other.note == this.note &&
          other.phase == this.phase);
}

class CheckInRecordsCompanion extends UpdateCompanion<CheckInRecord> {
  final Value<String> id;
  final Value<String> spotId;
  final Value<DateTime> checkInDate;
  final Value<String> note;
  final Value<String> phase;
  final Value<int> rowid;
  const CheckInRecordsCompanion({
    this.id = const Value.absent(),
    this.spotId = const Value.absent(),
    this.checkInDate = const Value.absent(),
    this.note = const Value.absent(),
    this.phase = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckInRecordsCompanion.insert({
    required String id,
    required String spotId,
    required DateTime checkInDate,
    this.note = const Value.absent(),
    this.phase = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       spotId = Value(spotId),
       checkInDate = Value(checkInDate);
  static Insertable<CheckInRecord> custom({
    Expression<String>? id,
    Expression<String>? spotId,
    Expression<DateTime>? checkInDate,
    Expression<String>? note,
    Expression<String>? phase,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (spotId != null) 'spot_id': spotId,
      if (checkInDate != null) 'check_in_date': checkInDate,
      if (note != null) 'note': note,
      if (phase != null) 'phase': phase,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckInRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? spotId,
    Value<DateTime>? checkInDate,
    Value<String>? note,
    Value<String>? phase,
    Value<int>? rowid,
  }) {
    return CheckInRecordsCompanion(
      id: id ?? this.id,
      spotId: spotId ?? this.spotId,
      checkInDate: checkInDate ?? this.checkInDate,
      note: note ?? this.note,
      phase: phase ?? this.phase,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (spotId.present) {
      map['spot_id'] = Variable<String>(spotId.value);
    }
    if (checkInDate.present) {
      map['check_in_date'] = Variable<DateTime>(checkInDate.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (phase.present) {
      map['phase'] = Variable<String>(phase.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckInRecordsCompanion(')
          ..write('id: $id, ')
          ..write('spotId: $spotId, ')
          ..write('checkInDate: $checkInDate, ')
          ..write('note: $note, ')
          ..write('phase: $phase, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TreatmentItemsTable extends TreatmentItems
    with TableInfo<$TreatmentItemsTable, TreatmentItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TreatmentItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInIdMeta = const VerificationMeta(
    'checkInId',
  );
  @override
  late final GeneratedColumn<String> checkInId = GeneratedColumn<String>(
    'check_in_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES check_in_records (id)',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
    'dosage',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [id, checkInId, type, name, dosage];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'treatment_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<TreatmentItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('check_in_id')) {
      context.handle(
        _checkInIdMeta,
        checkInId.isAcceptableOrUnknown(data['check_in_id']!, _checkInIdMeta),
      );
    } else if (isInserting) {
      context.missing(_checkInIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(
        _dosageMeta,
        dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TreatmentItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TreatmentItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      checkInId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      dosage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dosage'],
      )!,
    );
  }

  @override
  $TreatmentItemsTable createAlias(String alias) {
    return $TreatmentItemsTable(attachedDatabase, alias);
  }
}

class TreatmentItem extends DataClass implements Insertable<TreatmentItem> {
  final String id;
  final String checkInId;
  final String type;
  final String name;
  final String dosage;
  const TreatmentItem({
    required this.id,
    required this.checkInId,
    required this.type,
    required this.name,
    required this.dosage,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['check_in_id'] = Variable<String>(checkInId);
    map['type'] = Variable<String>(type);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    return map;
  }

  TreatmentItemsCompanion toCompanion(bool nullToAbsent) {
    return TreatmentItemsCompanion(
      id: Value(id),
      checkInId: Value(checkInId),
      type: Value(type),
      name: Value(name),
      dosage: Value(dosage),
    );
  }

  factory TreatmentItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TreatmentItem(
      id: serializer.fromJson<String>(json['id']),
      checkInId: serializer.fromJson<String>(json['checkInId']),
      type: serializer.fromJson<String>(json['type']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'checkInId': serializer.toJson<String>(checkInId),
      'type': serializer.toJson<String>(type),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
    };
  }

  TreatmentItem copyWith({
    String? id,
    String? checkInId,
    String? type,
    String? name,
    String? dosage,
  }) => TreatmentItem(
    id: id ?? this.id,
    checkInId: checkInId ?? this.checkInId,
    type: type ?? this.type,
    name: name ?? this.name,
    dosage: dosage ?? this.dosage,
  );
  TreatmentItem copyWithCompanion(TreatmentItemsCompanion data) {
    return TreatmentItem(
      id: data.id.present ? data.id.value : this.id,
      checkInId: data.checkInId.present ? data.checkInId.value : this.checkInId,
      type: data.type.present ? data.type.value : this.type,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentItem(')
          ..write('id: $id, ')
          ..write('checkInId: $checkInId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, checkInId, type, name, dosage);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TreatmentItem &&
          other.id == this.id &&
          other.checkInId == this.checkInId &&
          other.type == this.type &&
          other.name == this.name &&
          other.dosage == this.dosage);
}

class TreatmentItemsCompanion extends UpdateCompanion<TreatmentItem> {
  final Value<String> id;
  final Value<String> checkInId;
  final Value<String> type;
  final Value<String> name;
  final Value<String> dosage;
  final Value<int> rowid;
  const TreatmentItemsCompanion({
    this.id = const Value.absent(),
    this.checkInId = const Value.absent(),
    this.type = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TreatmentItemsCompanion.insert({
    required String id,
    required String checkInId,
    required String type,
    required String name,
    this.dosage = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       checkInId = Value(checkInId),
       type = Value(type),
       name = Value(name);
  static Insertable<TreatmentItem> custom({
    Expression<String>? id,
    Expression<String>? checkInId,
    Expression<String>? type,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkInId != null) 'check_in_id': checkInId,
      if (type != null) 'type': type,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TreatmentItemsCompanion copyWith({
    Value<String>? id,
    Value<String>? checkInId,
    Value<String>? type,
    Value<String>? name,
    Value<String>? dosage,
    Value<int>? rowid,
  }) {
    return TreatmentItemsCompanion(
      id: id ?? this.id,
      checkInId: checkInId ?? this.checkInId,
      type: type ?? this.type,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (checkInId.present) {
      map['check_in_id'] = Variable<String>(checkInId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TreatmentItemsCompanion(')
          ..write('id: $id, ')
          ..write('checkInId: $checkInId, ')
          ..write('type: $type, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, Photo> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _checkInIdMeta = const VerificationMeta(
    'checkInId',
  );
  @override
  late final GeneratedColumn<String> checkInId = GeneratedColumn<String>(
    'check_in_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES check_in_records (id)',
    ),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _capturedAtMeta = const VerificationMeta(
    'capturedAt',
  );
  @override
  late final GeneratedColumn<DateTime> capturedAt = GeneratedColumn<DateTime>(
    'captured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('builtin'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    checkInId,
    filePath,
    capturedAt,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Photo> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('check_in_id')) {
      context.handle(
        _checkInIdMeta,
        checkInId.isAcceptableOrUnknown(data['check_in_id']!, _checkInIdMeta),
      );
    } else if (isInserting) {
      context.missing(_checkInIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('captured_at')) {
      context.handle(
        _capturedAtMeta,
        capturedAt.isAcceptableOrUnknown(data['captured_at']!, _capturedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_capturedAtMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Photo map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Photo(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      checkInId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}check_in_id'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      capturedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}captured_at'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }
}

class Photo extends DataClass implements Insertable<Photo> {
  final String id;
  final String checkInId;
  final String filePath;
  final DateTime capturedAt;
  final String source;
  const Photo({
    required this.id,
    required this.checkInId,
    required this.filePath,
    required this.capturedAt,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['check_in_id'] = Variable<String>(checkInId);
    map['file_path'] = Variable<String>(filePath);
    map['captured_at'] = Variable<DateTime>(capturedAt);
    map['source'] = Variable<String>(source);
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      id: Value(id),
      checkInId: Value(checkInId),
      filePath: Value(filePath),
      capturedAt: Value(capturedAt),
      source: Value(source),
    );
  }

  factory Photo.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Photo(
      id: serializer.fromJson<String>(json['id']),
      checkInId: serializer.fromJson<String>(json['checkInId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      capturedAt: serializer.fromJson<DateTime>(json['capturedAt']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'checkInId': serializer.toJson<String>(checkInId),
      'filePath': serializer.toJson<String>(filePath),
      'capturedAt': serializer.toJson<DateTime>(capturedAt),
      'source': serializer.toJson<String>(source),
    };
  }

  Photo copyWith({
    String? id,
    String? checkInId,
    String? filePath,
    DateTime? capturedAt,
    String? source,
  }) => Photo(
    id: id ?? this.id,
    checkInId: checkInId ?? this.checkInId,
    filePath: filePath ?? this.filePath,
    capturedAt: capturedAt ?? this.capturedAt,
    source: source ?? this.source,
  );
  Photo copyWithCompanion(PhotosCompanion data) {
    return Photo(
      id: data.id.present ? data.id.value : this.id,
      checkInId: data.checkInId.present ? data.checkInId.value : this.checkInId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      capturedAt: data.capturedAt.present
          ? data.capturedAt.value
          : this.capturedAt,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Photo(')
          ..write('id: $id, ')
          ..write('checkInId: $checkInId, ')
          ..write('filePath: $filePath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, checkInId, filePath, capturedAt, source);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Photo &&
          other.id == this.id &&
          other.checkInId == this.checkInId &&
          other.filePath == this.filePath &&
          other.capturedAt == this.capturedAt &&
          other.source == this.source);
}

class PhotosCompanion extends UpdateCompanion<Photo> {
  final Value<String> id;
  final Value<String> checkInId;
  final Value<String> filePath;
  final Value<DateTime> capturedAt;
  final Value<String> source;
  final Value<int> rowid;
  const PhotosCompanion({
    this.id = const Value.absent(),
    this.checkInId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.capturedAt = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    required String id,
    required String checkInId,
    required String filePath,
    required DateTime capturedAt,
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       checkInId = Value(checkInId),
       filePath = Value(filePath),
       capturedAt = Value(capturedAt);
  static Insertable<Photo> custom({
    Expression<String>? id,
    Expression<String>? checkInId,
    Expression<String>? filePath,
    Expression<DateTime>? capturedAt,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (checkInId != null) 'check_in_id': checkInId,
      if (filePath != null) 'file_path': filePath,
      if (capturedAt != null) 'captured_at': capturedAt,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<String>? id,
    Value<String>? checkInId,
    Value<String>? filePath,
    Value<DateTime>? capturedAt,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      id: id ?? this.id,
      checkInId: checkInId ?? this.checkInId,
      filePath: filePath ?? this.filePath,
      capturedAt: capturedAt ?? this.capturedAt,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (checkInId.present) {
      map['check_in_id'] = Variable<String>(checkInId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (capturedAt.present) {
      map['captured_at'] = Variable<DateTime>(capturedAt.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('id: $id, ')
          ..write('checkInId: $checkInId, ')
          ..write('filePath: $filePath, ')
          ..write('capturedAt: $capturedAt, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $AcneSpotsTable acneSpots = $AcneSpotsTable(this);
  late final $CheckInRecordsTable checkInRecords = $CheckInRecordsTable(this);
  late final $TreatmentItemsTable treatmentItems = $TreatmentItemsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    acneSpots,
    checkInRecords,
    treatmentItems,
    photos,
  ];
}

typedef $$AcneSpotsTableCreateCompanionBuilder =
    AcneSpotsCompanion Function({
      required String id,
      Value<String> title,
      required String faceRegion,
      required DateTime createdAt,
      Value<String> note,
      Value<String> status,
      Value<int> rowid,
    });
typedef $$AcneSpotsTableUpdateCompanionBuilder =
    AcneSpotsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<String> faceRegion,
      Value<DateTime> createdAt,
      Value<String> note,
      Value<String> status,
      Value<int> rowid,
    });

final class $$AcneSpotsTableReferences
    extends BaseReferences<_$AppDatabase, $AcneSpotsTable, AcneSpot> {
  $$AcneSpotsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CheckInRecordsTable, List<CheckInRecord>>
  _checkInRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkInRecords,
    aliasName: 'acne_spots__id__check_in_records__spot_id',
  );

  $$CheckInRecordsTableProcessedTableManager get checkInRecordsRefs {
    final manager = $$CheckInRecordsTableTableManager(
      $_db,
      $_db.checkInRecords,
    ).filter((f) => f.spotId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkInRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$AcneSpotsTableFilterComposer
    extends Composer<_$AppDatabase, $AcneSpotsTable> {
  $$AcneSpotsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get faceRegion => $composableBuilder(
    column: $table.faceRegion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> checkInRecordsRefs(
    Expression<bool> Function($$CheckInRecordsTableFilterComposer f) f,
  ) {
    final $$CheckInRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.spotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableFilterComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AcneSpotsTableOrderingComposer
    extends Composer<_$AppDatabase, $AcneSpotsTable> {
  $$AcneSpotsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get faceRegion => $composableBuilder(
    column: $table.faceRegion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AcneSpotsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcneSpotsTable> {
  $$AcneSpotsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get faceRegion => $composableBuilder(
    column: $table.faceRegion,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  Expression<T> checkInRecordsRefs<T extends Object>(
    Expression<T> Function($$CheckInRecordsTableAnnotationComposer a) f,
  ) {
    final $$CheckInRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.spotId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$AcneSpotsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcneSpotsTable,
          AcneSpot,
          $$AcneSpotsTableFilterComposer,
          $$AcneSpotsTableOrderingComposer,
          $$AcneSpotsTableAnnotationComposer,
          $$AcneSpotsTableCreateCompanionBuilder,
          $$AcneSpotsTableUpdateCompanionBuilder,
          (AcneSpot, $$AcneSpotsTableReferences),
          AcneSpot,
          PrefetchHooks Function({bool checkInRecordsRefs})
        > {
  $$AcneSpotsTableTableManager(_$AppDatabase db, $AcneSpotsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcneSpotsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcneSpotsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcneSpotsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> faceRegion = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AcneSpotsCompanion(
                id: id,
                title: title,
                faceRegion: faceRegion,
                createdAt: createdAt,
                note: note,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                required String faceRegion,
                required DateTime createdAt,
                Value<String> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AcneSpotsCompanion.insert(
                id: id,
                title: title,
                faceRegion: faceRegion,
                createdAt: createdAt,
                note: note,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AcneSpotsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({checkInRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (checkInRecordsRefs) db.checkInRecords,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (checkInRecordsRefs)
                    await $_getPrefetchedData<
                      AcneSpot,
                      $AcneSpotsTable,
                      CheckInRecord
                    >(
                      currentTable: table,
                      referencedTable: $$AcneSpotsTableReferences
                          ._checkInRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$AcneSpotsTableReferences(
                            db,
                            table,
                            p0,
                          ).checkInRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.spotId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$AcneSpotsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcneSpotsTable,
      AcneSpot,
      $$AcneSpotsTableFilterComposer,
      $$AcneSpotsTableOrderingComposer,
      $$AcneSpotsTableAnnotationComposer,
      $$AcneSpotsTableCreateCompanionBuilder,
      $$AcneSpotsTableUpdateCompanionBuilder,
      (AcneSpot, $$AcneSpotsTableReferences),
      AcneSpot,
      PrefetchHooks Function({bool checkInRecordsRefs})
    >;
typedef $$CheckInRecordsTableCreateCompanionBuilder =
    CheckInRecordsCompanion Function({
      required String id,
      required String spotId,
      required DateTime checkInDate,
      Value<String> note,
      Value<String> phase,
      Value<int> rowid,
    });
typedef $$CheckInRecordsTableUpdateCompanionBuilder =
    CheckInRecordsCompanion Function({
      Value<String> id,
      Value<String> spotId,
      Value<DateTime> checkInDate,
      Value<String> note,
      Value<String> phase,
      Value<int> rowid,
    });

final class $$CheckInRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckInRecordsTable, CheckInRecord> {
  $$CheckInRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $AcneSpotsTable _spotIdTable(_$AppDatabase db) =>
      db.acneSpots.createAlias('check_in_records__spot_id__acne_spots__id');

  $$AcneSpotsTableProcessedTableManager get spotId {
    final $_column = $_itemColumn<String>('spot_id')!;

    final manager = $$AcneSpotsTableTableManager(
      $_db,
      $_db.acneSpots,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_spotIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$TreatmentItemsTable, List<TreatmentItem>>
  _treatmentItemsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.treatmentItems,
    aliasName: 'check_in_records__id__treatment_items__check_in_id',
  );

  $$TreatmentItemsTableProcessedTableManager get treatmentItemsRefs {
    final manager = $$TreatmentItemsTableTableManager(
      $_db,
      $_db.treatmentItems,
    ).filter((f) => f.checkInId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_treatmentItemsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PhotosTable, List<Photo>> _photosRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.photos,
    aliasName: 'check_in_records__id__photos__check_in_id',
  );

  $$PhotosTableProcessedTableManager get photosRefs {
    final manager = $$PhotosTableTableManager(
      $_db,
      $_db.photos,
    ).filter((f) => f.checkInId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_photosRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CheckInRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableFilterComposer({
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

  ColumnFilters<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnFilters(column),
  );

  $$AcneSpotsTableFilterComposer get spotId {
    final $$AcneSpotsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spotId,
      referencedTable: $db.acneSpots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcneSpotsTableFilterComposer(
            $db: $db,
            $table: $db.acneSpots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> treatmentItemsRefs(
    Expression<bool> Function($$TreatmentItemsTableFilterComposer f) f,
  ) {
    final $$TreatmentItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentItems,
      getReferencedColumn: (t) => t.checkInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentItemsTableFilterComposer(
            $db: $db,
            $table: $db.treatmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> photosRefs(
    Expression<bool> Function($$PhotosTableFilterComposer f) f,
  ) {
    final $$PhotosTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.checkInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableFilterComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CheckInRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableOrderingComposer({
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

  ColumnOrderings<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phase => $composableBuilder(
    column: $table.phase,
    builder: (column) => ColumnOrderings(column),
  );

  $$AcneSpotsTableOrderingComposer get spotId {
    final $$AcneSpotsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spotId,
      referencedTable: $db.acneSpots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcneSpotsTableOrderingComposer(
            $db: $db,
            $table: $db.acneSpots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckInRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckInRecordsTable> {
  $$CheckInRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get checkInDate => $composableBuilder(
    column: $table.checkInDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get phase =>
      $composableBuilder(column: $table.phase, builder: (column) => column);

  $$AcneSpotsTableAnnotationComposer get spotId {
    final $$AcneSpotsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.spotId,
      referencedTable: $db.acneSpots,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcneSpotsTableAnnotationComposer(
            $db: $db,
            $table: $db.acneSpots,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> treatmentItemsRefs<T extends Object>(
    Expression<T> Function($$TreatmentItemsTableAnnotationComposer a) f,
  ) {
    final $$TreatmentItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.treatmentItems,
      getReferencedColumn: (t) => t.checkInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TreatmentItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.treatmentItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> photosRefs<T extends Object>(
    Expression<T> Function($$PhotosTableAnnotationComposer a) f,
  ) {
    final $$PhotosTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.photos,
      getReferencedColumn: (t) => t.checkInId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhotosTableAnnotationComposer(
            $db: $db,
            $table: $db.photos,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CheckInRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckInRecordsTable,
          CheckInRecord,
          $$CheckInRecordsTableFilterComposer,
          $$CheckInRecordsTableOrderingComposer,
          $$CheckInRecordsTableAnnotationComposer,
          $$CheckInRecordsTableCreateCompanionBuilder,
          $$CheckInRecordsTableUpdateCompanionBuilder,
          (CheckInRecord, $$CheckInRecordsTableReferences),
          CheckInRecord,
          PrefetchHooks Function({
            bool spotId,
            bool treatmentItemsRefs,
            bool photosRefs,
          })
        > {
  $$CheckInRecordsTableTableManager(
    _$AppDatabase db,
    $CheckInRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckInRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckInRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckInRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> spotId = const Value.absent(),
                Value<DateTime> checkInDate = const Value.absent(),
                Value<String> note = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckInRecordsCompanion(
                id: id,
                spotId: spotId,
                checkInDate: checkInDate,
                note: note,
                phase: phase,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String spotId,
                required DateTime checkInDate,
                Value<String> note = const Value.absent(),
                Value<String> phase = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckInRecordsCompanion.insert(
                id: id,
                spotId: spotId,
                checkInDate: checkInDate,
                note: note,
                phase: phase,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CheckInRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                spotId = false,
                treatmentItemsRefs = false,
                photosRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (treatmentItemsRefs) db.treatmentItems,
                    if (photosRefs) db.photos,
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
                        if (spotId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.spotId,
                                    referencedTable:
                                        $$CheckInRecordsTableReferences
                                            ._spotIdTable(db),
                                    referencedColumn:
                                        $$CheckInRecordsTableReferences
                                            ._spotIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (treatmentItemsRefs)
                        await $_getPrefetchedData<
                          CheckInRecord,
                          $CheckInRecordsTable,
                          TreatmentItem
                        >(
                          currentTable: table,
                          referencedTable: $$CheckInRecordsTableReferences
                              ._treatmentItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CheckInRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).treatmentItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.checkInId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (photosRefs)
                        await $_getPrefetchedData<
                          CheckInRecord,
                          $CheckInRecordsTable,
                          Photo
                        >(
                          currentTable: table,
                          referencedTable: $$CheckInRecordsTableReferences
                              ._photosRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CheckInRecordsTableReferences(
                                db,
                                table,
                                p0,
                              ).photosRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.checkInId == item.id,
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

typedef $$CheckInRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckInRecordsTable,
      CheckInRecord,
      $$CheckInRecordsTableFilterComposer,
      $$CheckInRecordsTableOrderingComposer,
      $$CheckInRecordsTableAnnotationComposer,
      $$CheckInRecordsTableCreateCompanionBuilder,
      $$CheckInRecordsTableUpdateCompanionBuilder,
      (CheckInRecord, $$CheckInRecordsTableReferences),
      CheckInRecord,
      PrefetchHooks Function({
        bool spotId,
        bool treatmentItemsRefs,
        bool photosRefs,
      })
    >;
typedef $$TreatmentItemsTableCreateCompanionBuilder =
    TreatmentItemsCompanion Function({
      required String id,
      required String checkInId,
      required String type,
      required String name,
      Value<String> dosage,
      Value<int> rowid,
    });
typedef $$TreatmentItemsTableUpdateCompanionBuilder =
    TreatmentItemsCompanion Function({
      Value<String> id,
      Value<String> checkInId,
      Value<String> type,
      Value<String> name,
      Value<String> dosage,
      Value<int> rowid,
    });

final class $$TreatmentItemsTableReferences
    extends BaseReferences<_$AppDatabase, $TreatmentItemsTable, TreatmentItem> {
  $$TreatmentItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $CheckInRecordsTable _checkInIdTable(_$AppDatabase db) => db
      .checkInRecords
      .createAlias('treatment_items__check_in_id__check_in_records__id');

  $$CheckInRecordsTableProcessedTableManager get checkInId {
    final $_column = $_itemColumn<String>('check_in_id')!;

    final manager = $$CheckInRecordsTableTableManager(
      $_db,
      $_db.checkInRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_checkInIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TreatmentItemsTableFilterComposer
    extends Composer<_$AppDatabase, $TreatmentItemsTable> {
  $$TreatmentItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnFilters(column),
  );

  $$CheckInRecordsTableFilterComposer get checkInId {
    final $$CheckInRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableFilterComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $TreatmentItemsTable> {
  $$TreatmentItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dosage => $composableBuilder(
    column: $table.dosage,
    builder: (column) => ColumnOrderings(column),
  );

  $$CheckInRecordsTableOrderingComposer get checkInId {
    final $$CheckInRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TreatmentItemsTable> {
  $$TreatmentItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  $$CheckInRecordsTableAnnotationComposer get checkInId {
    final $$CheckInRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TreatmentItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TreatmentItemsTable,
          TreatmentItem,
          $$TreatmentItemsTableFilterComposer,
          $$TreatmentItemsTableOrderingComposer,
          $$TreatmentItemsTableAnnotationComposer,
          $$TreatmentItemsTableCreateCompanionBuilder,
          $$TreatmentItemsTableUpdateCompanionBuilder,
          (TreatmentItem, $$TreatmentItemsTableReferences),
          TreatmentItem,
          PrefetchHooks Function({bool checkInId})
        > {
  $$TreatmentItemsTableTableManager(
    _$AppDatabase db,
    $TreatmentItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TreatmentItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TreatmentItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TreatmentItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> checkInId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> dosage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentItemsCompanion(
                id: id,
                checkInId: checkInId,
                type: type,
                name: name,
                dosage: dosage,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String checkInId,
                required String type,
                required String name,
                Value<String> dosage = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TreatmentItemsCompanion.insert(
                id: id,
                checkInId: checkInId,
                type: type,
                name: name,
                dosage: dosage,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TreatmentItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({checkInId = false}) {
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
                    if (checkInId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.checkInId,
                                referencedTable: $$TreatmentItemsTableReferences
                                    ._checkInIdTable(db),
                                referencedColumn:
                                    $$TreatmentItemsTableReferences
                                        ._checkInIdTable(db)
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

typedef $$TreatmentItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TreatmentItemsTable,
      TreatmentItem,
      $$TreatmentItemsTableFilterComposer,
      $$TreatmentItemsTableOrderingComposer,
      $$TreatmentItemsTableAnnotationComposer,
      $$TreatmentItemsTableCreateCompanionBuilder,
      $$TreatmentItemsTableUpdateCompanionBuilder,
      (TreatmentItem, $$TreatmentItemsTableReferences),
      TreatmentItem,
      PrefetchHooks Function({bool checkInId})
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      required String id,
      required String checkInId,
      required String filePath,
      required DateTime capturedAt,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<String> id,
      Value<String> checkInId,
      Value<String> filePath,
      Value<DateTime> capturedAt,
      Value<String> source,
      Value<int> rowid,
    });

final class $$PhotosTableReferences
    extends BaseReferences<_$AppDatabase, $PhotosTable, Photo> {
  $$PhotosTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CheckInRecordsTable _checkInIdTable(_$AppDatabase db) => db
      .checkInRecords
      .createAlias('photos__check_in_id__check_in_records__id');

  $$CheckInRecordsTableProcessedTableManager get checkInId {
    final $_column = $_itemColumn<String>('check_in_id')!;

    final manager = $$CheckInRecordsTableTableManager(
      $_db,
      $_db.checkInRecords,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_checkInIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
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

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  $$CheckInRecordsTableFilterComposer get checkInId {
    final $$CheckInRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableFilterComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
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

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  $$CheckInRecordsTableOrderingComposer get checkInId {
    final $$CheckInRecordsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableOrderingComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<DateTime> get capturedAt => $composableBuilder(
    column: $table.capturedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  $$CheckInRecordsTableAnnotationComposer get checkInId {
    final $$CheckInRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.checkInId,
      referencedTable: $db.checkInRecords,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckInRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkInRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          Photo,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (Photo, $$PhotosTableReferences),
          Photo,
          PrefetchHooks Function({bool checkInId})
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> checkInId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<DateTime> capturedAt = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                id: id,
                checkInId: checkInId,
                filePath: filePath,
                capturedAt: capturedAt,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String checkInId,
                required String filePath,
                required DateTime capturedAt,
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                id: id,
                checkInId: checkInId,
                filePath: filePath,
                capturedAt: capturedAt,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$PhotosTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({checkInId = false}) {
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
                    if (checkInId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.checkInId,
                                referencedTable: $$PhotosTableReferences
                                    ._checkInIdTable(db),
                                referencedColumn: $$PhotosTableReferences
                                    ._checkInIdTable(db)
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

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      Photo,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (Photo, $$PhotosTableReferences),
      Photo,
      PrefetchHooks Function({bool checkInId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$AcneSpotsTableTableManager get acneSpots =>
      $$AcneSpotsTableTableManager(_db, _db.acneSpots);
  $$CheckInRecordsTableTableManager get checkInRecords =>
      $$CheckInRecordsTableTableManager(_db, _db.checkInRecords);
  $$TreatmentItemsTableTableManager get treatmentItems =>
      $$TreatmentItemsTableTableManager(_db, _db.treatmentItems);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
}
