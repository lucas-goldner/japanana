import 'package:flutter/foundation.dart';

@immutable
class ChangelogEntry {
  const ChangelogEntry({
    required this.version,
    required this.date,
    required this.changes,
  });

  factory ChangelogEntry.fromMap(Map<String, dynamic> map) => ChangelogEntry(
        version: map['version'] as String,
        date: DateTime.parse(map['date'] as String),
        changes: (map['changes'] as Map<String, dynamic>).map(
          (language, items) =>
              MapEntry(language, (items as List<dynamic>).cast<String>()),
        ),
      );

  final String version;
  final DateTime date;

  /// Changes per language code.
  final Map<String, List<String>> changes;

  /// Changes in [languageCode], falling back to English.
  List<String> changesFor(String languageCode) =>
      changes[languageCode] ?? changes['en'] ?? const [];
}
