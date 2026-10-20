import 'dart:convert';

import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Serializes the learner's progress (mistakes, saved lectures and unfinished
/// review sessions) so it can be backed up, restored or reset.
// ignore: avoid_classes_with_only_static_members
abstract final class ProgressBackup {
  static const formatVersion = 1;
  static const _mistakesKey = 'mistakes';

  static final _listKeys = [
    _mistakesKey,
    SharedPreferencesKey.needToRememberLectures.value,
  ];

  static final _stringKeys = [
    for (final type in LectureType.values)
      SharedPreferencesKey.sessionKey(type).value,
  ];

  static String encode(SharedPreferences prefs, {DateTime? now}) =>
      const JsonEncoder.withIndent('  ').convert({
        'app': 'japanana',
        'version': formatVersion,
        'createdAt': (now ?? DateTime.now()).toIso8601String(),
        'data': {
          for (final key in _listKeys)
            if (prefs.getStringList(key) case final value?) key: value,
          for (final key in _stringKeys)
            if (prefs.getString(key) case final value?) key: value,
        },
      });

  /// Replaces the current progress with the backup in [source].
  ///
  /// Throws a [FormatException] when [source] isn't a Japanana backup.
  static Future<void> restore(SharedPreferences prefs, String source) async {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic> ||
        decoded['app'] != 'japanana' ||
        decoded['data'] is! Map<String, dynamic>) {
      throw const FormatException('Not a Japanana backup');
    }
    if ((decoded['version'] as int? ?? 0) > formatVersion) {
      throw const FormatException('Backup is from a newer app version');
    }

    final data = decoded['data'] as Map<String, dynamic>;
    await clear(prefs);
    for (final key in _listKeys) {
      if (data[key] case final List<dynamic> value) {
        await prefs.setStringList(key, value.cast<String>());
      }
    }
    for (final key in _stringKeys) {
      if (data[key] case final String value) {
        await prefs.setString(key, value);
      }
    }
  }

  static Future<void> clear(SharedPreferences prefs) async {
    for (final key in [..._listKeys, ..._stringKeys]) {
      await prefs.remove(key);
    }
  }
}
