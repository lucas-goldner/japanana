import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/features/settings/application/changelog_provider.dart';
import 'package:japanana/features/settings/domain/changelog_entry.dart';
import 'package:japanana/features/settings/presentation/widgets/sheet_parts.dart';

class ChangelogSheet extends ConsumerWidget {
  const ChangelogSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(changelogProvider)) {
        AsyncData(:final value) => SheetColumn(
            children: [
              for (final (index, entry) in value.indexed)
                _ChangelogCard(entry: entry, isLatest: index == 0),
            ],
          ),
        _ => const SizedBox(height: 120),
      };
}

class _ChangelogCard extends StatelessWidget {
  const _ChangelogCard({required this.entry, required this.isLatest});

  final ChangelogEntry entry;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final locale = Localizations.localeOf(context);
    final textStyle = TextStyle(
      color: neo.onCard,
      fontFamily: context.textTheme.notoSansJPFont,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: neo.decoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: neo
                    .decoration(
                      color: isLatest ? neo.accent : neo.card,
                      borderRadius: BorderRadius.circular(999),
                    )
                    .copyWith(boxShadow: []),
                child: Text(
                  context.l10n.changelogVersion(entry.version),
                  style: textStyle.copyWith(
                    color: isLatest ? neo.onAccent : neo.onCard,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat.yMMMd(locale.toLanguageTag()).format(entry.date),
                style: textStyle.copyWith(fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final change in entry.changesFor(locale.languageCode))
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 7, right: 10),
                    child: Container(
                      width: 8,
                      height: 8,
                      color: context.colorScheme.tertiary,
                    ),
                  ),
                  Expanded(
                    child: Text(change, style: textStyle.copyWith(height: 1.4)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
