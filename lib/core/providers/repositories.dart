import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../database/database.dart';
import '../../shared/models/face_marker_size.dart';
import '../../shared/models/face_region.dart';
import '../../shared/models/placed_spot_marker.dart';
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

  Future<void> updateSpotNote(String id, String note) =>
      _db.updateSpotNote(id, note);

  Future<void> updateSpotTitle(String id, String title) =>
      _db.updateSpotTitle(id, title);

  Future<void> updateSpotMapPosition(String id, double? x, double? y) =>
      _db.updateSpotMapPosition(id, x, y);

  Stream<List<SpotFaceMarker>> watchFaceMarkers(String spotId) =>
      _db.watchFaceMarkersForSpot(spotId);

  Future<String> addFaceMarker(
    String spotId,
    double x,
    double y, {
    FaceMarkerSize size = FaceMarkerSize.small,
  }) async {
    final id = _uuid.v4();
    await _db.insertFaceMarker(
      SpotFaceMarkersCompanion.insert(
        id: id,
        spotId: spotId,
        mapX: x,
        mapY: y,
        size: Value(size.id),
      ),
    );
    return id;
  }

  Future<void> updateFaceMarkerPosition(String id, double x, double y) =>
      _db.updateFaceMarkerPosition(id, x, y);

  Future<void> deleteFaceMarker(String id) => _db.deleteFaceMarker(id);

  Stream<List<PlacedSpotMarker>> watchAllPlacedMarkers() {
    return _db.watchAllPlacedMarkerRows().map(
      (rows) => [
        for (final (marker, spot) in rows)
          PlacedSpotMarker(marker: marker, spot: spot),
      ],
    );
  }

  Future<String> createSpot({
    required FaceRegion region,
    String title = '',
    String note = '',
  }) async {
    final id = _uuid.v4();
    await _db.insertSpot(
      AcneSpotsCompanion.insert(
        id: id,
        title: Value(title),
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

  Future<Photo?> getLatestPhotoForSpot(String spotId) async {
    final checkIns = await _db.getCheckInsForSpot(spotId);
    for (final checkIn in checkIns) {
      final photo = await _db.getPhotoForCheckIn(checkIn.id);
      if (photo != null) return photo;
    }
    return null;
  }

  Future<List<SpotCheckInPhoto>> getTimelineForSpot(String spotId) async {
    final checkIns = await _db.getCheckInsForSpot(spotId);
    final timeline = <SpotCheckInPhoto>[];
    for (final checkIn in checkIns) {
      final photo = await _db.getPhotoForCheckIn(checkIn.id);
      final treatments = await _db.getTreatmentsForCheckIn(checkIn.id);
      timeline.add(
        SpotCheckInPhoto(
          checkIn: checkIn,
          photo: photo,
          treatments: treatments,
        ),
      );
    }
    return timeline;
  }

  Future<String> createCheckIn({
    required String spotId,
    required String photoSourcePath,
    required PhotoSource source,
    required List<TreatmentEntry> treatments,
    required String phaseId,
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
        phase: Value(phaseId),
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

  Future<CheckInDetail?> getCheckInDetail(String checkInId) async {
    final checkIn = await _db.getCheckIn(checkInId);
    if (checkIn == null) return null;
    final photo = await _db.getPhotoForCheckIn(checkInId);
    final treatments = await _db.getTreatmentsForCheckIn(checkInId);
    return CheckInDetail(
      checkIn: checkIn,
      photo: photo,
      treatments: treatments,
    );
  }

  Future<void> updateCheckIn({
    required String checkInId,
    required String phaseId,
    required String note,
    required DateTime checkInDate,
    required List<TreatmentEntry> treatments,
  }) async {
    await _db.updateCheckInRecord(
      checkInId,
      phase: phaseId,
      note: note,
      checkInDate: checkInDate,
    );
    final photo = await _db.getPhotoForCheckIn(checkInId);
    if (photo != null) {
      await _db.updatePhotoCapturedAt(checkInId, checkInDate);
    }
    await _db.deleteTreatmentsForCheckIn(checkInId);
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
  }

  Future<void> deleteCheckIn(String checkInId) async {
    final photo = await _db.getPhotoForCheckIn(checkInId);
    if (photo != null) {
      await PhotoStorage.deletePhoto(photo.filePath);
    }
    await _db.deleteCheckIn(checkInId);
  }
}

class TreatmentEntry {
  TreatmentEntry({required this.type, required this.name, this.dosage = ''});

  final TreatmentType type;
  final String name;
  final String dosage;
}

class SpotCheckInPhoto {
  const SpotCheckInPhoto({
    required this.checkIn,
    required this.photo,
    this.treatments = const [],
  });

  final CheckInRecord checkIn;
  final Photo? photo;
  final List<TreatmentItem> treatments;
}

class CheckInDetail {
  const CheckInDetail({
    required this.checkIn,
    required this.photo,
    required this.treatments,
  });

  final CheckInRecord checkIn;
  final Photo? photo;
  final List<TreatmentItem> treatments;
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

final selectedHomeSpotIdProvider = StateProvider<String?>((ref) => null);

final spotFaceMarkersProvider =
    StreamProvider.family<List<SpotFaceMarker>, String>((ref, spotId) {
      return ref.watch(spotRepositoryProvider).watchFaceMarkers(spotId);
    });

final allPlacedSpotMarkersProvider =
    StreamProvider<List<PlacedSpotMarker>>((ref) {
      return ref.watch(spotRepositoryProvider).watchAllPlacedMarkers();
    });

final spotTimelineProvider =
    FutureProvider.family<List<SpotCheckInPhoto>, String>((ref, spotId) async {
      ref.watch(checkInsForSpotProvider(spotId));
      return ref.read(checkInRepositoryProvider).getTimelineForSpot(spotId);
    });

final spotThumbnailProvider = FutureProvider.family<Photo?, String>((
  ref,
  spotId,
) async {
  ref.watch(checkInsForSpotProvider(spotId));
  return ref.read(checkInRepositoryProvider).getLatestPhotoForSpot(spotId);
});

final checkInDetailProvider = FutureProvider.family<CheckInDetail?, String>((
  ref,
  checkInId,
) {
  return ref.watch(checkInRepositoryProvider).getCheckInDetail(checkInId);
});
