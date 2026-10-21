import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/onboarding/domain/demo_result.dart';
import 'package:japanana/features/onboarding/presentation/steps/demo_step.dart';
import 'package:japanana/features/onboarding/presentation/steps/question_steps.dart';
import 'package:japanana/features/onboarding/presentation/steps/result_steps.dart';
import 'package:japanana/features/onboarding/presentation/steps/setup_steps.dart';
import 'package:japanana/features/onboarding/presentation/steps/story_steps.dart';
import 'package:japanana/features/onboarding/presentation/widgets/onboarding_widgets.dart';

const _kStepTransitionDuration = Duration(milliseconds: 650);
const _kStepSlideDistance = 60.0;
const _kStepBlur = 6.0;
const _kProgressDuration = Duration(milliseconds: 600);

/// Steps of the onboarding, in order.
enum OnboardingStep {
  hook(0, StepTint.banana, showChrome: false),
  goal(0.06, StepTint.paper),
  level(0.12, StepTint.paper),
  years(0.18, StepTint.paper),
  gap(0.25, StepTint.blush),
  pains(0.32, StepTint.paper),
  math(0.4, StepTint.cream),
  fix(0.47, StepTint.paper),
  compare(0.53, StepTint.paper),
  proof(0.6, StepTint.paper),
  rhythm(0.67, StepTint.mint),
  reminder(0.73, StepTint.paper, alwaysDark: true),
  building(0.8, StepTint.paper, canGoBack: false),
  demo(0.86, StepTint.paper, canGoBack: false),
  snapshot(0.91, StepTint.banana, canGoBack: false),
  plan(0.96, StepTint.paper, canGoBack: false),
  paywall(1, StepTint.paper, showChrome: false);

  const OnboardingStep(
    this.progress,
    this.tint, {
    this.showChrome = true,
    this.canGoBack = true,
    this.alwaysDark = false,
  });

  /// Fill of the progress bar while this step shows.
  final double progress;
  final StepTint tint;

  /// Whether the progress bar and back button show.
  final bool showChrome;
  final bool canGoBack;

  /// Night themed even in light mode, like the evening reminder.
  final bool alwaysDark;
}

/// High converting onboarding: questions, a personal plan, a first real
/// conversation and the supporter offer.
class OnboardingScreen extends HookConsumerWidget {
  const OnboardingScreen({
    this.initialStep = OnboardingStep.hook,
    this.initialDemoResult,
    this.onFinished,
    super.key,
  });

  /// Lets golden tests start at any step.
  final OnboardingStep initialStep;
  final DemoResult? initialDemoResult;

  /// Called after the onboarding completed. Defaults to the home screen.
  final VoidCallback? onFinished;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final step = useState(initialStep);
    final forward = useState(true);
    final demoResult = useState(initialDemoResult);
    final current = step.value;

    void goTo(OnboardingStep next) {
      forward.value = next.index > current.index;
      step.value = next;
    }

    void next() {
      if (current.index + 1 < OnboardingStep.values.length) {
        goTo(OnboardingStep.values[current.index + 1]);
      }
    }

    final canGoBack = current.canGoBack && current.index > 0;
    void back() {
      if (canGoBack) goTo(OnboardingStep.values[current.index - 1]);
    }

    Future<void> finish() async {
      await ref.read(onboardingProvider.notifier).complete();
      if (onFinished != null) {
        onFinished!();
      } else if (context.mounted) {
        context.go(AppRoutes.reviewSelection.path);
      }
    }

