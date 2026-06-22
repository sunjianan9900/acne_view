import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/photo_source.dart';
import '../../shared/models/spot_status.dart';
import '../../shared/models/treatment_type.dart';
import '../camera/camera_service.dart';

const _uuid = Uuid();

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

class AcneSpotRepository {
  AcneSpotRepository(this._db);

  final AppDatabase _db;

  Stream<List<AcneSpot>> watchAllSpots() => _db.watchAllSpots();

  Stream<List<AcneSpot>> watchSpotsByRegion(FaceRegion region) =>
      _db.watchSpotsByRegion(region.id);

  Stream<List<AcneSpot>> watchActiveSpots() => _db.watchActiveSpots();

  Future<AcneSpot?> getSpot(String id) => _db.getSpot(id);

  Future<String> createSpot({
    required FaceRegion region,
    String note = '',
  }) async {
    final id = _uuid.v4();
    await _db.insertSpot(
      AcneSpotsCompanion.insert(
        id: id,
        faceRegion: region.id,
        createdAt: DateTime.now(),
        note: Value(note),
        status: const Value('active'),
      ),
    );
    return id;
  }

  Future<void> updateSpotStatus(String id, SpotStatus status) =>
      _db.updateSpotStatus(id, status.id);

  Future<void> deleteSpot(String id) => _db.deleteSpot(id);

  Future<Map<String, int>> getActiveCountByRegion() async {
    final counts = <String, int>{};
    for (final region in FaceRegion.values) {
      counts[region.id] = await _db.countActiveSpotsByRegion(region.id);
    }
    return counts;
  }

  Future<int> countActiveSpots() => _db.countActiveSpots();
}

class CheckInRepository {
  CheckInRepository(this._db);

  final AppDatabase _db;

  Stream<List<CheckInRecord>> watchCheckInsForSpot(String spotId) =>
      _db.watchCheckInsForSpot(spotId);

  Future<List<CheckInRecord>> getCheckInsForSpot(String spotId) =>
      _db.getCheckInsForSpot(spotId);

  Future<bool> hasCheckInToday(String spotId) => _db.hasCheckInToday(spotId);

  Future<int> countTodayCheckIns() => _db.countTodayCheckIns();

  Future<List<TreatmentItem>> getTreatments(String checkInId) =>
      _db.getTreatmentsForCheckIn(checkInId);

  Future<Photo?> getPhoto(String checkInId) =>
      _db.getPhotoForCheckIn(checkInId);

  Future<String> createCheckIn({
    required String spotId,
    required String photoSourcePath,
    required PhotoSource source,
    required List<TreatmentEntry> treatments,
    String note = '',
    DateTime? checkInDate,
  }) async {
    final checkInId = _uuid.v4();
    final now = checkInDate ?? DateTime.now();

    await _db.insertCheckIn(
      CheckInRecordsCompanion.insert(
        id: checkInId,
        spotId: spotId,
        checkInDate: now,
        note: Value(note),
      ),
    );

    for (final treatment in treatments) {
      if (treatment.name.trim().isEmpty) continue;
      await _db.insertTreatment(
        TreatmentItemsCompanion.insert(
          id: _uuid.v4(),
          checkInId: checkInId,
          type: treatment.type.id,
          name: treatment.name.trim(),
          dosage: Value(treatment.dosage),
        ),
      );
    }

    final savedPath = await PhotoStorage.savePhoto(
      spotId: spotId,
      sourcePath: photoSourcePath,
      capturedAt: now,
    );

    await _db.insertPhoto(
      PhotosCompanion.insert(
        id: _uuid.v4(),
        checkInId: checkInId,
        filePath: savedPath,
        capturedAt: now,
        source: Value(source.id),
      ),
    );

    return checkInId;
  }
}

class TreatmentEntry {
  TreatmentEntry({required this.type, required this.name, this.dosage = ''});

  final TreatmentType type;
  final String name;
  final String dosage;
}

final spotRepositoryProvider = Provider<AcneSpotRepository>((ref) {
  return AcneSpotRepository(ref.watch(databaseProvider));
});

final checkInRepositoryProvider = Provider<CheckInRepository>((ref) {
  return CheckInRepository(ref.watch(databaseProvider));
});

final activeSpotCountProvider = StreamProvider<int>((ref) {
  return ref
      .watch(databaseProvider)
      .watchActiveSpots()
      .map((spots) => spots.length);
});

final regionCountsProvider = FutureProvider<Map<String, int>>((ref) async {
  return ref.watch(spotRepositoryProvider).getActiveCountByRegion();
});

final todayCheckInCountProvider = FutureProvider<int>((ref) async {
  return ref.watch(checkInRepositoryProvider).countTodayCheckIns();
});

final spotProvider = FutureProvider.family<AcneSpot?, String>((ref, spotId) {
  return ref.watch(spotRepositoryProvider).getSpot(spotId);
});

final checkInsForSpotProvider =
    StreamProvider.family<List<CheckInRecord>, String>((ref, spotId) {
      return ref.watch(checkInRepositoryProvider).watchCheckInsForSpot(spotId);
    });

final spotsByRegionProvider = StreamProvider.family<List<AcneSpot>, String>((
  ref,
  regionId,
) {
  final region = FaceRegion.fromId(regionId);
  if (region == null) return Stream.value([]);
  return ref.watch(spotRepositoryProvider).watchSpotsByRegion(region);
});

final allSpotsProvider = StreamProvider<List<AcneSpot>>((ref) {
  return ref.watch(spotRepositoryProvider).watchAllSpots();
});
