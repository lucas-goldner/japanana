import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/hikou_theme.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:swipe_cards/swipe_cards.dart';

class InReview extends StatefulHookConsumerWidget {
  const InReview(this.reviewOption, {super.key});
  final (ReviewSections, ReviewSetupOptions) reviewOption;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InReviewState();
}

class _InReviewState extends ConsumerState<InReview> {
  List<Lecture> lectures = [];
  late final MatchEngine matchEngine;
  late final ReviewSetupOptions options;

  void _onNope(Lecture lecture) {
    if (options.repeatOnFalseCard) matchEngine..rewindMatch();
  }

  @override
  void initState() {
    options = widget.reviewOption.$2;
    lectures = ref
        .read(lectureProvider.notifier)
        .getLecturesForReviewOption(widget.reviewOption.$1);
    if (options.randomize) lectures.shuffle();
    matchEngine = MatchEngine(
        swipeItems: lectures
            .map(
              (lecture) => SwipeItem(
                content: LectureCard(lecture),
                nopeAction: () => _onNope(lecture),
              ),
            )
            .toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final reviewProgress = useState(0);
    final done = useState(false);
    final linearPercentIndicatorExt =
        context.themeExtension<LinearPercentIndicatorColors>();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.inversePrimary,
        title: Text(
          key: K.getInReviewAppTitleForReviewOption(widget.reviewOption.$1),
          widget.reviewOption.$1.getLocalizedTitle(context),
          style: context.textTheme.headlineSmall,
        ),
      ),
      body: Stack(
        children: [
          Visibility(
            visible: done.value,
            child: Center(
                child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.congratsOnFinising(
                      widget.reviewOption.$1.getLocalizedTitle(context),
                    ),
                    style: context.textTheme.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    key: K.startNextReviewButton,
                    onPressed: () =>
                        context.popUntilPath(AppRoutes.reviewSelection.path),
                    child: Text(
                      context.l10n.startNextReview.toUpperCase(),
                      style: context.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            )),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SwipeCards(
                  key: K.inReviewCardStack,
                  matchEngine: matchEngine,
                  itemBuilder: (BuildContext context, int index) =>
                      LectureCard(lectures[index]),
                  onStackFinished: () => done.value = true,
                  itemChanged: (SwipeItem item, int index) =>
                      reviewProgress.value = index,
                  upSwipeAllowed: false,
                  fillSpace: false,
                ),
              ),
              Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, left: 20, right: 20),
                child: LinearPercentIndicator(
                  key: K.progressIndicator,
                  animation: true,
                  animateFromLastPercent: true,
                  lineHeight: 20.0,
                  animationDuration: 1250,
                  percent: ((reviewProgress.value + 1) / lectures.length),
                  center: Text(
                    key: K.progressIndicatorLabel,
                    "${(reviewProgress.value + 1)} / ${lectures.length}",
                    style: context.textTheme.labelLarge?.copyWith(
                      color: linearPercentIndicatorExt.progressLabelTextColor,
                    ),
                  ),
                  progressColor: linearPercentIndicatorExt.progressColor,
                  backgroundColor: linearPercentIndicatorExt.backgroundColor,
                  barRadius: Radius.circular(4.0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
