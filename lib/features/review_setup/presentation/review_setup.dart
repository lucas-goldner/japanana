import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hikou/core/extensions.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';
import 'package:hikou/features/review_setup/presentation/widgets/review_select_item.dart';

class ReviewSetup extends StatelessWidget {
  const ReviewSetup({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: context.colorScheme.inversePrimary,
          title: Text(
            key: K.reviewSetupAppTitle,
            context.l10n.appTitle,
            style: context.textTheme.headlineLarge,
          ),
        ),
        body: ListView.separated(
          itemCount: ReviewOptions.values.length,
          itemBuilder: (context, index) => ReviewSelectItem(
            ReviewOptions.values[index],
          ),
          separatorBuilder: (context, index) => const Divider(),
        ),
      );
}
