import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InReview extends StatelessWidget {
  const InReview({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme.colorScheme.inversePrimary,
        title: Text(
          t!.appTitle,
          style: theme.textTheme.headlineLarge,
        ),
      ),
      body: Text("In Review"),
    );
  }
}
