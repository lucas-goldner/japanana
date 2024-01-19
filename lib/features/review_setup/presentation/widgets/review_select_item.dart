import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hikou/core/router.dart';

class ReviewSelectItem extends StatelessWidget {
  const ReviewSelectItem(this.title, {super.key});
  final String? title;

  void _startReview(BuildContext context) =>
      context.push(AppRoutes.inReview.path);

  @override
  Widget build(BuildContext context) => ListTile(
        onTap: () => _startReview(context),
        title: Text(
          title ?? "",
          style: Theme.of(context).textTheme.headlineSmall,
          maxLines: 3,
        ),
        trailing: IconButton(
          onPressed: () => _startReview(context),
          icon: const Icon(Icons.arrow_forward_ios),
        ),
      );
}
