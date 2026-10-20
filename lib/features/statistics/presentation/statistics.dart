import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/presentation/widgets/transition/bars_animation_transition.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/statistics/application/study_stats_provider.dart';
import 'package:japanana/features/statistics/presentation/recent_mistakes_screen.dart';
import 'package:japanana/features/statistics/presentation/statistics_dashboard.dart';

class Statistics extends HookConsumerWidget {
  const Statistics({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(studyStatsProvider);
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
          StatisticsDashboard(
            stats: stats,
            now: ref.watch(clockProvider)(),
            onSeeAllMistakes: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RecentMistakesScreen(),
              ),
            ),
            onReviewWeakSpots: stats.recentMistakes.isEmpty
                ? null
                : () => context.push(
                      AppRoutes.reviewSetup.path,
                      extra: LectureType.recentMistakes,
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
}
