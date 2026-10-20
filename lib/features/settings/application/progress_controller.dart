import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/features/session/application/session_provider.dart';
import 'package:japanana/features/settings/data/backup_storage.dart';
import 'package:japanana/features/settings/data/progress_backup.dart';

final progressControllerProvider = Provider<ProgressController>(
  ProgressController.new,
);

/// Resets, backs up and restores the learner's progress, and reloads the
/// providers that cache it.
class ProgressController {
  ProgressController(this._ref);
  final Ref _ref;

  BackupStorage get _storage => _ref.read(backupStorageProvider);

  bool get supportsICloud => _storage.supportsICloud;

  Future<void> reset() async {
    await ProgressBackup.clear(_ref.read(preferencesProvider));
    await _reload();
  }

  Future<void> exportFile({Rect? shareOrigin}) => _storage.exportFile(
        ProgressBackup.encode(_ref.read(preferencesProvider)),
        shareOrigin: shareOrigin,
      );

  /// Returns false when the user cancelled picking a file.
  Future<bool> importFile() async {
    final contents = await _storage.importFile();
    if (contents == null) return false;
    await _restore(contents);
    return true;
  }

  Future<void> backupToICloud() => _storage
      .uploadToICloud(ProgressBackup.encode(_ref.read(preferencesProvider)));

  /// Returns false when there is no backup in iCloud.
  Future<bool> restoreFromICloud() async {
    final contents = await _storage.downloadFromICloud();
    if (contents == null) return false;
    await _restore(contents);
    return true;
  }

  Future<void> _restore(String contents) async {
    await ProgressBackup.restore(_ref.read(preferencesProvider), contents);
    await _reload();
  }

  Future<void> _reload() async {
    _ref
      ..invalidate(mistakenLecturesProvider)
      ..invalidate(sessionProvider);
    await _ref.read(lectureProvider.notifier).fetchLectures();
  }
}
