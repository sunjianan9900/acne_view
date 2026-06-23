import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../photo/photo_flip_migration.dart';
import '../providers/repositories.dart';

final photoFlipMigrationServiceProvider = Provider<PhotoFlipMigrationService>((
  ref,
) {
  return PhotoFlipMigrationService(ref.watch(databaseProvider));
});

final photoFlipMigrationDoneProvider = FutureProvider<bool>((ref) async {
  return ref.watch(photoFlipMigrationServiceProvider).isMigrated();
});
