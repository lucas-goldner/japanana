import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/domain/shared_preferences_key.dart';
import 'package:japanana/features/onboarding/domain/learning_plan.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';
import 'package:japanana/features/statistics/application/study_log_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const onboardingAnswersKey = 'onboarding_answers';
const onboardingCompletedKey = 'onboarding_completed';

/// Whether a fresh install should start with the onboarding. Learners who
/// already studied before the onboarding existed skip it.
bool shouldShowOnboarding(SharedPreferences prefs) {
  if (prefs.getBool(onboardingCompletedKey) ?? false) return false;
  final progressKeys = [
    studyAnswersKey,
    studySessionsKey,
    'mistakes',
    for (final key in SharedPreferencesKey.values) key.value,
  ];
  return !progressKeys.any(prefs.containsKey);
}

final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingAnswers>(
      OnboardingNotifier.new,
    );

class OnboardingNotifier extends Notifier<OnboardingAnswers> {
  /// Whether the rating prompt was already requested, so going back and
  /// forth doesn't ask twice.
  bool reviewRequested = false;

  @override
  OnboardingAnswers build() {
    final json = ref.watch(preferencesProvider).getString(onboardingAnswersKey);
    return json == null
        ? const OnboardingAnswers()
        : OnboardingAnswers.fromJson(json);
  }

  Future<void> update(
    OnboardingAnswers Function(OnboardingAnswers answers) change,
  ) async {
    state = change(state);
    await ref
        .read(preferencesProvider)
        .setString(onboardingAnswersKey, state.toJson());
  }

  Future<void> togglePain(OnboardingPain pain, {required bool agreed}) =>
      update(
        (answers) => answers.copyWith(
          pains: agreed
              ? {...answers.pains, pain}
              : ({...answers.pains}..remove(pain)),
        ),
      );

  Future<void> complete() =>
      ref.read(preferencesProvider).setBool(onboardingCompletedKey, true);
}

/// Plan for the learner's answers. Pass daily minutes to override the
/// learner's choice, e.g. before they picked their daily rhythm.
final learningPlanProvider = Provider.family<LearningPlan, int?>((
  ref,
  dailyMinutes,
) {
  final answers = ref.watch(onboardingProvider);
  final lectures = ref.watch(lectureProvider);
  final counts = <LectureType, int>{};
  for (final lecture in lectures) {
    for (final type in lecture.types) {
      counts[type] = (counts[type] ?? 0) + 1;
    }
  }
  // Until the lectures are loaded, the bundled counts give the same numbers.
  final loaded = lectures.isNotEmpty;
  return LearningPlan.calculate(
    answers: dailyMinutes == null
        ? answers
        : answers.copyWith(dailyMinutes: dailyMinutes),
    lectureCounts: loaded ? counts : kDefaultLectureCounts,
    totalPoints: loaded ? lectures.length : kDefaultLectureTotal,
    now: ref.watch(clockProvider)(),
  );
}, dependencies: [lectureProvider, onboardingProvider, clockProvider]);
