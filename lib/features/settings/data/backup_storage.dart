import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icloud_storage_plus/icloud_storage.dart';
import 'package:japanana/core/app_config.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Stored in the container's Documents folder so it shows up in iCloud Drive.
const _kICloudPath = 'Documents/japanana-backup.json';

final backupStorageProvider =
    Provider<BackupStorage>((ref) => DeviceBackupStorage());

/// Moves backup files in and out of the app.
abstract interface class BackupStorage {
  /// Whether iCloud backups are offered on this device.
  bool get supportsICloud;

  /// Hands [contents] to the share sheet as a JSON file.
  Future<void> exportFile(String contents, {Rect? shareOrigin});

  /// Lets the user pick a backup file. Returns null when cancelled.
  Future<String?> importFile();

  Future<void> uploadToICloud(String contents);

  /// Returns the iCloud backup, or null when there is none.
  Future<String?> downloadFromICloud();
}

class DeviceBackupStorage implements BackupStorage {
  @override
  bool get supportsICloud =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.iOS ||
          defaultTargetPlatform == TargetPlatform.macOS);

  Future<File> _tempFile(String name) async {
    final directory = await getTemporaryDirectory();
    return File('${directory.path}/$name');
  }

  @override
  Future<void> exportFile(String contents, {Rect? shareOrigin}) async {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final file = await _tempFile('japanana-backup-$date.json');
    await file.writeAsString(contents);
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/json')],
        sharePositionOrigin: shareOrigin,
      ),
    );
  }

  @override
  Future<String?> importFile() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    final bytes = await files.first.readAsBytes();
    return utf8.decode(bytes);
  }

  @override
  Future<void> uploadToICloud(String contents) => ICloudStorage.writeInPlace(
        containerId: AppConfig.iCloudContainerId,
        relativePath: _kICloudPath,
        contents: contents,
      );

  @override
  Future<String?> downloadFromICloud() async {
    final exists = await ICloudStorage.documentExists(
      containerId: AppConfig.iCloudContainerId,
      relativePath: _kICloudPath,
    );
    if (!exists) return null;
    return ICloudStorage.readInPlace(
      containerId: AppConfig.iCloudContainerId,
      relativePath: _kICloudPath,
    );
  }
}
