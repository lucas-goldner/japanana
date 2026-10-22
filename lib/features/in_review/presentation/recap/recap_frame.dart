import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/features/in_review/domain/session_recap.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';
import 'package:japanana/features/onboarding/presentation/widgets/motion.dart';

/// Size the recap is laid out at; the video renders it at twice this.
const kRecapSize = Size(360, 640);

/// Length of the recap video.
const kRecapDuration = Duration(seconds: 10);

const _kSceneFade = 0.35;

/// One frame of the recap video at [progress] from 0 to 1. Pure function of
/// its inputs so every frame can be rendered on demand.
class RecapFrame extends StatelessWidget {
  const RecapFrame({required this.recap, required this.progress, super.key});

  final SessionRecap recap;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final t = progress * kRecapDuration.inMilliseconds / 1000;
    final neo = context.neo;
    final dark = context.theme.brightness == Brightness.dark;
    final highlights = recap.highlights();
    final highlightsEnd = 4.6 + max(1, highlights.length) * 1.35;

    double scene(double start, double end) {
      final fadeIn = start <= 0
          ? 1.0
          : ((t - start) / _kSceneFade).clamp(0.0, 1.0);
      final fadeOut = ((end - t) / _kSceneFade).clamp(0.0, 1.0);
      return min(fadeIn, fadeOut);
    }

