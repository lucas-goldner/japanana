import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_progress.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:swipe_cards/swipe_cards.dart';

class InReview extends StatefulWidget {
  const InReview(this.reviewOption, {super.key});
  final (LectureType?, ReviewSetupOptions?)? reviewOption;

  @override
  State<InReview> createState() => _InReviewState();
}

class _InReviewState extends State<InReview> with RestorationMixin {
  final RestorableEnum _restorableLectureType = RestorableEnum<LectureType>(
    LectureType.writing,
    values: LectureType.values,
  );
  final RestorableInt _reviewProgress = RestorableInt(0);

  @override
  String? get restorationId => 'inReview';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableLectureType, 'inReviewLectureType');
    registerForRestoration(_reviewProgress, 'reviewProgressKey');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => reviewSection(widget.reviewOption?.$1),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _restorableLectureType.dispose();
  }

  void reviewSection(LectureType? value) {
    if (value == null) return;
    setState(() {
      _restorableLectureType.value = value;
    });
  }

  LectureType get reviewingLecture =>
      widget.reviewOption?.$1 ?? _restorableLectureType.value as LectureType;

  @override
  Widget build(BuildContext context) => Center(
        child: _InReviewContent(
          reviewOption: (
            reviewingLecture,
            widget.reviewOption?.$2 ??
                const ReviewSetupOptions(
                  randomize: false,
                  repeatOnFalseCard: false,
                )
          ),
          reviewProgress: _reviewProgress,
        ),
      );
}

class _InReviewContent extends StatefulHookConsumerWidget {
  const _InReviewContent({
    required this.reviewOption,
    required this.reviewProgress,
  });
  final (LectureType, ReviewSetupOptions) reviewOption;
  final RestorableInt reviewProgress;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _InReviewContentState();
}

class _InReviewContentState extends ConsumerState<_InReviewContent> {
  late final MatchEngine matchEngine;
  late final ReviewSetupOptions _options;
  List<Lecture> lectures = [];

  void _onNope(lecture) {
    if (_options.repeatOnFalseCard) matchEngine.rewindMatch();
  }

  @override
  void initState() {
    super.initState();
    _options = widget.reviewOption.$2;
    lectures = ref
        .read(lectureProvider.notifier)
        .getLecturesForReviewOption(widget.reviewOption.$1);
    if (_options.randomize) lectures.shuffle();
    matchEngine = MatchEngine(
      swipeItems: lectures
          .map(
            (lecture) => SwipeItem(
              content: LectureCard(lecture),
              nopeAction: () => _onNope(lecture),
            ),
          )
          .toList(),
    );
  }

  void increaseProgress(
    RestorableInt restorableProgress,
    ValueNotifier<int> reviewProgress,
    int newValue,
  ) {
    setState(() {
      restorableProgress.value = newValue;
      reviewProgress.value == newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reviewProgress = useState(0);
    final done = useState(false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.inversePrimary,
        title: Text(
          key: K.getInReviewAppTitleForReviewOption(
            widget.reviewOption.$1,
          ),
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
                    const SizedBox(height: 20),
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
              ),
            ),
          ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: SwipeCards(
                  key: K.inReviewCardStack,
                  matchEngine: matchEngine,
                  itemBuilder: (context, index) =>
                      LectureCard(lectures[widget.reviewProgress.value]),
                  onStackFinished: () => done.value = true,
                  itemChanged: (item, index) => increaseProgress(
                    widget.reviewProgress,
                    reviewProgress,
                    index,
                  ),
                  fillSpace: false,
                ),
              ),
              const Spacer(),
              if (widget.reviewOption.$1 != LectureType.remember)
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(lectureProvider.notifier)
                        .putLectureInRememberChamber(
                          lectures[widget.reviewProgress.value].id,
                        );
                  },
                  label: Text(context.l10n.remember),
                  icon: const Icon(Icons.save),
                )
              else
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(lectureProvider.notifier)
                        .banishLectureFromRememberChamber(
                          lectures[widget.reviewProgress.value].id,
                        );
                  },
                  label: Text(context.l10n.forget),
                  icon: const Icon(Icons.remove_circle),
                ),
              const SizedBox(height: 20),
              LectureProgress(widget.reviewProgress.value, lectures.length),
            ],
          ),
        ],
      ),
    );
  }
}
