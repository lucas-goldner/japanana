import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/features/settings/domain/changelog_entry.dart';

const _kChangelogAsset = 'assets/changelog/changelog.json';

final changelogProvider = FutureProvider<List<ChangelogEntry>>((ref) async {
  final source = await rootBundle.loadString(_kChangelogAsset);
  return (jsonDecode(source) as List<dynamic>)
      .cast<Map<String, dynamic>>()
      .map(ChangelogEntry.fromMap)
      .toList();
});
