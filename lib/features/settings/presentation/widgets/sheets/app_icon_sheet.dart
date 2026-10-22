import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/features/settings/application/app_icon_provider.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/domain/app_icon.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';
import 'package:japanana/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:japanana/features/settings/presentation/widgets/sheet_parts.dart';

/// Corner radius of an icon preview relative to its size, like iOS.
const _kIconCornerRatio = 0.225;

class AppIconSheet extends HookConsumerWidget {
  const AppIconSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(appIconProvider).value ?? AppIcon.sparkle;
    final isSupporter = ref.watch(storeProvider).value?.isSupporter ?? false;
    final failed = useState(false);

    Future<void> pick(AppIcon icon) async {
      failed.value = false;
      if (icon.isPerk && !isSupporter) {
        // Alternate icons come with the supporter subscription.
        final navigator = Navigator.of(context);
        final root = Navigator.of(context, rootNavigator: true).context;
        navigator.pop();
        await SettingsModal.show(
          context: root,
          settingType: SettingType.subscription,
        );
        return;
      }
      try {
        await ref.read(appIconProvider.notifier).select(icon);
      } on Exception {
        failed.value = true;
      }
    }

    return SheetColumn(
      children: [
        SheetDescription(l10n.appIconDescription),
        if (!isSupporter)
          SheetMessage(
            l10n.appIconSupporterPerk,
            tone: SheetMessageTone.success,
          ),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 18,
          crossAxisSpacing: 16,
          childAspectRatio: 0.78,
          children: [
            for (final icon in AppIcon.values)
              _IconChoice(
                icon: icon,
                locked: icon.isPerk && !isSupporter,
                selected: icon == selected,
                onTap: () => pick(icon),
              ),
          ],
        ),
        if (failed.value)
          SheetMessage(l10n.appIconFailed, tone: SheetMessageTone.error),
      ],
    );
  }
}

class _IconChoice extends StatelessWidget {
  const _IconChoice({
    required this.icon,
    required this.locked,
    required this.selected,
    required this.onTap,
  });

  final AppIcon icon;
  final bool locked;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final neo = context.neo;
    return Semantics(
      button: true,
      selected: selected,
      label: locked
          ? '${icon.label(context)}, ${context.l10n.settingSubscription}'
          : icon.label(context),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final size = constraints.biggest.shortestSide - 8;
                  final radius =
                      BorderRadius.circular(size * _kIconCornerRatio);
                  return Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            color: neo.card,
                            borderRadius: radius,
                            border: Border.all(
                              color: selected ? neo.border : Colors.transparent,
                              width: neo.borderWidth,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: selected ? neo.accentShadow : neo.shadow,
                                offset: selected
                                    ? neo.shadowOffset
                                    : const Offset(2, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: radius,
                            child: Opacity(
                              opacity: locked ? 0.55 : 1,
                              child: Image.asset(
                                icon.preview,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        if (locked)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: neo.decoration(
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.lock,
                                size: 15,
                                color: neo.onCard,
                              ),
                            ),
                          ),
                        if (selected)
                          Positioned(
                            top: -8,
                            right: -8,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: neo.decoration(
                                color: neo.accent,
                                shadowColor: neo.accentShadow,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.check,
                                size: 16,
                                color: neo.onAccent,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Text(
              icon.label(context),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textTheme.labelLarge?.copyWith(
                fontFamily: context.textTheme.notoSansJPFont,
                fontWeight: FontWeight.bold,
                color: context.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
