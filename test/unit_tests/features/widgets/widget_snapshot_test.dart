import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';
import 'package:japanana/features/statistics/domain/study_stats_calculator.dart';
import 'package:japanana/features/widgets/domain/widget_snapshot.dart';

import '../../../golden/golden_fixtures.dart';

void main() {
  final now = DateTime(2026, 10, 20, 12);
  AnswerRecord answer(int daysAgo) => AnswerRecord(
        time: now.subtract(Duration(days: daysAgo)),
        lectureId: 'n4-1',
        correct: true,
        firstAttempt: true,
      );

  WidgetSnapshot snapshot(List<AnswerRecord> answers, {String lang = 'en'}) =>
      WidgetSnapshot.from(
        stats: calculateStudyStats(
          log: StudyLog(answers: answers, sessions: const []),
          lectures: goldenLectures,
          mistakes: const [],
          now: now,
        ),
        lectures: goldenLectures,
        isSupporter: true,
        now: now,
        l10n: lookupAppLocalizations(Locale(lang)),
      );

  test('writes every field the Swift widget decodes', () {
    final json = jsonDecode(snapshot([answer(0), answer(1)]).toJson())
        as Map<String, dynamic>;
    expect(json.keys, {
      'isSupporter',
      'streak',
      'lastStudyDate',
      'days',
      'grammar',
      'locale',
      'labels',
    });
    expect(json['streak'], 2);
    expect(json['lastStudyDate'], '2026-10-20');
    expect((json['days'] as List).last, {'date': '2026-10-20', 'cards': 1});
    expect((json['days'] as List), hasLength(kWidgetHistoryDays));
    expect(
      (json['grammar'] as Map).keys,
      {'title', 'usage', 'example', 'translation', 'book'},
    );
    expect((json['labels'] as Map).keys, {
      'dayStreak',
      'cardsToday',
      'studyToday',
      'grammarOfDay',
      'thisWeek',
      'supporterPerk',
      'openToUnlock',
    });
  });

  test('labels follow the app language', () {
    final json =
        jsonDecode(snapshot([], lang: 'ja').toJson()) as Map<String, dynamic>;
    expect(json['locale'], 'ja');
    expect((json['labels'] as Map)['grammarOfDay'], '今日の文法');
    expect(json['lastStudyDate'], isNull);
  });

  test('the grammar of the day stays all day and changes the next', () {
    final morning = grammarOfTheDay(goldenLectures, DateTime(2026, 10, 20, 7));
    final evening = grammarOfTheDay(goldenLectures, DateTime(2026, 10, 20, 23));
    final tomorrow = grammarOfTheDay(goldenLectures, DateTime(2026, 10, 21));
    expect(morning, same(evening));
    expect(tomorrow, isNot(same(morning)));
    expect(grammarOfTheDay(const [], now), isNull);
  });
}
