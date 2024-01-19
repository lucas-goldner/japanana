import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

enum ReviewOptions { n3, n4, conversational, writing }

extension ReviewOptionsExtension on ReviewOptions {
  String getLocalizedTitle(BuildContext context) => switch (this) {
        ReviewOptions.n3 => AppLocalizations.of(context)!.n3Grammar,
        ReviewOptions.n4 => AppLocalizations.of(context)!.n4Grammar,
        ReviewOptions.conversational =>
          AppLocalizations.of(context)!.conversational,
        ReviewOptions.writing => AppLocalizations.of(context)!.writing
      };
}