    final stepWidget = switch (current) {
      OnboardingStep.hook => HookStep(onNext: next),
      OnboardingStep.goal => GoalStep(onNext: next),
      OnboardingStep.level => LevelStep(onNext: next),
      OnboardingStep.years => YearsStep(onNext: next),
      OnboardingStep.gap => GapStep(onNext: next),
      OnboardingStep.pains => PainsStep(onNext: next),
      OnboardingStep.math => MathStep(onNext: next),
      OnboardingStep.fix => FixStep(onNext: next),
      OnboardingStep.compare => CompareStep(onNext: next),
      OnboardingStep.proof => ProofStep(onNext: next),
      OnboardingStep.rhythm => RhythmStep(onNext: next),
      OnboardingStep.reminder => ReminderStep(onNext: next),
      OnboardingStep.building => BuildingStep(onNext: next),
      OnboardingStep.demo => DemoStep(
        onFinished: (result) {
          demoResult.value = result;
          next();
        },
      ),
      OnboardingStep.snapshot => SnapshotStep(
        result: demoResult.value,
        onNext: next,
      ),
      OnboardingStep.plan => PlanStep(onNext: next),
      OnboardingStep.paywall => PaywallStep(onFinished: finish),
    };

    final baseTheme = Theme.of(context);
    ThemeData themeOf(OnboardingStep step) =>
        step.alwaysDark && baseTheme.brightness == Brightness.light
        ? darkTheme
        : baseTheme;
    final stepTheme = themeOf(current);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
      },
      child: AnnotatedRegion<SystemUiOverlayStyle>(
        value: stepTheme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark,
        child: Scaffold(
          body: Stack(
            children: [
              AnimatedSwitcher(
                duration: _kStepTransitionDuration,
                layoutBuilder: (currentChild, previousChildren) => Stack(
                  fit: StackFit.expand,
                  children: [...previousChildren, ?currentChild],
                ),
                transitionBuilder: (child, animation) => _StepTransition(
                  animation: animation,
                  incoming: child.key == ValueKey(current),
                  forward: forward.value,
                  child: child,
                ),
                child: Theme(
                  key: ValueKey(current),
                  data: stepTheme,
                  child: Builder(
                    builder: (context) => StepBackdrop(
                      tint: current.tint,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: context.neo.onCard),
                        child: stepWidget,
                      ),
                    ),
                  ),
                ),
              ),
              AnimatedTheme(
                data: stepTheme,
                child: _Chrome(
                  progress: current.progress,
                  visible: current.showChrome,
                  canGoBack: canGoBack,
                  onBack: back,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Fades, slides and blurs steps in and out like the motion prototype.
class _StepTransition extends StatelessWidget {
  const _StepTransition({
    required this.animation,
    required this.incoming,
    required this.forward,
    required this.child,
  });

  final Animation<double> animation;
  final bool incoming;
  final bool forward;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) {
      final progress = (incoming ? Curves.easeOutCubic : Curves.easeInCubic)
          .transform(animation.value);
      final remaining = 1 - progress;
      final direction = forward ? 1 : -1;
      final dx = (incoming ? 1 : -1) * direction * _kStepSlideDistance;
      final sigma = remaining * _kStepBlur;
      return IgnorePointer(
        ignoring: !incoming,
        child: Opacity(
          opacity: progress,
          child: Transform.translate(
            offset: Offset(dx * remaining, 0),
            child: Transform.scale(
              scale: incoming ? 1 : 1 - remaining * 0.03,
              // Always in the tree so the step keeps its state.
              child: ImageFiltered(
                enabled: sigma > 0.05,
                imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
                child: child,
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _Chrome extends StatelessWidget {
  const _Chrome({
    required this.progress,
    required this.visible,
    required this.canGoBack,
    required this.onBack,
  });

  final double progress;
  final bool visible;
  final bool canGoBack;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return SafeArea(
      child: IgnorePointer(
        ignoring: !visible,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: visible ? 1 : 0,
          child: SizedBox(
            height: kOnboardingChromeHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: canGoBack ? 1 : 0,
                    child: IconButton(
                      onPressed: canGoBack ? onBack : null,
                      icon: Icon(Icons.arrow_back, color: neo.onCard),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Container(
                      height: 14,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: neo.card,
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: neo.border, width: 2.5),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: _kProgressDuration,
                        curve: Curves.easeOutCubic,
                        builder: (context, value, _) => FractionallySizedBox(
                          alignment: Alignment.centerLeft,
                          widthFactor: value,
                          child: Container(color: neo.accent),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
