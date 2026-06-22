import 'package:drift/drift.dart';

class AcneSpots extends Table {
  TextColumn get id => text()();
  TextColumn get faceRegion => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('active'))();

  @override
  Set<Column> get primaryKey => {id};
}

class CheckInRecords extends Table {
  TextColumn get id => text()();
  TextColumn get spotId => text().references(AcneSpots, #id)();
  DateTimeColumn get checkInDate => dateTime()();
  TextColumn get note => text().withDefault(const Constant(''))();
  TextColumn get phase => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class TreatmentItems extends Table {
  TextColumn get id => text()();
  TextColumn get checkInId => text().references(CheckInRecords, #id)();
  TextColumn get type => text()();
  TextColumn get name => text()();
  TextColumn get dosage => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {id};
}

class Photos extends Table {
  TextColumn get id => text()();
  TextColumn get checkInId => text().references(CheckInRecords, #id)();
  TextColumn get filePath => text()();
  DateTimeColumn get capturedAt => dateTime()();
  TextColumn get source => text().withDefault(const Constant('builtin'))();

  @override
  Set<Column> get primaryKey => {id};
}
