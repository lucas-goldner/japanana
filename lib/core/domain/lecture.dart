import 'package:flutter/widgets.dart';
import 'package:japanana/core/extensions.dart';

enum LectureType {
  writing,
  conversational,
  n2,
  n3,
  n4,
  remember;

  String getLocalizedTitle(BuildContext context) => switch (this) {
        LectureType.n2 => context.l10n.n2Grammar,
        LectureType.n3 => context.l10n.n3Grammar,
        LectureType.n4 => context.l10n.n4Grammar,
        LectureType.conversational => context.l10n.conversational,
        LectureType.writing => context.l10n.writing,
        LectureType.remember => context.l10n.rememberedSection
      };
}

class Lecture {
  Lecture({
    required this.id,
    required this.title,
    required this.usages,
    required this.examples,
    required this.translations,
    required this.types,
    this.extras,
  });

  final String id;
  final String title;
  final List<String> usages;
  final List<String> examples;
  final List<String> translations;
  final List<String>? extras;
  final List<LectureType> types;

  Lecture copyWith({
    String? id,
    String? title,
    List<String>? usages,
    List<String>? examples,
    List<String>? translations,
    List<String>? extras,
    List<LectureType>? types,
  }) =>
      Lecture(
        id: id ?? this.id,
        title: title ?? this.title,
        usages: usages ?? this.usages,
        examples: examples ?? this.examples,
        translations: translations ?? this.translations,
        extras: extras ?? this.extras,
        types: types ?? this.types,
      );
}