    return SizedBox.fromSize(
      size: kRecapSize,
      child: ClipRect(
        child: CustomPaint(
          painter: GridPaperPainter(
            backgroundColor: dark
                ? context.colorScheme.surface
                : const Color(0xffF8D318),
            lineColor: neo.grid,
          ),
          child: DefaultTextStyle(
            style: TextStyle(
              fontFamily: kReviewFont,
              fontWeight: FontWeight.bold,
              color: neo.onCard,
            ),
            child: Stack(
              children: [
                _Scene(
                  opacity: scene(0, 2.4),
                  child: _TitleScene(recap: recap, t: t),
                ),
                _Scene(
                  opacity: scene(2.2, 4.8),
                  child: _StatsScene(recap: recap, t: t - 2.2),
                ),
                _Scene(
                  opacity: scene(4.6, highlightsEnd),
                  child: _HighlightsScene(recap: recap, t: t - 4.6),
                ),
                _Scene(
                  opacity: scene(highlightsEnd - 0.2, 99),
                  child: _EndScene(t: t - highlightsEnd + 0.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Scene extends StatelessWidget {
  const _Scene({required this.opacity, required this.child});

  final double opacity;
  final Widget child;

  @override
  Widget build(BuildContext context) => opacity <= 0
      ? const SizedBox.shrink()
      : Positioned.fill(
          child: Opacity(
            opacity: opacity,
            child: Padding(padding: const EdgeInsets.all(28), child: child),
          ),
        );
}

/// Progress of an animation starting at [start] seconds and lasting
/// [duration], with [curve].
double _p(
  double t,
  double start,
  double duration, [
  Curve curve = Curves.easeOutCubic,
]) => curve.transform(((t - start) / duration).clamp(0.0, 1.0));

class _Logo extends StatelessWidget {
  const _Logo({this.size = 72});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: context.neo.decoration(
      color: context.neo.card,
      borderRadius: BorderRadius.circular(size * 0.25),
    ),
    child: Text('🍌', style: TextStyle(fontSize: size * 0.55)),
  );
}

class _TitleScene extends StatelessWidget {
  const _TitleScene({required this.recap, required this.t});

  final SessionRecap recap;
  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final locale = Localizations.localeOf(context).toString();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RevealTransform(
          progress: _p(t, 0.1, 0.5, Curves.easeOutBack),
          offset: Offset.zero,
          scale: 0.5,
          blur: 0,
          child: const _Logo(),
        ),
        const SizedBox(height: 26),
        RevealTransform(
          progress: _p(t, 0.3, 0.6),
          blur: 10,
          child: Text(
            l10n.recapTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Exlibris',
              fontFamilyFallback: const [kReviewFont],
              fontSize: 40,
              height: 1.1,
              color: neo.onCard,
            ),
          ),
        ),
        const SizedBox(height: 18),
        RevealTransform(
          progress: _p(t, 0.6, 0.6),
          child: Column(
            children: [
              ReviewPill(
                label: recap.book.getLocalizedTitle(context),
                color: context.inkFill,
                foregroundColor: context.onInkFill,
              ),
              const SizedBox(height: 10),
              Text(
                DateFormat.yMMMMd(locale).format(recap.date),
                style: TextStyle(
                  fontSize: 15,
                  color: neo.onCard.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsScene extends StatelessWidget {
  const _StatsScene({required this.recap, required this.t});

  final SessionRecap recap;
  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final roll = _p(t, 0.3, 1.2, Curves.easeInOutCubic);
    final stats = [
      (l10n.reviewSummaryCards, '${(recap.cards * roll).round()}'),
      (
        l10n.reviewSummaryFirstTry,
        '${(recap.firstTryPercent * roll).round()}%',
      ),
      (l10n.reviewSummaryBestCombo, '×${(recap.bestCombo * roll).round()}'),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final (index, (label, value)) in stats.indexed)
          Padding(
            padding: const EdgeInsets.only(bottom: 22, right: 5),
            child: RevealTransform(
              progress: _p(t, 0.1 + index * 0.2, 0.5),
              offset: const Offset(60, 0),
              blur: 6,
              child: Container(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
                decoration: neo.decoration(
                  color: index == 1 ? neo.accent : neo.card,
                  shadowColor: index == 1 ? neo.accentShadow : neo.shadow,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: (index == 1 ? neo.onAccent : neo.onCard)
                            .withValues(alpha: 0.75),
                      ),
                    ),
                    Text(
                      value,
                      style: TextStyle(
                        fontSize: 54,
                        height: 1.15,
                        color: index == 1 ? neo.onAccent : neo.onCard,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _HighlightsScene extends StatelessWidget {
  const _HighlightsScene({required this.recap, required this.t});

  final SessionRecap recap;
  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final highlights = recap.highlights();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        RevealTransform(
          progress: _p(t, 0, 0.5),
          child: Text(
            l10n.recapHighlights,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Exlibris',
              fontFamilyFallback: const [kReviewFont],
              fontSize: 32,
              color: neo.onCard,
            ),
          ),
        ),
        const SizedBox(height: 30),
        Expanded(
          child: Stack(
            children: [
              for (final (index, lecture) in highlights.indexed)
                Builder(
                  builder: (context) {
                    final start = 0.2 + index * 1.35;
                    final enter = _p(t, start, 0.45);
                    final last = index == highlights.length - 1;
                    final leave = last
                        ? 0.0
                        : _p(t, start + 1.2, 0.35, Curves.easeInCubic);
                    if (enter == 0 || leave == 1) {
                      return const SizedBox.shrink();
                    }
                    return Transform.translate(
                      offset: Offset(260 * (1 - enter) - 260 * leave, 0),
                      child: Transform.rotate(
                        angle: (1 - enter) * 0.12 - leave * 0.12,
                        child: Opacity(
                          opacity: min(enter, 1 - leave),
                          child: Container(
                            margin: const EdgeInsets.only(right: 5),
                            padding: const EdgeInsets.all(22),
                            decoration: neo.decoration(),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  lecture.title,
                                  style: const TextStyle(
                                    fontSize: 36,
                                    height: 1.2,
                                  ),
                                ),
                                Container(
                                  height: 3,
                                  margin: const EdgeInsets.symmetric(
                                    vertical: 14,
                                  ),
                                  color: neo.border,
                                ),
                                Text(
                                  lecture.examples.first,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    height: 1.4,
                                  ),
                                ),
                                if (lecture.translations.isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    lecture.translations.first,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      color: neo.onCard.withValues(alpha: 0.75),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EndScene extends StatelessWidget {
  const _EndScene({required this.t});

  final double t;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        RevealTransform(
          progress: _p(t, 0.1, 0.5, Curves.easeOutBack),
          offset: Offset.zero,
          scale: 0.5,
          blur: 0,
          child: const _Logo(size: 96),
        ),
        const SizedBox(height: 22),
        RevealTransform(
          progress: _p(t, 0.35, 0.5),
          blur: 10,
          child: Text(
            'Japanana',
            style: TextStyle(
              fontFamily: 'Exlibris',
              fontSize: 46,
              color: neo.onCard,
            ),
          ),
        ),
        const SizedBox(height: 8),
        RevealTransform(
          progress: _p(t, 0.6, 0.5),
          child: Text(
            l10n.recapTagline,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 17),
          ),
        ),
      ],
    );
  }
}
