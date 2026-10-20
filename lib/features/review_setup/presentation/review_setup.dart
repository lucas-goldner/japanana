import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/core/presentation/widgets/note_background.dart';
import 'package:japanana/core/presentation/widgets/transition/page_curl_transition.dart';
import 'package:japanana/features/in_review/presentation/in_review.dart';
import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/review_setup/presentation/widgets/review_setup_option.dart';
import 'package:japanana/features/session/application/session_provider.dart';

class ReviewSetup extends HookConsumerWidget {
  const ReviewSetup(this.reviewSection, {super.key});
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

    final existingSession = reviewSection != null
        ? ref.watch(sessionProvider(reviewSection!))
        : null;
    final hasSessionForType = existingSession != null;

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
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ReviewSetupOption(
                    label: context.l10n.randomizeCards,
                    value: reviewOptions.value.randomize,
                    onChanged: (value) => reviewOptions.value =
                        reviewOptions.value.copyWith(randomize: value),
                  ),
                  const SizedBox(height: 20),
                  ReviewSetupOption(
                    label: context.l10n.repeatFailedCards,
                    value: reviewOptions.value.repeatOnFalseCard,
                    onChanged: (value) => reviewOptions.value =
                        reviewOptions.value.copyWith(repeatOnFalseCard: value),
                  ),
                  const Spacer(),
                  if (hasSessionForType) ...[
                    NeoButton(
                      onPressed: () {
                        if (reviewSection != null) {
                          final session =
                              ref.read(sessionProvider(reviewSection!));
                          if (session != null) {
                            navigateToReview(context, session.options);
                          }
                        }
                      },
                      minHeight: 72,
                      color: context.neo.correctFill,
                      foregroundColor: context.neo.onFeedback,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            context.l10n.continueReview,
                            style: _buttonTextStyle(context),
                          ),
                          Text(
                            context.l10n.completedLectures(
                              existingSession.completedLectureIds.length,
                            ),
                            style: TextStyle(
                              fontFamily: context.textTheme.notoSansJPFont,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  NeoButton(
                    key: K.startReviewButton,
                    onPressed: () async {
                      if (reviewSection case final LectureType type) {
                        await ref
                            .read(sessionProvider(type).notifier)
                            .startNewSession(
                              reviewOptions.value,
                            );
                      }
                      if (context.mounted) {
                        navigateToReview(context, reviewOptions.value);
                      }
                    },
                    minHeight: 80,
                    color: context.neo.accent,
                    foregroundColor: context.neo.onAccent,
                    shadowColor: context.neo.accentShadow,
                    child: Text(
                      context.l10n.startReview.toUpperCase(),
                      style: _buttonTextStyle(context),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

TextStyle _buttonTextStyle(BuildContext context) => TextStyle(
      fontFamily: context.textTheme.notoSansJPFont,
      fontSize: 16,
      letterSpacing: 1,
    );
