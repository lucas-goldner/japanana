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
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SettingsModal(settingType: settingType),
    );
  }

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Hero(
                      tag: settingType,
                      child: Icon(
                        settingType.icon,
                        color: context.colorScheme.primary,
                        size: 48,
                      ),
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
            ],
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
    }
  }
}
