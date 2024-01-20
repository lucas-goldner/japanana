import 'package:flutter/material.dart';
import 'package:hikou/core/application/lecture_provider.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class InReview extends HookConsumerWidget {
  const InReview(this.reviewOption, {super.key});
  final ReviewOptions reviewOption;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lectures = ref.watch(lectureProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(
          key: K.getInReviewAppTitleForReviewOption(reviewOption),
          reviewOption.getLocalizedTitle(context),
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: Text(reviewOption.name),
    );
  }
}
