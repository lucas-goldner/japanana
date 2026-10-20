import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/statistics_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/presentation/widgets/transition/bars_animation_transition.dart';

class Statistics extends HookConsumerWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final mistakes = ref.watch(statisticsProvider);
    final allLectures = ref.read(lectureProvider);
    final showOpenAnimation = useState(true);
    final showCloseAnimation = useState(false);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        // Show close animation before popping
        showCloseAnimation.value = true;
      },
      child: Stack(
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
            body: mistakes.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 104,
                            height: 104,
                            decoration: context.neo.decoration(
                              color: context.neo.accent,
                              shadowColor: context.neo.accentShadow,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.trending_up,
                              size: 56,
                              color: context.neo.onAccent,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            l10n.noMistakesYet,
                            style: context.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
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

                      return Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        decoration: context.neo.decoration(),
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
                                '${l10n.lastMistake} '
                                    '${_formatDate(mistake.lastMistakeDate)}',
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
                                  color: _getMistakeColor(
                                    mistake.mistakeCount,
                                    context,
                                  ),
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
          if (showOpenAnimation.value)
            Positioned.fill(
              child: BarsAnimationTransition.open(
                onAnimationComplete: () {
                  showOpenAnimation.value = false;
                },
              ),
            ),
          if (showCloseAnimation.value)
            Positioned.fill(
              child: BarsAnimationTransition.close(
                onAnimationComplete: () {
                  if (context.mounted) {
                    Navigator.of(context)
                        .pop(true); // true indicates we need open animation
                  }
                },
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} '
          'ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} '
          'ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} '
          'minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  Color _getMistakeColor(int mistakeCount, BuildContext context) {
    if (mistakeCount == 1) {
      return context.neo.accent;
    } else if (mistakeCount <= 3) {
      return const Color(0xffFFA94D);
    } else {
      return context.neo.wrongFill;
    }
  }
}
