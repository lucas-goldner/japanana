import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';
import 'package:japanana/features/review_selection/presentation/widgets/review_selection_item.dart';

class ReviewSelection extends StatelessWidget {
  const ReviewSelection({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.inversePrimary,
          title: Text(
            key: K.reviewSelectionAppTitle,
            context.l10n.appTitle,
            style: context.textTheme.headlineLarge,
          ),
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
