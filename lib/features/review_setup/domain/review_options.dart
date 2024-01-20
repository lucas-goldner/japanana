import 'package:flutter/material.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/extensions.dart';

typedef ReviewOptions = LectureType;

extension ReviewOptionsExtension on ReviewOptions {
  String getLocalizedTitle(BuildContext context) => switch (this) {
        ReviewOptions.n3 => context.l10n.n3Grammar,
        ReviewOptions.n4 => context.l10n.n4Grammar,
        ReviewOptions.conversational => context.l10n.conversational,
        ReviewOptions.writing => context.l10n.writing
      };
}
