import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hikou/core/application/lecture_provider.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/extensions.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/core/presentation/widgets/lecture_card.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:swipe_cards/swipe_cards.dart';

class InReview extends StatefulHookConsumerWidget {
  const InReview(this.reviewOption, {super.key});
  final ReviewOptions reviewOption;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _InReviewState();
}

class _InReviewState extends ConsumerState<InReview> {
  late final List<Lecture> lectures;
  late final MatchEngine matchEngine;

  @override
  void initState() {
    lectures = ref
        .read(lectureProvider.notifier)
        .getLecturesForReviewOption(widget.reviewOption);
    matchEngine = MatchEngine(
        swipeItems: lectures
            .map((e) => SwipeItem(
                  content: LectureCard(e),
                ))
            .toList());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.inversePrimary,
        title: Text(
          key: K.getInReviewAppTitleForReviewOption(widget.reviewOption),
          widget.reviewOption.getLocalizedTitle(context),
          style: context.textTheme.headlineSmall,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: SwipeCards(
              matchEngine: matchEngine,
              itemBuilder: (BuildContext context, int index) => LectureCard(
                lectures[index],
              ),
              onStackFinished: () {},
              itemChanged: (SwipeItem item, int index) {},
              upSwipeAllowed: false,
              fillSpace: false,
            ),
          ),
        ],
      ),
    );
  }
}
