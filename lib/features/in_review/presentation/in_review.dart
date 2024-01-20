import 'package:flutter/material.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';

class InReview extends StatelessWidget {
  const InReview(this.reviewOption, {super.key});
  final ReviewOptions reviewOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(
          key: Key('in_review_app_title_${reviewOption.name}'),
          reviewOption.getLocalizedTitle(context),
          style: theme.textTheme.headlineSmall,
        ),
      ),
      body: Text(reviewOption.name),
    );
  }
}
