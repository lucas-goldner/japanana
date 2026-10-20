import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/features/statistics/domain/study_records.dart';

/// SharedPreferences keys of the study log, also used by backup and reset.
const studyAnswersKey = 'study_answers';
const studySessionsKey = 'study_sessions';

/// Oldest records are dropped beyond this, keeping storage bounded.
const _kMaxRecords = 20000;

final studyLogProvider =
    NotifierProvider<StudyLogNotifier, StudyLog>(StudyLogNotifier.new);

/// Records every answer and review session for the statistics screen.
class StudyLogNotifier extends Notifier<StudyLog> {
  @override
  StudyLog build() {
    final prefs = ref.watch(preferencesProvider);
    return StudyLog(
      answers: [
        for (final json in prefs.getStringList(studyAnswersKey) ?? <String>[])
          AnswerRecord.fromJson(json),
      ],
      sessions: [
        for (final json in prefs.getStringList(studySessionsKey) ?? <String>[])
          SessionRecord.fromJson(json),
      ],
    );
  }

  Future<void> recordAnswer({
    required String lectureId,
    required bool correct,
    required bool firstAttempt,
    String? pickedLectureId,
  }) async {
    final answers = _bounded([
      ...state.answers,
      AnswerRecord(
        time: ref.read(clockProvider)(),
        lectureId: lectureId,
        correct: correct,
        firstAttempt: firstAttempt,
        pickedLectureId: pickedLectureId,
      ),
    ]);
    state = StudyLog(answers: answers, sessions: state.sessions);
    await ref.read(preferencesProvider).setStringList(
          studyAnswersKey,
          [for (final answer in answers) answer.toJson()],
        );
  }

  Future<void> recordSession({
    required DateTime start,
    required int cardsCompleted,
  }) async {
    final sessions = _bounded([
      ...state.sessions,
      SessionRecord(
        start: start,
        end: ref.read(clockProvider)(),
        cardsCompleted: cardsCompleted,
      ),
    ]);
    state = StudyLog(answers: state.answers, sessions: sessions);
    await ref.read(preferencesProvider).setStringList(
          studySessionsKey,
          [for (final session in sessions) session.toJson()],
        );
  }

  List<T> _bounded<T>(List<T> records) => records.length > _kMaxRecords
      ? records.sublist(records.length - _kMaxRecords)
      : records;
}
