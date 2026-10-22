import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/in_review/domain/review_question.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_section.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';

const lightningBestKey = 'lightning_best_score';
const _kMismatchHold = Duration(milliseconds: 900);
const _kLightningDuration = Duration(seconds: 30);
const _kLightningPoints = 100;
const _kStampGreen = Color(0xff2E9A4B);

TextStyle _bold(BuildContext context, double size) => TextStyle(
  fontFamily: kReviewFont,
  fontWeight: FontWeight.bold,
  fontSize: size,
  color: context.neo.onCard,
);

TextStyle _muted(BuildContext context, double size) => TextStyle(
  fontFamily: kReviewFont,
  fontSize: size,
  height: 1.4,
  color: context.neo.onCard.withValues(alpha: 0.75),
);

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final Widget value;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: context.neo.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.neo.border, width: 3),
      ),
      child: Column(
        children: [
          Text(
            label.toUpperCase(),
            style: _bold(context, 11).copyWith(
              letterSpacing: 0.8,
              color: context.neo.onCard.withValues(alpha: 0.7),
            ),
          ),
          DefaultTextStyle(style: _bold(context, 22), child: value),
        ],
      ),
    ),
  );
}

class _Stamp extends StatelessWidget {
  const _Stamp({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -0.14,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      decoration: BoxDecoration(
        color: context.neo.card,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kStampGreen, width: 3),
      ),
      child: Text(
        label.toUpperCase(),
        style: _bold(context, 18).copyWith(color: _kStampGreen),
      ),
    ),
  );
}

Widget _primaryButton(BuildContext context, String label, VoidCallback onTap) =>
    NeoButton(
      onPressed: onTap,
      color: context.inkFill,
      foregroundColor: context.onInkFill,
      shadowColor: context.isDark
          ? context.neo.accentShadow
          : context.neo.accent,
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontFamily: kReviewFont,
          fontSize: 16,
          letterSpacing: 1,
        ),
      ),
    );

String _clock(Duration duration) {
  final seconds = (duration.inSeconds % 60).toString().padLeft(2, '0');
  return '${duration.inMinutes}:$seconds';
}

/// Flip two cards at a time to match each grammar point with its usage.
class MemoryBreakView extends HookWidget {
  const MemoryBreakView({
    required this.cards,
    required this.onFinished,
    required this.onGrow,
    super.key,
  });

  final List<MemoryCard> cards;
  final VoidCallback onFinished;
  final VoidCallback onGrow;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    final faceUp = useState<List<int>>([]);
    final matched = useState<Set<String>>({});
    final moves = useState(0);
    final mismatch = useState(false);
    final finished = useState(false);
    final clock = useAnimationController(duration: const Duration(hours: 1));
    final later = useLater();
    final pairCount = cards.length ~/ 2;
    final done = matched.value.length == pairCount;

    useEffect(() {
      clock.forward();
      return null;
    }, const []);

    void tap(int index) {
      if (done || finished.value || faceUp.value.length == 2) return;
      if (faceUp.value.contains(index)) return;
      if (matched.value.contains(cards[index].pairId)) return;
      final up = [...faceUp.value, index];
      faceUp.value = up;
      mismatch.value = false;
      if (up.length < 2) return;
      moves.value++;
      if (cards[up[0]].pairId == cards[up[1]].pairId) {
        matched.value = {...matched.value, cards[up[0]].pairId};
        faceUp.value = [];
        if (matched.value.length == pairCount) {
          clock.stop();
          WidgetsBinding.instance.addPostFrameCallback((_) => onGrow());
        }
      } else {
        mismatch.value = true;
        later(_kMismatchHold, () => faceUp.value = []);
      }
    }

    void finish() {
      if (finished.value) return;
      finished.value = true;
      clock.stop();
      onFinished();
    }

