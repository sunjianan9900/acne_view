import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(tables: [AcneSpots, SpotFaceMarkers, CheckInRecords, TreatmentItems, Photos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onUpgrade: (migrator, from, to) async {
      if (from < 2) {
        await migrator.addColumn(checkInRecords, checkInRecords.phase);
      }
      if (from < 3) {
        await migrator.addColumn(acneSpots, acneSpots.title);
      }
      if (from < 4) {
        await migrator.addColumn(acneSpots, acneSpots.faceMapX);
        await migrator.addColumn(acneSpots, acneSpots.faceMapY);
      }
      if (from < 5) {
        await migrator.createTable(spotFaceMarkers);
        final legacySpots = await (select(acneSpots)
              ..where((t) => t.faceMapX.isNotNull() & t.faceMapY.isNotNull()))
            .get();
        for (final spot in legacySpots) {
          final x = spot.faceMapX;
          final y = spot.faceMapY;
          if (x == null || y == null) continue;
          await into(spotFaceMarkers).insert(
            SpotFaceMarkersCompanion.insert(
              id: '${spot.id}-legacy-marker',
              spotId: spot.id,
              mapX: x,
              mapY: y,
            ),
          );
        }
      }
    },
  );

  // --- Acne Spots ---

  Stream<List<AcneSpot>> watchAllSpots() {
    return (select(
      acneSpots,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).watch();
  }

  Stream<List<AcneSpot>> watchSpotsByRegion(String regionId) {
    return (select(acneSpots)
          ..where((t) => t.faceRegion.equals(regionId))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Stream<List<AcneSpot>> watchActiveSpots() {
    return (select(acneSpots)
          ..where((t) => t.status.equals('active'))
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .watch();
  }

  Future<AcneSpot?> getSpot(String id) {
    return (select(acneSpots)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertSpot(AcneSpotsCompanion spot) {
    return into(acneSpots).insert(spot);
  }

  Future<bool> updateSpot(AcneSpotsCompanion spot) {
    return update(acneSpots).replace(spot);
  }

  Future<int> updateSpotNote(String id, String note) {
    return (update(acneSpots)..where((t) => t.id.equals(id))).write(
      AcneSpotsCompanion(note: Value(note)),
    );
  }

  Future<int> updateSpotStatus(String id, String status) {
    return (update(acneSpots)..where((t) => t.id.equals(id))).write(
      AcneSpotsCompanion(status: Value(status)),
    );
  }

  Future<int> updateSpotMapPosition(String id, double? x, double? y) {
    return (update(acneSpots)..where((t) => t.id.equals(id))).write(
      AcneSpotsCompanion(
        faceMapX: Value(x),
        faceMapY: Value(y),
      ),
    );
  }

  Future<int> deleteSpot(String id) async {
    await (delete(spotFaceMarkers)..where((t) => t.spotId.equals(id))).go();
    final checkIns = await (select(
      checkInRecords,
    )..where((t) => t.spotId.equals(id))).get();
    for (final checkIn in checkIns) {
      await deleteCheckIn(checkIn.id);
    }
    return (delete(acneSpots)..where((t) => t.id.equals(id))).go();
  }

  Future<int> countActiveSpotsByRegion(String regionId) async {
    final query = selectOnly(acneSpots)
      ..addColumns([acneSpots.id.count()])
      ..where(acneSpots.faceRegion.equals(regionId))
      ..where(acneSpots.status.equals('active'));
    final row = await query.getSingle();
    return row.read(acneSpots.id.count()) ?? 0;
  }

  Future<int> countActiveSpots() async {
    final query = selectOnly(acneSpots)
      ..addColumns([acneSpots.id.count()])
      ..where(acneSpots.status.equals('active'));
    final row = await query.getSingle();
    return row.read(acneSpots.id.count()) ?? 0;
  }

  // --- Spot face markers ---

  Stream<List<SpotFaceMarker>> watchFaceMarkersForSpot(String spotId) {
    return (select(spotFaceMarkers)..where((t) => t.spotId.equals(spotId)))
        .watch();
  }

  Future<int> insertFaceMarker(SpotFaceMarkersCompanion marker) {
    return into(spotFaceMarkers).insert(marker);
  }

  Future<int> updateFaceMarkerPosition(String id, double x, double y) {
    return (update(spotFaceMarkers)..where((t) => t.id.equals(id))).write(
      SpotFaceMarkersCompanion(mapX: Value(x), mapY: Value(y)),
    );
  }

  Future<int> deleteFaceMarker(String id) {
    return (delete(spotFaceMarkers)..where((t) => t.id.equals(id))).go();
  }

  // --- Check-ins ---

  Stream<List<CheckInRecord>> watchCheckInsForSpot(String spotId) {
    return (select(checkInRecords)
          ..where((t) => t.spotId.equals(spotId))
          ..orderBy([(t) => OrderingTerm.desc(t.checkInDate)]))
        .watch();
  }

  Future<List<CheckInRecord>> getCheckInsForSpot(String spotId) {
    return (select(checkInRecords)
          ..where((t) => t.spotId.equals(spotId))
          ..orderBy([(t) => OrderingTerm.desc(t.checkInDate)]))
        .get();
  }

  Future<CheckInRecord?> getCheckIn(String id) {
    return (select(
      checkInRecords,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<bool> hasCheckInToday(String spotId) async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final result =
        await (select(checkInRecords)
              ..where((t) => t.spotId.equals(spotId))
              ..where((t) => t.checkInDate.isBiggerOrEqualValue(start))
              ..where((t) => t.checkInDate.isSmallerThanValue(end)))
            .get();
    return result.isNotEmpty;
  }

  Future<int> countTodayCheckIns() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final query = selectOnly(checkInRecords)
      ..addColumns([checkInRecords.id.count()])
      ..where(checkInRecords.checkInDate.isBiggerOrEqualValue(start))
      ..where(checkInRecords.checkInDate.isSmallerThanValue(end));
    final row = await query.getSingle();
    return row.read(checkInRecords.id.count()) ?? 0;
  }

  Future<int> insertCheckIn(CheckInRecordsCompanion record) {
    return into(checkInRecords).insert(record);
  }

  Future<int> updateCheckInRecord(
    String id, {
    required String phase,
    required String note,
    required DateTime checkInDate,
  }) {
    return (update(checkInRecords)..where((t) => t.id.equals(id))).write(
      CheckInRecordsCompanion(
        phase: Value(phase),
        note: Value(note),
        checkInDate: Value(checkInDate),
      ),
    );
  }

  Future<int> deleteCheckIn(String id) async {
    await (delete(treatmentItems)..where((t) => t.checkInId.equals(id))).go();
    await (delete(photos)..where((t) => t.checkInId.equals(id))).go();
    return (delete(checkInRecords)..where((t) => t.id.equals(id))).go();
  }

  // --- Treatments ---

  Future<List<TreatmentItem>> getTreatmentsForCheckIn(String checkInId) {
    return (select(
      treatmentItems,
    )..where((t) => t.checkInId.equals(checkInId))).get();
  }

  Future<int> insertTreatment(TreatmentItemsCompanion item) {
    return into(treatmentItems).insert(item);
  }

  Future<int> deleteTreatmentsForCheckIn(String checkInId) {
    return (delete(
      treatmentItems,
    )..where((t) => t.checkInId.equals(checkInId))).go();
  }

  // --- Photos ---

  Future<Photo?> getPhotoForCheckIn(String checkInId) {
    return (select(
      photos,
    )..where((t) => t.checkInId.equals(checkInId))).getSingleOrNull();
  }

  Future<int> insertPhoto(PhotosCompanion photo) {
    return into(photos).insert(photo);
  }

  Future<int> updatePhotoCapturedAt(String checkInId, DateTime capturedAt) {
    return (update(photos)..where((t) => t.checkInId.equals(checkInId))).write(
      PhotosCompanion(capturedAt: Value(capturedAt)),
    );
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'douji.db'));
    return NativeDatabase(file);
  });
}
