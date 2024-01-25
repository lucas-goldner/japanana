import 'package:flutter/material.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/extensions.dart';

typedef ReviewSections = LectureType;

extension ReviewSectionsExtension on ReviewSections {
  String getLocalizedTitle(BuildContext context) => switch (this) {
        ReviewSections.n3 => context.l10n.n3Grammar,
        ReviewSections.n4 => context.l10n.n4Grammar,
        ReviewSections.conversational => context.l10n.conversational,
        ReviewSections.writing => context.l10n.writing
      };
}
