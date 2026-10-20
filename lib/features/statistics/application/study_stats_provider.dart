import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';
import 'package:japanana/features/statistics/domain/study_stats.dart';
import 'package:japanana/features/statistics/domain/study_stats_calculator.dart';

final studyStatsProvider = Provider<StudyStats>(
  (ref) => calculateStudyStats(
    log: ref.watch(studyLogProvider),
    lectures: ref.watch(lectureProvider),
    mistakes: ref.watch(mistakenLecturesProvider),
    now: ref.watch(clockProvider)(),
  ),
  dependencies: [
    studyLogProvider,
    lectureProvider,
    mistakenLecturesProvider,
    clockProvider,
  ],
);
