import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/features/statistics/domain/study_stats.dart';

/// Days of activity sent to the widgets, enough to draw this week even when
/// the app wasn't opened for a few days.
const kWidgetHistoryDays = 14;

/// Books the grammar of the day comes from, in order.
const _kGrammarBooks = [LectureType.n4, LectureType.n3, LectureType.n2];

/// Everything the iOS widgets show, written for the widget extension as
/// JSON. Field names match `WidgetSnapshot` in
/// `ios/JapananaWidgets/JapananaWidgets.swift`.
@immutable
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.isSupporter,
    required this.streak,
    required this.lastStudyDate,
    required this.days,
    required this.grammar,
    required this.locale,
    required this.labels,
  });

  /// Builds the snapshot from the study stats and lectures on [now].
  factory WidgetSnapshot.from({
    required StudyStats stats,
    required List<Lecture> lectures,
    required bool isSupporter,
    required DateTime now,
    required AppLocalizations l10n,
  }) {
    final recent = stats.days.length > kWidgetHistoryDays
        ? stats.days.sublist(stats.days.length - kWidgetHistoryDays)
        : stats.days;
    final studied = stats.days.where((day) => day.correct + day.wrong > 0);
    return WidgetSnapshot(
      isSupporter: isSupporter,
      streak: stats.currentStreak,
      lastStudyDate: studied.isEmpty ? null : _date(studied.last.day),
      days: {
        for (final day in recent) _date(day.day): day.correct + day.wrong,
      },
      grammar: grammarOfTheDay(lectures, now),
      locale: l10n.localeName,
      labels: {
        'dayStreak': l10n.widgetDayStreak,
        'cardsToday': l10n.widgetCardsToday,
        'studyToday': l10n.widgetStudyToday,
        'grammarOfDay': l10n.widgetGrammarOfDay,
        'thisWeek': l10n.widgetThisWeek,
        'supporterPerk': l10n.widgetSupporterPerk,
        'openToUnlock': l10n.widgetOpenToUnlock,
      },
    );
  }

  final bool isSupporter;
  final int streak;

  /// Last day with answers as `yyyy-MM-dd`, so the widget can end the streak
  /// by itself after a day without study.
  final String? lastStudyDate;

  /// Answers per day, keyed by `yyyy-MM-dd`.
  final Map<String, int> days;
  final Lecture? grammar;
  final String locale;
  final Map<String, String> labels;

  String toJson() => jsonEncode({
        'isSupporter': isSupporter,
        'streak': streak,
        'lastStudyDate': lastStudyDate,
        'days': [
          for (final MapEntry(:key, :value) in days.entries)
            {'date': key, 'cards': value},
        ],
        'grammar': grammar == null
            ? null
            : {
                'title': grammar!.title,
                'usage': grammar!.usages.firstOrNull ?? '',
                'example': grammar!.examples.firstOrNull ?? '',
                'translation': grammar!.translations.firstOrNull ?? '',
                'book': _bookLabel(grammar!),
              },
        'locale': locale,
        'labels': labels,
      });

  @override
  bool operator ==(Object other) =>
      other is WidgetSnapshot && other.toJson() == toJson();

  @override
  int get hashCode => toJson().hashCode;
}

/// A lecture picked for [now]'s date: the same all day, a different one the
/// next day.
Lecture? grammarOfTheDay(List<Lecture> lectures, DateTime now) {
  final candidates = lectures
      .where(
        (lecture) =>
            lecture.examples.isNotEmpty &&
            lecture.usages.isNotEmpty &&
            lecture.types.any(_kGrammarBooks.contains),
      )
      .toList()
    ..sort((a, b) => a.id.compareTo(b.id));
  if (candidates.isEmpty) return null;
  final day = DateTime.utc(now.year, now.month, now.day)
      .difference(DateTime.utc(2024))
      .inDays;
  return candidates[day % candidates.length];
}

String _bookLabel(Lecture lecture) => switch (
        lecture.types.firstWhere(
          _kGrammarBooks.contains,
          orElse: () => LectureType.n4,
        )) {
      LectureType.n2 => 'N2',
      LectureType.n3 => 'N3',
      _ => 'N4',
    };

String _date(DateTime day) => '${day.year.toString().padLeft(4, '0')}-'
    '${day.month.toString().padLeft(2, '0')}-'
    '${day.day.toString().padLeft(2, '0')}';
