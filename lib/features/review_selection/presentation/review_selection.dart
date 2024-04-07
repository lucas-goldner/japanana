import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';
import 'package:japanana/features/review_selection/presentation/widgets/review_selection_item.dart';

class ReviewSelection extends ConsumerWidget {
  const ReviewSelection({super.key});

  void _navigateToLectureList(BuildContext context, WidgetRef ref) =>
      context.push(
        AppRoutes.lectureList.path,
        extra: ref.read(lectureProvider),
      );

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
        appBar: AppBar(
          title: Text(
            key: K.reviewSelectionAppTitle,
            context.l10n.appTitle,
            style: context.textTheme.headlineLarge,
          ),
          actions: [
            IconButton(
              icon: Icon(
                Icons.list_alt_outlined,
                color: context.colorScheme.secondaryContainer,
              ),
              onPressed: () => _navigateToLectureList(context, ref),
            ),
          ],
        ),
        body: ListView.separated(
          itemCount: ReviewSections.values.length,
          itemBuilder: (context, index) => ReviewSelectionItem(
            ReviewSections.values[index],
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
}
