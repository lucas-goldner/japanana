import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/demo_result.dart';
import 'package:japanana/features/onboarding/domain/onboarding_answers.dart';
import 'package:japanana/features/onboarding/presentation/onboarding_screen.dart';

import 'golden_fakes.dart';
import 'golden_fixtures.dart';
import 'golden_utils.dart';

final _answers = const OnboardingAnswers(
  goal: OnboardingGoal.talk,
  years: 2,
  speakingConfidence: 0.3,
  pains: {OnboardingPain.cantSpeak, OnboardingPain.mixUp},
).toJson();

final _demoResult = DemoResult(
  lecture: goldenLectures[0],
  firstTry: false,
  mixedUpWith: goldenLectures[1],
  nextLecture: goldenLectures[2],
);

/// Long enough for every intro animation of a step to finish.
const _kSettle = Duration(milliseconds: 4200);

void main() {
  setUpGoldens();

  Future<void> pumpStep(
    WidgetTester tester,
    ThemeData theme,
    OnboardingStep step, {
    bool storeAvailable = true,
    bool withLectures = false,
    Locale locale = const Locale('en'),
  }) => pumpGoldenScreen(
    tester,
    theme: theme,
    locale: locale,
    preferences: {onboardingAnswersKey: _answers},
    // Without lectures the plan uses the real grammar counts.
    lectures: withLectures ? null : const [],
    purchases: FakePurchasesService(isAvailable: storeAvailable),
    screen: OnboardingScreen(
      initialStep: step,
      initialDemoResult: _demoResult,
      onFinished: () {},
    ),
  );

  for (final step in OnboardingStep.values) {
    if (step == OnboardingStep.demo) continue;
    goldenTest('onboarding ${step.name}', (tester, theme, themeName) async {
      await pumpStep(tester, theme, step);
      // The plan builds itself and moves on, so catch it halfway.
      await pumpFor(
        tester,
        step == OnboardingStep.building
            ? const Duration(milliseconds: 1800)
            : _kSettle,
      );
      await expectScreenGolden(
        tester,
        screen: 'onboarding',
        name: step.name,
        themeName: themeName,
      );
    });
  }

  goldenTest('onboarding hook in Japanese', (tester, theme, themeName) async {
    await pumpStep(
      tester,
      theme,
      OnboardingStep.hook,
      locale: const Locale('ja'),
    );
    await pumpFor(tester, _kSettle);
    await expectScreenGolden(
      tester,
      screen: 'onboarding',
      name: 'hook_ja',
      themeName: themeName,
    );
  });

  goldenTest('onboarding paywall without store', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpStep(
      tester,
      theme,
      OnboardingStep.paywall,
      storeAvailable: false,
    );
    await pumpFor(tester, _kSettle);
    await expectScreenGolden(
      tester,
      screen: 'onboarding',
      name: 'paywall_no_store',
      themeName: themeName,
    );
  });

  goldenTest('onboarding demo', (tester, theme, themeName) async {
    await pumpStep(tester, theme, OnboardingStep.demo, withLectures: true);
    await pumpFor(tester, _kSettle);
    await expectScreenGolden(
      tester,
      screen: 'onboarding',
      name: 'demo',
      themeName: themeName,
    );
  });

  goldenTest('onboarding demo after a wrong and a right pick', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpStep(tester, theme, OnboardingStep.demo, withLectures: true);
    await pumpFor(tester, _kSettle);
    final lecture = goldenLectures.firstWhere(
      (l) => find.text("Let's talk about ${l.title}").evaluate().isNotEmpty,
    );
    final right = lecture.usages.first;
    final wrong = find.byWidgetPredicate(
      (widget) =>
          widget is Text &&
          widget.data != right &&
          (goldenLectures.any((l) => l.usages.contains(widget.data))),
    );
    await tester.tap(wrong.first);
    await pumpFor(tester, const Duration(milliseconds: 600));
    await expectScreenGolden(
      tester,
      screen: 'onboarding',
      name: 'demo_wrong',
      themeName: themeName,
    );
    await tester.tap(find.text(right));
    await pumpFor(tester, _kSettle);
    await expectScreenGolden(
      tester,
      screen: 'onboarding',
      name: 'demo_answered',
      themeName: themeName,
    );
  });
}
