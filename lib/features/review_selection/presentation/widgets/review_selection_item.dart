import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';

class ReviewSelectionItem extends StatelessWidget {
  const ReviewSelectionItem(this.reviewOption, {super.key});
  final ReviewSections reviewOption;

  void _startReview(BuildContext context) =>
      context.push(AppRoutes.reviewSetup.path, extra: reviewOption);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => _startReview(context),
        title: Text(
          key: K.getReviewSelectionItemTitleForReviewOption(reviewOption),
          reviewOption.getLocalizedTitle(context),
          style: context.textTheme.headlineSmall,
          maxLines: 3,
        ),
        trailing: IconButton(
          onPressed: () => _startReview(context),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      );
}
