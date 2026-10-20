import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/data/progress_backup.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const progress = {
    'mistakes': ['{"lectureId":"n4-1"}'],
    'needToRememberLectures': ['n3-1'],
    'session_n4': '{"lectureType":"n4"}',
  };

  setUp(() => SharedPreferences.setMockInitialValues({
        ...progress,
        'settings_theme_mode': 'dark',
      }));

  test('backup only contains progress', () async {
    final prefs = await SharedPreferences.getInstance();

    final backup = jsonDecode(ProgressBackup.encode(prefs)) as Map;

    expect(backup['app'], 'japanana');
    expect(backup['version'], ProgressBackup.formatVersion);
    expect(backup['data'], progress);
  });

  test('restoring a backup replaces the progress', () async {
    final prefs = await SharedPreferences.getInstance();
    final backup = ProgressBackup.encode(prefs);
    await prefs.setStringList('mistakes', ['other']);
    await prefs.setString('session_writing', 'stale');

    await ProgressBackup.restore(prefs, backup);

    expect(prefs.getStringList('mistakes'), progress['mistakes']);
    expect(prefs.getString('session_writing'), isNull);
    expect(prefs.getString('settings_theme_mode'), 'dark');
  });

  test('rejects files that are not Japanana backups', () async {
    final prefs = await SharedPreferences.getInstance();

    expect(
      () => ProgressBackup.restore(prefs, '{"hello":"world"}'),
      throwsFormatException,
    );
    expect(prefs.getStringList('mistakes'), progress['mistakes']);
  });

  test('clear keeps settings', () async {
    final prefs = await SharedPreferences.getInstance();

    await ProgressBackup.clear(prefs);

    expect(prefs.getStringList('mistakes'), isNull);
    expect(prefs.getStringList('needToRememberLectures'), isNull);
    expect(prefs.getString('session_n4'), isNull);
    expect(prefs.getString('settings_theme_mode'), 'dark');
  });
}
