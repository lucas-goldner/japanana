import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/learning_plan.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LearningPlan', () {
    LearningPlan plan(OnboardingAnswers answers) => LearningPlan.calculate(
      answers: answers,
      lectureCounts: kDefaultLectureCounts,
      totalPoints: kDefaultLectureTotal,
      now: DateTime(2026, 10, 20),
    );

    test('counts the books from the level up', () {
      expect(plan(const OnboardingAnswers()).pointsToGo, 536);
      expect(
        plan(const OnboardingAnswers(level: JlptLevel.n3)).pointsToGo,
        468,
      );
      expect(
        plan(const OnboardingAnswers(level: JlptLevel.n1)).pointsToGo,
        146,
      );
    });

    test('daily practice is faster than studying alone', () {
      final result = plan(const OnboardingAnswers());
      expect(result.monthsAlone, 21);
      expect(result.monthsWithJapanana, 8);
      expect(result.targetDate, DateTime(2027, 6));
    });

    test('more minutes a day means an earlier date', () {
      final ten = plan(const OnboardingAnswers());
      final twenty = plan(const OnboardingAnswers(dailyMinutes: 20));
      expect(twenty.monthsWithJapanana, lessThan(ten.monthsWithJapanana));
    });

    test('never takes longer than studying alone', () {
      final result = plan(
        const OnboardingAnswers(level: JlptLevel.n2, dailyMinutes: 5),
      );
      expect(result.monthsWithJapanana, lessThanOrEqualTo(result.monthsAlone));
    });
  });

  test('answers survive a JSON round trip', () {
    const answers = OnboardingAnswers(
      goal: OnboardingGoal.anime,
      level: JlptLevel.n3,
      years: 4,
      speakingConfidence: 0.2,
      pains: {OnboardingPain.forget, OnboardingPain.mixUp},
      dailyMinutes: 15,
    );
    expect(OnboardingAnswers.fromJson(answers.toJson()), answers);
  });

  group('shouldShowOnboarding', () {
    Future<SharedPreferences> prefs(Map<String, Object> values) {
      SharedPreferences.setMockInitialValues(values);
      return SharedPreferences.getInstance();
    }

    test('shows on a fresh install', () async {
      expect(shouldShowOnboarding(await prefs({})), isTrue);
    });

    test('skips once completed', () async {
      expect(
        shouldShowOnboarding(await prefs({onboardingCompletedKey: true})),
        isFalse,
      );
    });

    test('skips for learners who already studied', () async {
      expect(
        shouldShowOnboarding(await prefs({'mistakes': <String>[]})),
        isFalse,
      );
      expect(shouldShowOnboarding(await prefs({'session_n4': '{}'})), isFalse);
    });
  });

  test('notifier persists answers and completion', () async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final container = ProviderContainer(
      overrides: [preferencesProvider.overrideWithValue(preferences)],
    );
    addTearDown(container.dispose);

    final notifier = container.read(onboardingProvider.notifier);
    await notifier.update((a) => a.copyWith(level: JlptLevel.n2));
    await notifier.togglePain(OnboardingPain.textbook, agreed: true);
    await notifier.complete();

    final saved = OnboardingAnswers.fromJson(
      preferences.getString(onboardingAnswersKey)!,
    );
    expect(saved.level, JlptLevel.n2);
    expect(saved.level.startingBook, LectureType.n2);
    expect(saved.pains, {OnboardingPain.textbook});
    expect(shouldShowOnboarding(preferences), isFalse);
  });
}
