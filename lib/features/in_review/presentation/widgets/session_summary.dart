import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/in_review/domain/session_recap.dart';
import 'package:japanana/features/in_review/presentation/widgets/review_widgets.dart';

/// End of a session: stats, the mistakes to jump back to and sharing.
class SessionSummaryView extends StatelessWidget {
  const SessionSummaryView({
    required this.recap,
    required this.onJump,
    required this.onShare,
    required this.onDone,
    super.key,
  });

  final SessionRecap recap;
  final ValueChanged<String> onJump;
  final VoidCallback onShare;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final neo = context.neo;
    TextStyle bold(double size, {Color? color}) => TextStyle(
      fontFamily: kReviewFont,
      fontWeight: FontWeight.bold,
      fontSize: size,
      color: color ?? neo.onCard,
    );
    Widget stat(String label, String value) => Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: neo.decoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: bold(
                11,
                color: neo.onCard.withValues(alpha: 0.7),
              ).copyWith(letterSpacing: 0.8),
            ),
            const SizedBox(height: 2),
            FittedBox(child: Text(value, style: bold(28))),
          ],
        ),
      ),
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: ReviewReveal(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.congratsOnFinising(recap.book.getLocalizedTitle(context)),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: neo.onCard,
              ),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                stat(l10n.reviewSummaryCards, '${recap.cards}'),
                stat(l10n.reviewSummaryFirstTry, '${recap.firstTryPercent}%'),
                stat(l10n.reviewSummaryBestCombo, '×${recap.bestCombo}'),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
              decoration: neo.decoration(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.reviewSummaryMistakes, style: bold(17)),
                  const SizedBox(height: 4),
                  if (recap.missed.isEmpty)
                    Text(
                      l10n.reviewSummaryNoMistakes,
                      style: TextStyle(
                        fontFamily: kReviewFont,
                        fontSize: 14,
                        color: neo.onCard.withValues(alpha: 0.75),
                      ),
                    )
                  else ...[
                    Text(
                      l10n.reviewSummaryMistakesHint,
                      style: TextStyle(
                        fontFamily: kReviewFont,
                        fontSize: 13,
                        color: neo.onCard.withValues(alpha: 0.75),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (final lecture in recap.missed)
                          ActionChip(
                            onPressed: () => onJump(lecture.id),
                            backgroundColor: neo.wrongFill,
                            side: BorderSide(color: neo.border, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(999),
                            ),
                            avatar: Icon(
                              Icons.arrow_upward,
                              size: 16,
                              color: neo.onFeedback,
                            ),
                            label: Text(
                              lecture.title,
                              style: bold(14, color: neo.onFeedback),
                            ),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: NeoButton(
                onPressed: onShare,
                minHeight: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.ios_share, color: neo.onCard),
                    const SizedBox(width: 10),
                    Text(
                      l10n.reviewShareRecap.toUpperCase(),
                      style: const TextStyle(
                        fontFamily: kReviewFont,
                        fontSize: 16,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.only(right: 5),
              child: NeoButton(
                key: K.startNextReviewButton,
                onPressed: onDone,
                minHeight: 68,
                color: neo.accent,
                foregroundColor: neo.onAccent,
                shadowColor: neo.accentShadow,
                child: Text(
                  l10n.startNextReview.toUpperCase(),
                  style: const TextStyle(
                    fontFamily: kReviewFont,
                    fontSize: 16,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
