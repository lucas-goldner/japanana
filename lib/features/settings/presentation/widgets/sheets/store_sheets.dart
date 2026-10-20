import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/domain/store_catalog.dart';
import 'package:japanana/features/settings/presentation/widgets/sheet_parts.dart';
import 'package:japanana/features/settings/presentation/widgets/supporter_badge.dart';

class SubscriptionSheet extends HookConsumerWidget {
  const SubscriptionSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final store = ref.watch(storeProvider);
    final failed = useState(false);
    final busy = useState(false);

    Future<void> run(Future<void> Function() action) async {
      if (busy.value) return;
      busy.value = true;
      failed.value = false;
      try {
        await action();
      } on Object {
        failed.value = true;
      } finally {
        busy.value = false;
      }
    }

    return SheetColumn(
      children: [
        SheetDescription(l10n.subscriptionDescription),
        ...switch (store) {
          AsyncData(:final value) when value.isSupporter => [
              const Center(child: SupporterBadge()),
              SheetMessage(
                l10n.subscriptionActive,
                tone: SheetMessageTone.success,
              ),
            ],
          AsyncData(:final value) => [
              for (final item in value.subscriptions)
                _StoreItemButton(
                  item: item,
                  label: switch (item.kind) {
                    StoreItemKind.yearly => l10n.subscriptionYearly,
                    _ => l10n.subscriptionMonthly,
                  },
                  highlighted: item.kind == StoreItemKind.yearly,
                  onPressed: () => run(
                    () => ref.read(storeProvider.notifier).purchase(item),
                  ),
                ),
              NeoButton(
                onPressed: () =>
                    run(() => ref.read(storeProvider.notifier).restore()),
                minHeight: 48,
                child: Text(
                  l10n.restorePurchases,
                  style: TextStyle(
                    fontFamily: context.textTheme.notoSansJPFont,
                  ),
                ),
              ),
            ],
          AsyncError() => [
              SheetMessage(l10n.storeUnavailable, tone: SheetMessageTone.error),
            ],
          _ => [const _StoreLoading()],
        },
        if (failed.value)
          SheetMessage(l10n.storeUnavailable, tone: SheetMessageTone.error),
      ],
    );
  }
}

class DonationSheet extends HookConsumerWidget {
  const DonationSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final store = ref.watch(storeProvider);
    final thanked = useState(false);
    final failed = useState(false);
    final busy = useState(false);

    Future<void> tip(StoreItem item) async {
      if (busy.value) return;
      busy.value = true;
      failed.value = false;
      try {
        if (await ref.read(storeProvider.notifier).purchase(item)) {
          thanked.value = true;
        }
      } on Object {
        failed.value = true;
      } finally {
        busy.value = false;
      }
    }

    return SheetColumn(
      children: [
        SheetDescription(l10n.donationDescription),
        ...switch (store) {
          AsyncData(:final value) when value.tips.isNotEmpty => [
              for (final (index, item) in value.tips.indexed)
                _StoreItemButton(
                  item: item,
                  label: item.title,
                  leading: switch (index) {
                    0 => Icons.local_cafe_outlined,
                    1 => Icons.ramen_dining_outlined,
                    _ => Icons.celebration_outlined,
                  },
                  highlighted: index == 1,
                  onPressed: () => tip(item),
                ),
            ],
          AsyncData() || AsyncError() => [
              SheetMessage(l10n.storeUnavailable, tone: SheetMessageTone.error),
            ],
          _ => [const _StoreLoading()],
        },
        if (thanked.value)
          SheetMessage(l10n.donationThanks, tone: SheetMessageTone.success),
        if (failed.value)
          SheetMessage(l10n.storeUnavailable, tone: SheetMessageTone.error),
      ],
    );
  }
}

class _StoreItemButton extends StatelessWidget {
  const _StoreItemButton({
    required this.item,
    required this.label,
    required this.onPressed,
    this.highlighted = false,
    this.leading,
  });

  final StoreItem item;
  final String label;
  final VoidCallback onPressed;
  final bool highlighted;
  final IconData? leading;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    final foreground = highlighted ? Colors.white : neo.onCard;
    final style = TextStyle(
      fontFamily: context.textTheme.notoSansJPFont,
      fontSize: 16,
      color: foreground,
    );

    return NeoButton(
      onPressed: onPressed,
      minHeight: 60,
      color: highlighted ? context.colorScheme.tertiary : null,
      foregroundColor: foreground,
      shadowColor: highlighted ? neo.accentShadow : null,
      child: Row(
        children: [
          if (leading != null) ...[
            Icon(leading, color: foreground),
            const SizedBox(width: 12),
          ],
          Expanded(child: Text(label, style: style)),
          Text(item.price, style: style.copyWith(fontSize: 18)),
        ],
      ),
    );
  }
}

class _StoreLoading extends StatelessWidget {
  const _StoreLoading();

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(color: context.neo.border),
        ),
      );
}
