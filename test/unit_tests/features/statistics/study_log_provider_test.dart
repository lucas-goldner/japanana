import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('answers and sessions are saved and loaded again', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime(2026, 10, 20, 12);
    ProviderContainer container() => ProviderContainer(
          overrides: [
            preferencesProvider.overrideWithValue(prefs),
            clockProvider.overrideWithValue(() => now),
          ],
        );

    final first = container();
    addTearDown(first.dispose);
    final notifier = first.read(studyLogProvider.notifier);
    await notifier.recordAnswer(
      lectureId: 'a',
      correct: false,
      firstAttempt: true,
      pickedLectureId: 'b',
    );
    await notifier.recordSession(
      start: now.subtract(const Duration(minutes: 5)),
      cardsCompleted: 3,
    );

    final second = container();
    addTearDown(second.dispose);
    final log = second.read(studyLogProvider);

    expect(log.answers.single.pickedLectureId, 'b');
    expect(log.answers.single.time, now);
    expect(log.sessions.single.cardsCompleted, 3);
    expect(
      log.sessions.single.end.difference(log.sessions.single.start),
      const Duration(minutes: 5),
    );
  });
}
