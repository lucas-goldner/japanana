import 'package:flutter/widgets.dart';
import 'package:japanana/core/extensions.dart';

/// Localized relative time such as "3 hours ago".
String relativeTime(BuildContext context, DateTime when, DateTime now) {
  final difference = now.difference(when);
  final l10n = context.l10n;
  if (difference.inDays > 0) return l10n.timeDaysAgo(difference.inDays);
  if (difference.inHours > 0) return l10n.timeHoursAgo(difference.inHours);
  if (difference.inMinutes > 0) {
    return l10n.timeMinutesAgo(difference.inMinutes);
  }
  return l10n.timeJustNow;
}
