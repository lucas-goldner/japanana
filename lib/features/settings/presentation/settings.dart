import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/app_config.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/hooks/use_widget_canvas_controller.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/settings/data/external_actions.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';
import 'package:japanana/features/settings/presentation/widgets/connecting_lines.dart';
import 'package:japanana/features/settings/presentation/widgets/settings_sheet.dart';
import 'package:japanana/features/settings/presentation/widgets/supporter_badge.dart';

const settingsLayout = [
  // Core App Settings (Top-Left)
  (SettingType.language, Offset(-180, -380)),
  (SettingType.theme, Offset(-50, -240)),
  (SettingType.notifications, Offset(-250, -100)), // Bridge to center
  (SettingType.reminder, Offset(-280, 20)),

  // Data & Progress (Top-Right)
  (SettingType.exportSyncData, Offset(100, -340)), // Bridge to center
  (SettingType.resetProgress, Offset(320, -250)),

  //  Premium & Support (CENTER - Hub)
  (SettingType.subscription, Offset(-50, -50)), // Bridge to top-left
  (SettingType.sendFeedback, Offset(50, 50)), // Bridge to bottom-right
  (SettingType.donation, Offset(-150, 150)),
  (SettingType.rateTheApp, Offset(-220, 350)),
  (SettingType.otherApps, Offset(-320, 420)),

  // Info, Legal & External (Bottom-Right)
  (SettingType.seeChangelog, Offset(250, 200)), // Bridge from center
  (SettingType.privacyPolicy, Offset(230, 480)),
  (SettingType.termsOfUse, Offset(120, 400)),
  (SettingType.website, Offset(-80, 450)),
  (SettingType.followOnX, Offset(30, 300)),
];

class Settings extends HookConsumerWidget {
  const Settings({super.key});

  Future<void> _onSettingTap(
    BuildContext context,
    WidgetRef ref,
    SettingType settingType,
  ) async {
    if (!settingType.isExternal) {
      await SettingsModal.show(context: context, settingType: settingType);
      return;
    }

    final actions = ref.read(externalActionsProvider);
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final opened = switch (settingType) {
      SettingType.sendFeedback => await actions.sendFeedback(
          subject: l10n.feedbackSubject,
          body: l10n.feedbackBody,
        ),
      SettingType.rateTheApp => await actions.rateApp().then((_) => true),
      SettingType.followOnX => await actions.openUrl(AppConfig.xProfileUrl),
      SettingType.website => await actions.openUrl(AppConfig.websiteUrl),
      SettingType.otherApps => await actions.openUrl(AppConfig.otherAppsUrl),
      SettingType.privacyPolicy =>
        await actions.openUrl(AppConfig.privacyPolicyUrl, inApp: true),
      SettingType.termsOfUse =>
        await actions.openUrl(AppConfig.termsOfUseUrl, inApp: true),
      _ => true,
    };
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.linkFailed)));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useCenteredWidgetCanvasController(
      context: context,
      centerOffset: const Offset(0, -150),
      scale: 0.8,
      children: settingsLayout.map((setting) {
        final (settingType, offset) = setting;
        return WidgetCanvasChild(
          key: ValueKey(settingType),
          offset: offset,
          size: const Size(120, 140),
          onTap: () => _onSettingTap(context, ref, settingType),
          child: _SettingCanvasItem(
            settingType: settingType,
          ),
        );
      }).toList(),
    );

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Allow normal back navigation since we're using page transitions
      },
      child: Scaffold(
        backgroundColor: context.colorScheme.surface,
        appBar: AppBar(
          title: Text(
            context.l10n.settings,
            style: context.textTheme.headlineSmall,
          ),
        ),
        body: WidgetCanvas(
          controller: controller,
          backgroundColor: context.colorScheme.secondary,
          minScale: 0.1,
          maxScale: 1,
          selectionWidget: Padding(
            padding: const EdgeInsets.all(8),
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: context.colorScheme.onSecondary,
                  width: 3,
                ),
              ),
            ),
          ),
          backgroundWidget: ConnectingLines(
            controller: controller,
            lineColor: context.colorScheme.onSecondary,
            lineWidth: 3,
            opacity: 1,
            connectionRange: 250,
            linePadding: 52,
          ),
        ),
      ),
    );
  }
}

class _SettingCanvasItem extends ConsumerWidget {
  const _SettingCanvasItem({
    required this.settingType,
  });

  final SettingType settingType;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscription = settingType == SettingType.subscription;
    final isSupporter = isSubscription &&
        (ref.watch(storeProvider).value?.isSupporter ?? false);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Hero(
          tag: settingType,
          child: Container(
            width: 60,
            height: 60,
            decoration: context.neo.decoration(
              color: isSubscription ? context.neo.accent : null,
              shadowColor: isSubscription ? context.neo.accentShadow : null,
              shape: BoxShape.circle,
            ),
            child: Icon(
              settingType.icon,
              color: isSubscription ? context.neo.onAccent : context.neo.onCard,
              size: 28,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          settingType.label(context),
          style: context.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: context.colorScheme.onSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (isSupporter) ...[
          const SizedBox(height: 4),
          const SupporterBadge(),
        ],
      ],
    );
  }
}
