import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/hooks/use_widget_canvas_controller.dart';
import 'package:japanana/core/presentation/widgets/widget_canvas.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';
import 'package:japanana/features/settings/presentation/widgets/connecting_lines.dart';
import 'package:japanana/features/settings/presentation/widgets/settings_sheet.dart';

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

  void _onSettingTap(BuildContext context, SettingType settingType) =>
      switch (settingType) {
        SettingType.sendFeedback => print('Sent Feedback'),
        SettingType.followOnX => print('Follow on X'),
        SettingType.website => print('Show Website'),
        SettingType.rateTheApp => print('Rate the App'),
        SettingType.privacyPolicy => print('Privacy Policy'),
        SettingType.termsOfUse => print('Terms of Use'),
        _ => SettingsModal.show(
            context: context,
            settingType: settingType,
          ),
      };

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
          onTap: () => _onSettingTap(context, settingType),
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
            'Settings',
            style: context.textTheme.headlineSmall,
          ),
          backgroundColor: context.colorScheme.secondary,
          surfaceTintColor: context.colorScheme.secondary,
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

class _SettingCanvasItem extends StatelessWidget {
  const _SettingCanvasItem({
    required this.settingType,
  });

  final SettingType settingType;

  @override
  Widget build(BuildContext context) => Hero(
        tag: settingType,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              settingType.icon,
              color: context.colorScheme.primary,
              size: 32,
            ),
            const SizedBox(height: 12),
            Text(
              settingType.label,
              style: context.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: context.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
}
