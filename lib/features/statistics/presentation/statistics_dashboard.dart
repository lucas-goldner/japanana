import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/features/statistics/domain/study_stats.dart';
import 'package:japanana/features/statistics/presentation/widgets/neo_charts.dart';
import 'package:japanana/features/statistics/presentation/widgets/relative_time.dart';

const _kRecentMistakesPreview = 3;

/// Overview of the learner's progress: streak, activity, mastery and weak
/// spots, with the recent mistakes as one section among them.
class StatisticsDashboard extends StatelessWidget {
  const StatisticsDashboard({
    required this.stats,
    required this.now,
    this.onSeeAllMistakes,
    this.onReviewWeakSpots,
    super.key,
  });

  final StudyStats stats;

  /// Reference time for "3 hours ago" labels.
  final DateTime now;
  final VoidCallback? onSeeAllMistakes;

  /// Starts a review of the weak spots; the button is hidden when null.
  final VoidCallback? onReviewWeakSpots;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Stack(
      children: [
        const NoteBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.statistics,
              style: context.textTheme.headlineSmall,
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 22, 32),
            children: [
              _StreakCard(stats: stats),
              const SizedBox(height: 20),
              _StatTiles(stats: stats),
              const SizedBox(height: 20),
              _DashboardCard(
                title: l10n.statsActivity,
                child: Column(
                  children: [
                    ActivityHeatmap(days: stats.days),
                    const SizedBox(height: 8),
                    const HeatmapLegend(),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              _CardsPerDayCard(days: stats.days),
              const SizedBox(height: 20),
              _MasteryCard(decks: stats.decks),
              const SizedBox(height: 20),
              _DashboardCard(
                title: l10n.statsAccuracyByWeek,
                child: stats.weeklyAccuracy.nonNulls.length < 2
                    ? const _NotEnoughData()
                    : AccuracyLineChart(weeks: stats.weeklyAccuracy),
              ),
              const SizedBox(height: 32),
              _SectionHeading(l10n.statsWeakSpots),
              const SizedBox(height: 12),
              _MostMissedCard(lectures: stats.weakLectures),
              const SizedBox(height: 20),
              _MixedUpCard(pairs: stats.confusionPairs),
              const SizedBox(height: 20),
              _RecentMistakesCard(
                mistakes: stats.recentMistakes,
                now: now,
                onSeeAll: onSeeAllMistakes,
              ),
              if (onReviewWeakSpots case final onReviewWeakSpots?) ...[
              const SizedBox(height: 24),
              NeoButton(
                onPressed: onReviewWeakSpots,
                color: context.neo.accent,
                foregroundColor: context.neo.onAccent,
                shadowColor: context.neo.accentShadow,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.bolt, color: context.neo.onAccent),
                    const SizedBox(width: 8),
                    Text(
                      l10n.statsReviewWeakSpots.toUpperCase(),
                      style: _textStyle(
                        context,
                        size: 16,
                      ).copyWith(color: context.neo.onAccent, letterSpacing: 1),
                    ),
                  ],
                ),
              ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

TextStyle _textStyle(
  BuildContext context, {
  double size = 14,
  FontWeight weight = FontWeight.bold,
}) => TextStyle(
  color: context.neo.onCard,
  fontFamily: context.textTheme.notoSansJPFont,
  fontSize: size,
  fontWeight: weight,
);

String _percent(BuildContext context, double share) =>
    '${(share * 100).round()}%';

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: context.textTheme.headlineSmall?.copyWith(
      fontWeight: FontWeight.bold,
      color: context.colorScheme.onSecondary,
    ),
  );
}

class _DashboardCard extends StatelessWidget {
  const _DashboardCard({
    required this.title,
    required this.child,
    this.trailing,
  });

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: context.neo.decoration(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: _textStyle(context, size: 16))),
            if (trailing != null) trailing!,
          ],
        ),
        const SizedBox(height: 14),
        child,
      ],
    ),
  );
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.stats});
  final StudyStats stats;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final onAccent = neo.onAccent;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: neo.decoration(
        color: neo.accent,
        shadowColor: neo.accentShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: neo
                .decoration(
                  color: context.colorScheme.tertiary,
                  shape: BoxShape.circle,
                )
                .copyWith(boxShadow: []),
            child: const Icon(
              Icons.local_fire_department,
              color: Colors.white,
              size: 38,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            '${stats.currentStreak}',
            style: _textStyle(
              context,
              size: 48,
            ).copyWith(color: onAccent, height: 1),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.statsDayStreak,
                  style: _textStyle(
                    context,
                    size: 18,
                  ).copyWith(color: onAccent),
                ),
                Text(
                  context.l10n.statsLongestStreak(stats.longestStreak),
                  style: _textStyle(
                    context,
                    size: 13,
                    weight: FontWeight.w500,
                  ).copyWith(color: onAccent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTiles extends StatelessWidget {
  const _StatTiles({required this.stats});
  final StudyStats stats;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final change = stats.cardsChangeThisWeek;
    final accuracy = stats.firstTryAccuracy;

    return Column(
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.style_outlined,
                  value: '${stats.cardsReviewed}',
                  label: l10n.statsCardsReviewed,
                  note: change == null
                      ? null
                      : l10n.statsVsLastWeek(
                          '${change >= 0 ? '+' : '−'}'
                          '${_percent(context, change.abs())}',
                        ),
                  noteIsGood: (change ?? 0) >= 0,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatTile(
                  icon: Icons.ads_click,
                  value: accuracy == null ? '–' : _percent(context, accuracy),
                  label: l10n.statsFirstTryAccuracy,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _StatTile(
                  icon: Icons.timer_outlined,
                  value: '${stats.minutesStudied}',
                  label: l10n.statsMinutesStudied,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _StatTile(
                  icon: Icons.workspace_premium_outlined,
                  value: '${stats.lecturesMastered}',
                  label: l10n.statsLecturesMastered,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.value,
    required this.label,
    this.note,
    this.noteIsGood = true,
  });

  final IconData icon;
  final String value;
  final String label;
  final String? note;
  final bool noteIsGood;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      constraints: const BoxConstraints(minHeight: 124),
      padding: const EdgeInsets.all(14),
      decoration: neo.decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: neo.onCard, size: 22),
          const SizedBox(height: 6),
          Text(value, style: _textStyle(context, size: 30)),
          Text(
            label,
            style: _textStyle(context, size: 12, weight: FontWeight.w500),
          ),
          if (note != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: noteIsGood ? neo.correctFill : neo.wrongFill,
                border: Border.all(color: neo.border, width: 1.5),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                note!,
                style: _textStyle(
                  context,
                  size: 10,
                ).copyWith(color: neo.onFeedback),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CardsPerDayCard extends HookWidget {
  const _CardsPerDayCard({required this.days});
  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final showMonth = useState(false);
    final l10n = context.l10n;
    final shown = days.sublist(days.length - (showMonth.value ? 30 : 7));

    return _DashboardCard(
      title: l10n.statsCardsPerDay,
      trailing: Row(
        children: [
          _RangeChip(
            label: l10n.statsLast7Days,
            selected: !showMonth.value,
            onTap: () => showMonth.value = false,
          ),
          const SizedBox(width: 8),
          _RangeChip(
            label: l10n.statsLast30Days,
            selected: showMonth.value,
            onTap: () => showMonth.value = true,
          ),
        ],
      ),
      child: Column(
        children: [
          if (shown.every((day) => day.total == 0))
            const _NotEnoughData()
          else
            CardsPerDayChart(days: shown),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(
                color: context.neo.correctFill,
                label: l10n.statsCorrect,
              ),
              const SizedBox(width: 16),
              _LegendDot(color: context.neo.wrongFill, label: l10n.statsWrong),
            ],
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          color: selected ? neo.border : neo.card,
          border: Border.all(color: neo.border, width: 2),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: _textStyle(
            context,
            size: 12,
          ).copyWith(color: selected ? neo.card : neo.onCard),
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: context.neo.border, width: 1.5),
        ),
      ),
      const SizedBox(width: 6),
      Text(
        label,
        style: _textStyle(context, size: 12, weight: FontWeight.w500),
      ),
    ],
  );
}

class _MasteryCard extends StatelessWidget {
  const _MasteryCard({required this.decks});
  final List<DeckMastery> decks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final books = context.booksTheme.lectureTypeColors;
    // Each bar uses its book color, so the legend uses the neutral ink.
    final legendColor = context.neo.border;

    return _DashboardCard(
      title: l10n.statsMastery,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final deck in decks) ...[
            Row(
              children: [
                SizedBox(
                  width: 72,
                  child: Text(
                    deck.type.getLocalizedShortTitle(context),
                    style: _textStyle(context, size: 13),
                  ),
                ),
                Expanded(
                  child: MasteryBar(
                    deck: deck,
                    color: books[deck.type]?.primary ?? legendColor,
                  ),
                ),
                SizedBox(
                  width: 52,
                  child: Text(
                    '${deck.mastered}/${deck.total}',
                    textAlign: TextAlign.end,
                    style: _textStyle(context, size: 12),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Wrap(
            spacing: 16,
            children: [
              _LegendDot(color: legendColor, label: l10n.statsMastered),
              _LegendDot(
                color: legendColor.withValues(alpha: 0.45),
                label: l10n.statsLearning,
              ),
              _LegendDot(color: context.neo.card, label: l10n.statsUnseen),
            ],
          ),
        ],
      ),
    );
  }
}

class _MostMissedCard extends StatelessWidget {
  const _MostMissedCard({required this.lectures});
  final List<WeakLecture> lectures;

  @override
  Widget build(BuildContext context) => _DashboardCard(
    title: context.l10n.statsMostMissed,
    child: Column(
      children: [
        if (lectures.isEmpty) const _NotEnoughData(),
        for (final (index, lecture) in lectures.indexed) ...[
          if (index > 0)
            Divider(height: 20, thickness: 1.5, color: context.neo.grid),
          Row(
            children: [
              _RankBadge(rank: index + 1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lecture.title,
                      style: _textStyle(context, size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      context.l10n.statsWrongShare(
                        _percent(context, lecture.errorRate),
                      ),
                      style: _textStyle(
                        context,
                        size: 12,
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              AnswerSparkline(answers: lecture.recentAnswers),
            ],
          ),
        ],
      ],
    ),
  );
}

class _RankBadge extends StatelessWidget {
  const _RankBadge({required this.rank});
  final int rank;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final first = rank == 1;
    return Container(
      width: 30,
      height: 30,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: first ? context.colorScheme.tertiary : neo.card,
        shape: BoxShape.circle,
        border: Border.all(color: neo.border, width: 2),
      ),
      child: Text(
        '$rank',
        style: _textStyle(
          context,
          size: 13,
        ).copyWith(color: first ? Colors.white : neo.onCard),
      ),
    );
  }
}

class _MixedUpCard extends StatelessWidget {
  const _MixedUpCard({required this.pairs});
  final List<ConfusionPair> pairs;

  @override
  Widget build(BuildContext context) => _DashboardCard(
    title: context.l10n.statsMixedUp,
    child: Column(
      children: [
        if (pairs.isEmpty) const _NotEnoughData(),
        for (final (index, pair) in pairs.indexed) ...[
          if (index > 0) const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Flexible(child: _GrammarChip(pair.expected, correct: true)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(
                        Icons.swap_horiz,
                        color: context.neo.onCard,
                        size: 22,
                      ),
                    ),
                    Flexible(child: _GrammarChip(pair.picked, correct: false)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                context.l10n.statsTimes(pair.count),
                style: _textStyle(context, size: 15),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _GrammarChip extends StatelessWidget {
  const _GrammarChip(this.text, {required this.correct});
  final String text;
  final bool correct;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: correct ? neo.correctFill : neo.wrongFill,
        border: Border.all(color: neo.border, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: _textStyle(context, size: 13).copyWith(color: neo.onFeedback),
      ),
    );
  }
}

class _RecentMistakesCard extends StatelessWidget {
  const _RecentMistakesCard({
    required this.mistakes,
    required this.now,
    this.onSeeAll,
  });

  final List<RecentMistake> mistakes;
  final DateTime now;
  final VoidCallback? onSeeAll;

  @override
  Widget build(BuildContext context) => _DashboardCard(
    title: context.l10n.recentMistakes,
    trailing: mistakes.isEmpty ? null : GestureDetector(
      onTap: onSeeAll,
      child: Text(
        '${context.l10n.statsSeeAll} →',
        style: _textStyle(context, size: 13).copyWith(
          decoration: TextDecoration.underline,
          decorationThickness: 2,
        ),
      ),
    ),
    child: Column(
      children: [
        if (mistakes.isEmpty)
          _NotEnoughData(message: context.l10n.noMistakesYet),
        for (final mistake in mistakes.take(_kRecentMistakesPreview))
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  color: context.colorScheme.tertiary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    mistake.title,
                    style: _textStyle(context),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  relativeTime(context, mistake.when, now),
                  style: _textStyle(context, size: 12, weight: FontWeight.w500),
                ),
              ],
            ),
          ),
      ],
    ),
  );
}

/// Placeholder for a chart or list that has nothing to show yet.
class _NotEnoughData extends StatelessWidget {
  const _NotEnoughData({this.message});

  /// Defaults to "Not enough data yet".
  final String? message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.hourglass_empty, color: context.neo.onCard, size: 20),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            message ?? context.l10n.statsNotEnoughData,
            style: _textStyle(context, weight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
