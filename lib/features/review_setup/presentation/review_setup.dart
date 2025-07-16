import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/presentation/widgets/page_curl_transition.dart';
import 'package:japanana/core/presentation/widgets/scribble_border_button.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/review_setup/presentation/widgets/review_setup_option.dart';
import 'package:japanana/features/session/application/session_provider.dart';

class ReviewSetup extends StatefulWidget {
  const ReviewSetup(this.reviewSection, {super.key});
  final LectureType? reviewSection;

  @override
  State<ReviewSetup> createState() => _ReviewSetupState();
}

class _ReviewSetupState extends State<ReviewSetup> with RestorationMixin {
  final RestorableEnum _restorableLectureType =
      RestorableEnum(LectureType.writing, values: LectureType.values);

  @override
  String? get restorationId => 'reviewSetup';

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableLectureType, 'setupLectureType');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
      const Duration(seconds: 1),
      () => reviewSection(widget.reviewSection),
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

  @override
  Widget build(BuildContext context) => _ReviewSetupContent(
        widget.reviewSection ?? (_restorableLectureType.value as LectureType?),
      );
}

class _ReviewSetupContent extends HookConsumerWidget {
  const _ReviewSetupContent(this.reviewSection);
  final LectureType? reviewSection;

  void navigateToReview(BuildContext context, ReviewSetupOptions options) {
    navigateWithPageCurl(
      context,
      InReview((reviewSection, options)),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewOptions = useState(
      const ReviewSetupOptions(randomize: false, repeatOnFalseCard: false),
    );

    final existingSession = ref.watch(sessionProvider);
    final hasSessionForType =
        reviewSection != null && existingSession?.lectureType == reviewSection;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          key: K.reviewSetupAppTitle,
          reviewSection?.getLocalizedTitle(context) ?? '',
          style: context.textTheme.headlineSmall,
        ),
      ),
      body: Stack(
        children: [
          const NoteBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(left: 48),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        ReviewSetupOption(
                          label: context.l10n.randomizeCards,
                          value: reviewOptions.value.randomize,
                          onChanged: (value) => reviewOptions.value =
                              reviewOptions.value.copyWith(randomize: value),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        ReviewSetupOption(
                          label: context.l10n.repeatFailedCards,
                          value: reviewOptions.value.repeatOnFalseCard,
                          onChanged: (value) => reviewOptions.value =
                              reviewOptions.value
                                  .copyWith(repeatOnFalseCard: value),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (hasSessionForType) ...[
                    ScribbleBorderButton(
                      onPressed: () {
                        final session = ref.read(sessionProvider);
                        if (session != null) {
                          navigateToReview(context, session.options);
                        }
                      },
                      minHeight: 80,
                      borderColor: Colors.green,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'CONTINUE',
                            style: context.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          if (existingSession != null)
                            Text(
                              '${existingSession.completedLectureIds.length} '
                              'completed',
                              style: context.textTheme.bodySmall?.copyWith(
                                color: Colors.green,
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ScribbleBorderButton(
                    key: K.startReviewButton,
                    onPressed: () async {
                      if (reviewSection case final LectureType type) {
                        await ref
                            .read(sessionProvider.notifier)
                            .startNewSession(
                              type,
                              reviewOptions.value,
                            );
                      }
                      if (context.mounted) {
                        navigateToReview(context, reviewOptions.value);
                      }
                    },
                    minHeight: 100,
                    child: Text(
                      context.l10n.startReview.toUpperCase(),
                      style: context.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
