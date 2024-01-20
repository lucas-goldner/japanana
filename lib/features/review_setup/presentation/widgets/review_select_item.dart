import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/core/router.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';

class ReviewSelectItem extends StatelessWidget {
  const ReviewSelectItem(this.reviewOption, {super.key});
  final ReviewOptions reviewOption;

  void _startReview(BuildContext context) =>
      context.push(AppRoutes.inReview.path, extra: reviewOption);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => _startReview(context),
        title: Text(
          key: K.getReviewSelectItemTitleForReviewOption(reviewOption),
          reviewOption.getLocalizedTitle(context),
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 3,
        ),
        trailing: IconButton(
          onPressed: () => _startReview(context),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      );
}
