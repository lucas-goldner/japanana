import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';

class Statistics extends HookConsumerWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mistakes = ref.watch(statisticsProvider);
    final allLectures = ref.read(lectureProvider);

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
            backgroundColor: context.colorScheme.secondary,
            surfaceTintColor: context.colorScheme.secondary,
            elevation: 4,
          ),
          body: mistakes.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.trending_up,
                          size: 64,
                          color: context.colorScheme.primary
                              .withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.noMistakesYet,
                          style: context.textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.keepPracticing,
                          style: context.textTheme.bodyLarge?.copyWith(
                            color: context.colorScheme.onSurface
                                .withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mistakes.length,
                  itemBuilder: (context, index) {
                    final mistake = mistakes[index];
                    final lecture = allLectures.firstWhere(
                      (l) => l.id == mistake.lectureId,
                      orElse: () => allLectures.first,
                    );

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          lecture.title,
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
                              '${l10n.lastMistake} ${_formatDate(mistake.lastMistakeDate)}',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: context.colorScheme.onSurface
                                    .withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                        trailing: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _getMistakeColor(mistake.mistakeCount, context),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${mistake.mistakeCount}',
                            style: context.textTheme.labelMedium?.copyWith(
                              color: Colors.white,
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getMistakeColor(int mistakeCount, BuildContext context) {
    if (mistakeCount == 1) {
      return Colors.orange;
    } else if (mistakeCount <= 3) {
      return Colors.deepOrange;
    } else {
      return Colors.red;
    }
  }
}
