import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/features/statistics/domain/study_stats.dart';

const _kHeatmapCell = 16.0;
const _kHeatmapGap = 4.0;
const _kBarChartHeight = 150.0;
const _kLineChartHeight = 150.0;

TextStyle _axisStyle(BuildContext context) => TextStyle(
      color: context.neo.onCard.withValues(alpha: 0.7),
      fontFamily: context.textTheme.notoSansJPFont,
      fontSize: 11,
    );

/// GitHub style calendar: one square per day, one column per week, filled
/// darker the more cards were reviewed.
class ActivityHeatmap extends StatelessWidget {
  const ActivityHeatmap({required this.days, super.key});

  /// Oldest first, ending today.
  final List<DayActivity> days;

  static Color levelColor(BuildContext context, int level) {
    final neo = context.neo;
    return switch (level) {
      0 => neo.card,
      1 => Color.lerp(neo.card, neo.accent, 0.35)!,
      2 => Color.lerp(neo.card, neo.accent, 0.7)!,
      3 => neo.accent,
      _ => context.colorScheme.tertiary,
    };
  }

  static int levelOf(int cards) => switch (cards) {
        0 => 0,
        < 10 => 1,
        < 20 => 2,
        < 35 => 3,
        _ => 4,
      };

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    // Pad the start so every column is a full Monday to Sunday week.
    final leading = days.first.day.weekday - DateTime.monday;
    final cells = <DayActivity?>[...List.filled(leading, null), ...days];
    final weeks = (cells.length / 7).ceil();
    final locale = Localizations.localeOf(context).toLanguageTag();
    final weekdayNames = [
      for (var i = 0; i < 7; i++)
        MaterialLocalizations.of(context).narrowWeekdays[(i + 1) % 7],
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            for (final (index, name) in weekdayNames.indexed)
              SizedBox(
                height: _kHeatmapCell + _kHeatmapGap,
                width: 18,
                child: index.isEven
                    ? Text(name, style: _axisStyle(context))
                    : null,
              ),
          ],
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final visibleWeeks = math.min(
                weeks,
                (constraints.maxWidth / (_kHeatmapCell + _kHeatmapGap))
                    .floor(),
              );
              final firstWeek = weeks - visibleWeeks;
              return Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  for (var week = firstWeek; week < weeks; week++)
                    Padding(
                      padding: const EdgeInsets.only(right: _kHeatmapGap),
                      child: Column(
                        children: [
                          for (var weekday = 0; weekday < 7; weekday++)
                            _HeatmapCell(
                              activity: week * 7 + weekday < cells.length
                                  ? cells[week * 7 + weekday]
                                  : null,
                              locale: locale,
                              border: neo.border,
                            ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _HeatmapCell extends StatelessWidget {
  const _HeatmapCell({
    required this.activity,
    required this.locale,
    required this.border,
  });

  final DayActivity? activity;
  final String locale;
  final Color border;

  @override
  Widget build(BuildContext context) => Container(
        width: _kHeatmapCell,
        height: _kHeatmapCell,
        margin: const EdgeInsets.only(bottom: _kHeatmapGap),
        decoration: activity == null
            ? null
            : BoxDecoration(
                color: ActivityHeatmap.levelColor(
                  context,
                  ActivityHeatmap.levelOf(activity!.total),
                ),
                border: Border.all(color: border, width: 1.5),
                borderRadius: BorderRadius.circular(3),
              ),
      );
}

/// Legend from "less" to "more" for [ActivityHeatmap].
class HeatmapLegend extends StatelessWidget {
  const HeatmapLegend({super.key});

  @override
  Widget build(BuildContext context) => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(context.l10n.statsLess, style: _axisStyle(context)),
          const SizedBox(width: 6),
          for (var level = 0; level <= 4; level++)
            Container(
              width: 12,
              height: 12,
              margin: const EdgeInsets.only(right: 3),
              decoration: BoxDecoration(
                color: ActivityHeatmap.levelColor(context, level),
                border: Border.all(color: context.neo.border, width: 1.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          const SizedBox(width: 3),
          Text(context.l10n.statsMore, style: _axisStyle(context)),
        ],
      );
}

/// Stacked bars of correct and wrong answers per day.
class CardsPerDayChart extends StatelessWidget {
  const CardsPerDayChart({required this.days, super.key});

  final List<DayActivity> days;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final maxTotal = days.map((day) => day.total).fold(1, math.max);
    final locale = Localizations.localeOf(context).toLanguageTag();
    final dense = days.length > 10;

    String label(DayActivity day) => dense
        ? '${day.day.day}'
        : MaterialLocalizations.of(context)
            .narrowWeekdays[day.day.weekday % 7];

    return Column(
      children: [
        SizedBox(
          height: _kBarChartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final day in days)
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: dense ? 1 : 5),
                    child: _StackedBar(
                      correct: day.correct / maxTotal,
                      wrong: day.wrong / maxTotal,
                      thin: dense,
                    ),
                  ),
                ),
            ],
          ),
        ),
        Container(height: neo.borderWidth, color: neo.border),
        const SizedBox(height: 6),
        Row(
          children: [
            for (final (index, day) in days.indexed)
              Expanded(
                child: Text(
                  // Every 5th day, counted back from today.
                  !dense || (days.length - 1 - index) % 5 == 0
                      ? label(day)
                      : '',
                  textAlign: TextAlign.center,
                  style: _axisStyle(context),
                  maxLines: 1,
                  overflow: TextOverflow.visible,
                  softWrap: false,
                  key: ValueKey('$locale-$index'),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StackedBar extends StatelessWidget {
  const _StackedBar({
    required this.correct,
    required this.wrong,
    required this.thin,
  });

  /// Heights as a share of the tallest bar.
  final double correct;
  final double wrong;
  final bool thin;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    if (correct + wrong == 0) return const SizedBox.shrink();
    final borderWidth = thin ? 1.5 : 2.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final height = constraints.maxHeight;
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              height: height * (correct + wrong),
              decoration: BoxDecoration(
                border: Border.all(color: neo.border, width: borderWidth),
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(thin ? 2 : 4)),
              ),
              child: ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(thin ? 1 : 2)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: (wrong * 1000).round(),
                      child: ColoredBox(color: neo.wrongFill),
                    ),
                    Expanded(
                      flex: (correct * 1000).round(),
                      child: ColoredBox(color: neo.correctFill),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Line of weekly first try accuracy with square markers.
class AccuracyLineChart extends StatelessWidget {
  const AccuracyLineChart({required this.weeks, super.key});

  /// Oldest first; weeks without answers are null and skipped by the line.
  final List<double?> weeks;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Column(
      children: [
        SizedBox(
          height: _kLineChartHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final percent in ['100%', '50%', '0%'])
                    Text(percent, style: _axisStyle(context)),
                ],
              ),
              const SizedBox(width: 8),
              Expanded(
                child: CustomPaint(
                  painter: _AccuracyLinePainter(
                    weeks: weeks,
                    line: neo.border,
                    marker: neo.accent,
                    grid: neo.border.withValues(alpha: 0.15),
                    fill: neo.accent.withValues(alpha: 0.25),
                    lastMarker: context.colorScheme.tertiary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const SizedBox(width: 40),
            Text(
              context.l10n.statsWeeksAgo(weeks.length - 1),
              style: _axisStyle(context),
            ),
            const Spacer(),
            Text(context.l10n.statsThisWeek, style: _axisStyle(context)),
          ],
        ),
      ],
    );
  }
}

class _AccuracyLinePainter extends CustomPainter {
  _AccuracyLinePainter({
    required this.weeks,
    required this.line,
    required this.marker,
    required this.grid,
    required this.fill,
    required this.lastMarker,
  });

  final List<double?> weeks;
  final Color line;
  final Color marker;
  final Color grid;
  final Color fill;
  final Color lastMarker;

  @override
  void paint(Canvas canvas, Size size) {
    const markerSize = 10.0;
    const inset = markerSize / 2 + 2;
    final gridPaint = Paint()
      ..color = grid
      ..strokeWidth = 1.5;
    for (final share in [0.0, 0.5, 1.0]) {
      final y = inset + (size.height - inset * 2) * (1 - share);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final points = [
      for (final (index, value) in weeks.indexed)
        if (value != null)
          Offset(
            inset + (size.width - inset * 2) * index / (weeks.length - 1),
            inset + (size.height - inset * 2) * (1 - value),
          ),
    ];

    final bottom = size.height - inset;
    final area = Path()..moveTo(points.first.dx, bottom);
    for (final point in points) {
      area.lineTo(point.dx, point.dy);
    }
    area
      ..lineTo(points.last.dx, bottom)
      ..close();
    canvas
      ..drawPath(area, Paint()..color = fill)
      ..drawPath(
      Path()..addPolygon(points, false),
      Paint()
        ..color = line
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeJoin = StrokeJoin.round,
      );

    for (final (index, point) in points.indexed) {
      final rect = Rect.fromCenter(
        center: point,
        width: markerSize,
        height: markerSize,
      );
      canvas
        ..drawRect(
          rect,
          Paint()..color = index == points.length - 1 ? lastMarker : marker,
        )
        ..drawRect(
          rect,
          Paint()
            ..color = line
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(covariant _AccuracyLinePainter oldDelegate) =>
      oldDelegate.weeks != weeks || oldDelegate.line != line;
}

/// Horizontal bar split into mastered, learning and unseen lectures.
class MasteryBar extends StatelessWidget {
  const MasteryBar({required this.deck, required this.color, super.key});

  final DeckMastery deck;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Container(
      height: 22,
      decoration: BoxDecoration(
        border: Border.all(color: neo.border, width: 2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (deck.mastered > 0)
              Expanded(
                flex: deck.mastered,
                child: ColoredBox(color: color),
              ),
            if (deck.learning > 0)
              Expanded(
                flex: deck.learning,
                child: ColoredBox(color: color.withValues(alpha: 0.45)),
              ),
            if (deck.unseen > 0)
              Expanded(
                flex: deck.unseen,
                child: ColoredBox(color: neo.card),
              ),
          ],
        ),
      ),
    );
  }
}

/// Last answers of a lecture as small squares, green for right and red for
/// wrong.
class AnswerSparkline extends StatelessWidget {
  const AnswerSparkline({required this.answers, super.key});

  final List<bool> answers;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final correct in answers)
          Container(
            width: 9,
            height: correct ? 9 : 16,
            margin: const EdgeInsets.only(right: 2),
            decoration: BoxDecoration(
              color: correct ? neo.correctFill : neo.wrongFill,
              border: Border.all(color: neo.border, width: 1.5),
            ),
          ),
      ],
    );
  }
}
