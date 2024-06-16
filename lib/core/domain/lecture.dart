import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

enum LectureType {
  writing,
  conversational,
  n3,
  n4,
}

extension LectureTypeExtension on LectureType {
  String getLocalizedTitle(BuildContext context) => switch (this) {
        LectureType.n3 => context.l10n.n3Grammar,
        LectureType.n4 => context.l10n.n4Grammar,
        LectureType.conversational => context.l10n.conversational,
        LectureType.writing => context.l10n.writing
      };
}

class Lecture {
  Lecture({
    required this.title,
    required this.usages,
    required this.examples,
    required this.translations,
    this.extras,
    required this.types,
  });

  final String title;
  final List<String> usages;
  final List<String> examples;
  final List<String> translations;
  final List<String>? extras;
  final List<LectureType> types;
}
