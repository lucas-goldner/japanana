import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/domain/changelog_entry.dart';

void main() {
  test('bundled changelog parses and has every language', () {
    final entries = (jsonDecode(
      File('assets/changelog/changelog.json').readAsStringSync(),
    ) as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map(ChangelogEntry.fromMap)
        .toList();

    expect(entries, isNotEmpty);
    for (final entry in entries) {
      expect(entry.changesFor('en'), isNotEmpty);
      expect(entry.changesFor('ja'), hasLength(entry.changesFor('en').length));
    }
  });

  test('falls back to English for unknown languages', () {
    final entry = ChangelogEntry.fromMap(const {
      'version': '1.0.0',
      'date': '2025-01-01',
      'changes': {
        'en': ['First release'],
      },
    });

    expect(entry.changesFor('fr'), ['First release']);
  });
}
