import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/features/statistics/presentation/widgets/relative_time.dart';

/// Every lecture with a mistake, most recent first.
class RecentMistakesScreen extends ConsumerWidget {
  const RecentMistakesScreen({super.key});

  Color _countColor(BuildContext context, int mistakeCount) =>
      switch (mistakeCount) {
        1 => context.neo.accent,
        <= 3 => const Color(0xffFFA94D),
        _ => context.neo.wrongFill,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final now = ref.watch(clockProvider)();
    final lecturesById = {
      for (final lecture in ref.watch(lectureProvider)) lecture.id: lecture,
    };
    // Mistakes of lectures that no longer exist in the data are skipped.
    final mistakes = [
      for (final mistake in ref.watch(statisticsProvider))
        if (lecturesById[mistake.lectureId] case final lecture?)
          (mistake: mistake, title: lecture.title),
    ];

    return Stack(
      children: [
        const NoteBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(
              l10n.recentMistakes,
              style: context.textTheme.headlineSmall,
            ),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 20, 22, 32),
            itemCount: mistakes.length,
            itemBuilder: (context, index) {
              final (:mistake, :title) = mistakes[index];
              final lastMistake =
                  relativeTime(context, mistake.lastMistakeDate, now);
              return Container(
                margin: const EdgeInsets.only(bottom: 20),
                decoration: context.neo.decoration(),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    title,
                    style: context.textTheme.titleMedium?.copyWith(
                      fontFamily: context.textTheme.notoSansJPFont,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.mistakes} ${mistake.mistakeCount}',
                        style: context.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${l10n.lastMistake} $lastMistake',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: context.colorScheme.onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: context.neo
                        .decoration(
                          color: _countColor(context, mistake.mistakeCount),
                          borderRadius: BorderRadius.circular(999),
                        )
                        .copyWith(
                          boxShadow: [
                            BoxShadow(
                              color: context.neo.shadow,
                              offset: const Offset(2, 2),
                            ),
                          ],
                        ),
                    child: Text(
                      '${mistake.mistakeCount}',
                      style: context.textTheme.titleMedium?.copyWith(
                        color: context.neo.onFeedback,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