    final elapsed = AnimatedBuilder(
      animation: clock,
      builder: (context, _) =>
          Text(_clock(Duration(seconds: (clock.value * 3600).floor()))),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: BreakKind.memory.label(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.reviewMemorySubtitle,
                textAlign: TextAlign.center,
                style: _muted(context, 15),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _Stat(
                    label: l10n.reviewMemoryMoves,
                    value: Text('${moves.value}'),
                  ),
                  _Stat(label: l10n.reviewMemoryTime, value: elapsed),
                  _Stat(
                    label: l10n.reviewMemoryPairs,
                    value: Text('${matched.value.length}/$pairCount'),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              GridView.count(
                crossAxisCount: 3,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 14,
                crossAxisSpacing: 12,
                childAspectRatio: 0.9,
                padding: const EdgeInsets.only(right: 4, bottom: 4),
                children: [
                  for (final (index, card) in cards.indexed)
                    _MemoryTile(
                      card: card,
                      faceUp: faceUp.value.contains(index),
                      matched: matched.value.contains(card.pairId),
                      wrong: mismatch.value && faceUp.value.contains(index),
                      onTap: () => tap(index),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (done) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.reviewMemoryDone(pairCount, moves.value),
                        style: _bold(context, 16),
                      ),
                    ),
                    if (moves.value == pairCount) ...[
                      const SizedBox(width: 12),
                      _Stamp(label: l10n.reviewPerfect),
                    ],
                  ],
                ),
                if (!finished.value) ...[
                  const SizedBox(height: 16),
                  _primaryButton(context, l10n.reviewContinue, finish),
                ],
              ] else ...[
                if (mismatch.value)
                  Text(
                    l10n.reviewMemoryMismatch,
                    textAlign: TextAlign.center,
                    style: _bold(context, 14).copyWith(
                      color: context.isDark
                          ? neo.wrongFill
                          : context.colorScheme.error,
                    ),
                  ),
                if (!finished.value)
                  TextButton(
                    onPressed: finish,
                    child: Text(l10n.reviewSkip, style: _muted(context, 14)),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MemoryTile extends StatelessWidget {
  const _MemoryTile({
    required this.card,
    required this.faceUp,
    required this.matched,
    required this.wrong,
    required this.onTap,
  });

  final MemoryCard card;
  final bool faceUp;
  final bool matched;
  final bool wrong;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final shown = faceUp || matched;
    final color = matched
        ? neo.correctFill
        : wrong
        ? neo.wrongFill
        : shown
        ? neo.card
        : neo.accent;
    final foreground = matched || wrong ? neo.onFeedback : neo.onCard;
    return GestureDetector(
      onTap: onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: shown ? 1 : 0),
        duration: const Duration(milliseconds: 260),
        builder: (context, flip, _) {
          final showFront = flip >= 0.5;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(pi * flip + (showFront ? pi : 0)),
            child: Opacity(
              opacity: matched ? 0.75 : 1,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      alignment: Alignment.center,
                      decoration: neo.decoration(
                        color: showFront ? color : neo.accent,
                        shadowColor: showFront ? neo.shadow : neo.accentShadow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: showFront
                          ? Text(
                              card.text,
                              textAlign: TextAlign.center,
                              maxLines: card.isTitle ? 3 : 5,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: kReviewFont,
                                fontWeight: FontWeight.bold,
                                fontSize: card.isTitle ? 17 : 11,
                                height: 1.3,
                                color: foreground,
                              ),
                            )
                          : Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: neo.card,
                                shape: BoxShape.circle,
                                border: Border.all(color: neo.border, width: 3),
                              ),
                              child: Text('?', style: _bold(context, 18)),
                            ),
                    ),
                  ),
                  if (matched)
                    const Positioned(top: -10, right: -8, child: RightMarker()),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

enum _LightningPhase { ready, running, done }

/// Thirty seconds of true or false swipes with a growing combo.
class LightningRoundView extends HookConsumerWidget {
  const LightningRoundView({
    required this.statements,
    required this.onFinished,
    required this.onGrow,
    super.key,
  });

  final List<LightningStatement> statements;
  final VoidCallback onFinished;
  final VoidCallback onGrow;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final neo = context.neo;
    final prefs = ref.watch(preferencesProvider);
    final phase = useState(_LightningPhase.ready);
    final index = useState(0);
    final score = useState(0);
    final streak = useState(0);
    final right = useState(0);
    final flash = useState<bool?>(null);
    final best = useState(prefs.getInt(lightningBestKey) ?? 0);
    final newBest = useState(false);
    final finished = useState(false);
    final timer = useAnimationController(duration: _kLightningDuration);

    useEffect(() {
      void listener(AnimationStatus status) {
        if (status != AnimationStatus.completed) return;
        phase.value = _LightningPhase.done;
        if (score.value > best.value) {
          newBest.value = true;
          best.value = score.value;
          prefs.setInt(lightningBestKey, score.value);
        }
        WidgetsBinding.instance.addPostFrameCallback((_) => onGrow());
      }

      timer.addStatusListener(listener);
      return () => timer.removeStatusListener(listener);
    }, const []);

    void answer({required bool fits}) {
      if (phase.value != _LightningPhase.running) return;
      final statement = statements[index.value % statements.length];
      final correct = statement.fits == fits;
      flash.value = correct;
      if (correct) {
        streak.value++;
        right.value++;
        score.value += _kLightningPoints * (1 + min<int>(streak.value ~/ 3, 4));
      } else {
        streak.value = 0;
      }
      index.value++;
    }

    void finish() {
      if (finished.value) return;
      finished.value = true;
      timer.stop();
      onFinished();
    }

    final statement = statements[index.value % statements.length];
    final multiplier = 1 + min<int>(streak.value ~/ 3, 4);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: BreakKind.lightning.label(context)),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: switch (phase.value) {
            _LightningPhase.ready => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.bolt, size: 56, color: neo.onCard),
                Text(
                  l10n.reviewLightningSubtitle,
                  textAlign: TextAlign.center,
                  style: _bold(context, 18),
                ),
                if (best.value > 0) ...[
                  const SizedBox(height: 6),
                  Text(
                    l10n.reviewLightningBest(best.value),
                    textAlign: TextAlign.center,
                    style: _muted(context, 14),
                  ),
                ],
                const SizedBox(height: 20),
                if (!finished.value) ...[
                  _primaryButton(context, l10n.reviewLightningStart, () {
                    phase.value = _LightningPhase.running;
                    timer.forward(from: 0);
                    WidgetsBinding.instance.addPostFrameCallback(
                      (_) => onGrow(),
                    );
                  }),
                  TextButton(
                    onPressed: finish,
                    child: Text(l10n.reviewSkip, style: _muted(context, 14)),
                  ),
                ],
              ],
            ),
            _LightningPhase.running => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    SizedBox.square(
                      dimension: 84,
                      child: AnimatedBuilder(
                        animation: timer,
                        builder: (context, _) => CustomPaint(
                          painter: _TimerPainter(
                            left: 1 - timer.value,
                            card: neo.card,
                            border: neo.border,
                            fill: neo.accent,
                          ),
                          child: Center(
                            child: Text(
                              _clock(
                                _kLightningDuration * (1 - timer.value) +
                                    const Duration(milliseconds: 999),
                              ),
                              style: _bold(context, 16),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          l10n.reviewLightningScore.toUpperCase(),
                          style: _muted(context, 11),
                        ),
                        Text('${score.value}', style: _bold(context, 36)),
                        if (multiplier > 1) ComboMeter(combo: multiplier),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  margin: const EdgeInsets.only(right: 5),
                  padding: const EdgeInsets.all(20),
                  constraints: const BoxConstraints(minHeight: 170),
                  decoration: neo.decoration(
                    color: switch (flash.value) {
                      true => Color.lerp(neo.card, neo.correctFill, 0.35),
                      false => Color.lerp(neo.card, neo.wrongFill, 0.35),
                      null => neo.card,
                    },
                  ),
                  child: Column(
                    key: ValueKey(index.value),
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(statement.title, style: _bold(context, 30)),
                      const SizedBox(height: 10),
                      Text(statement.usage, style: _bold(context, 17)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _LightningButton(
                      icon: Icons.close,
                      color: neo.wrongFill,
                      label: l10n.reviewSwipeNope,
                      onPressed: () => answer(fits: false),
                    ),
                    const SizedBox(width: 44),
                    _LightningButton(
                      icon: Icons.check,
                      color: neo.correctFill,
                      label: l10n.reviewSwipeFits,
                      onPressed: () => answer(fits: true),
                    ),
                  ],
                ),
              ],
            ),
            _LightningPhase.done => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        l10n.reviewLightningResult(right.value, score.value),
                        style: _bold(context, 18),
                      ),
                    ),
                    if (newBest.value) ...[
                      const SizedBox(width: 12),
                      _Stamp(label: l10n.reviewLightningNewBest),
                    ],
                  ],
                ),
                if (!finished.value) ...[
                  const SizedBox(height: 16),
                  _primaryButton(context, l10n.reviewContinue, finish),
                ],
              ],
            ),
          },
        ),
      ],
    );
  }
}

class _LightningButton extends StatelessWidget {
  const _LightningButton({
    required this.icon,
    required this.color,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    child: SizedBox.square(
      dimension: 72,
      child: NeoButton(
        onPressed: onPressed,
        color: color,
        minHeight: 72,
        padding: EdgeInsets.zero,
        child: Icon(icon, size: 32, color: context.neo.onFeedback),
      ),
    ),
  );
}

class _TimerPainter extends CustomPainter {
  _TimerPainter({
    required this.left,
    required this.card,
    required this.border,
    required this.fill,
  });

  final double left;
  final Color card;
  final Color border;
  final Color fill;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2 - 3;
    canvas
      ..drawCircle(center, radius, Paint()..color = card)
      ..drawCircle(
        center,
        radius,
        Paint()
          ..color = border
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4,
      )
      ..drawArc(
        Rect.fromCircle(center: center, radius: radius - 9),
        -pi / 2,
        2 * pi * left,
        false,
        Paint()
          ..color = fill
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
  }

  @override
  bool shouldRepaint(covariant _TimerPainter oldDelegate) =>
      oldDelegate.left != left;
}
