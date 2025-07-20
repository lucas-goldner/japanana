import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';

class SettingsModal extends StatelessWidget {
  const SettingsModal({
    required this.settingType,
    super.key,
  });

  final SettingType settingType;

  static Future<void> show({
    required BuildContext context,
    required SettingType settingType,
  }) async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) => SettingsModal(settingType: settingType),
    );
  }

  @override
  Widget build(BuildContext context) => Center(
        child: Hero(
          tag: settingType,
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 300,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: context.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    settingType.icon,
                    color: context.colorScheme.primary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    settingType.label,
                    style: context.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  _buildContent(context),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          settingType.getOnTap().call();
                        },
                        child: const Text('Confirm'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _buildContent(BuildContext context) {
    switch (settingType) {
      case SettingType.language:
        return Text(
          'Change the app language',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.theme:
        return Text(
          'Switch between light and dark theme',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.notifications:
        return Text(
          'Configure notification preferences',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.subscription:
        return Text(
          'Manage your subscription',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.reminder:
        return Text(
          'Set up daily study reminders',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.resetProgress:
        return Text(
          'Reset all your learning progress',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.statistics:
        return Text(
          'View your learning statistics',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.exportSyncData:
        return Text(
          'Export or sync your data',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.sendFeedback:
        return Text(
          'Send us your feedback',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.donation:
        return Text(
          'Support the app development',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.followOnX:
        return Text(
          'Follow us on X (Twitter)',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.website:
        return Text(
          'Visit our website',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.privacyPolicy:
        return Text(
          'Read our privacy policy',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.termsOfUse:
        return Text(
          'Read the terms of use',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.rateTheApp:
        return Text(
          'Rate the app on the store',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.otherApps:
        return Text(
          'Check out our other apps',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.seeChangelog:
        return Text(
          "See what's new in this version",
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
      case SettingType.resetData:
        return Text(
          'Reset all app data',
          style: context.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        );
    }
  }
}
