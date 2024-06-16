import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/router.dart';

import 'package:japanana/features/review_setup/domain/review_setup_options.dart';
import 'package:japanana/features/review_setup/presentation/widgets/review_setup_option.dart';

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
  String? get restorationId => "reviewSetup";

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    registerForRestoration(_restorableLectureType, 'setupLectureType');
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(
        Duration(seconds: 1), () => reviewSection(widget.reviewSection));
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

class _ReviewSetupContent extends HookWidget {
  const _ReviewSetupContent(this.reviewSection);
  final LectureType? reviewSection;

  void navigateToReview(BuildContext context, ReviewSetupOptions options) {
    context.push(
      AppRoutes.inReview.path,
      extra: (reviewSection, options),
    );
  }

  @override
  Widget build(BuildContext context) {
    final reviewOptions = useState(
      ReviewSetupOptions(randomize: false, repeatOnFalseCard: false),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colorScheme.inversePrimary,
        title: Text(
          key: K.reviewSetupAppTitle,
          context.l10n.appTitle,
          style: context.textTheme.headlineLarge,
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: 20,
          ),
          Text(
            reviewSection?.getLocalizedTitle(context) ?? "",
            style: context.textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 20,
                ),
                ReviewSetupOption(
                  label: context.l10n.randomizeCards,
                  value: reviewOptions.value.randomize,
                  onChanged: (value) => reviewOptions.value =
                      reviewOptions.value.copyWith(randomize: value),
                ),
                SizedBox(
                  height: 20,
                ),
                ReviewSetupOption(
                  label: context.l10n.repeatFailedCards,
                  value: reviewOptions.value.repeatOnFalseCard,
                  onChanged: (value) => reviewOptions.value =
                      reviewOptions.value.copyWith(repeatOnFalseCard: value),
                )
              ],
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.only(bottom: 40, left: 24, right: 24),
            child: ElevatedButton(
              key: K.startReviewButton,
              onPressed: () => navigateToReview(context, reviewOptions.value),
              child: Text(
                context.l10n.startReview.toUpperCase(),
                style: context.textTheme.bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
