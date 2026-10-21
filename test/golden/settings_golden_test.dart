@Tags(['golden'])
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/features/settings/data/backup_storage.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';
import 'package:japanana/features/settings/domain/setting_type.dart';
import 'package:japanana/features/settings/presentation/settings.dart';
import 'package:japanana/features/settings/presentation/widgets/settings_sheet.dart';

import 'golden_fakes.dart';
import 'golden_utils.dart';

/// Shows the settings screen and opens the sheet of [settingType] on top.
class _SettingsWithSheet extends StatefulWidget {
  const _SettingsWithSheet(this.settingType);
  final SettingType settingType;

  @override
  State<_SettingsWithSheet> createState() => _SettingsWithSheetState();
}

class _SettingsWithSheetState extends State<_SettingsWithSheet> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => SettingsModal.show(
        context: context,
        settingType: widget.settingType,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => const Settings();
}

void main() {
  setUpGoldens();

  Future<void> pumpSheet(
    WidgetTester tester,
    ThemeData theme,
    SettingType settingType, {
    Map<String, Object> preferences = const {},
    PurchasesService? purchases,
    BackupStorage? backupStorage,
  }) async {
    await pumpGoldenScreen(
      tester,
      screen: _SettingsWithSheet(settingType),
      theme: theme,
      preferences: preferences,
      purchases: purchases,
      backupStorage: backupStorage,
    );
    await pumpFor(tester, const Duration(seconds: 1));
  }

  goldenTest('Settings', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Settings(), theme: theme);
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'default',
      themeName: themeName,
    );
  });

  goldenTest('Settings in Japanese as supporter', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpGoldenScreen(
      tester,
      screen: const Settings(),
      theme: theme,
      locale: const Locale('ja'),
      purchases: FakePurchasesService(isSupporter: true),
    );
    await pumpFor(tester, const Duration(milliseconds: 500));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'japanese_supporter',
      themeName: themeName,
    );
  });

  goldenTest('Settings sheet', (tester, theme, themeName) async {
    await pumpGoldenScreen(tester, screen: const Settings(), theme: theme);
    await pumpFor(tester, const Duration(milliseconds: 500));

    await tester.tap(find.text('Theme'), warnIfMissed: false);
    await pumpFor(tester, const Duration(seconds: 1));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'sheet',
      themeName: themeName,
    );
  });

  goldenTest('Language sheet', (tester, theme, themeName) async {
    await pumpSheet(
      tester,
      theme,
      SettingType.language,
      preferences: {'settings_language': 'english'},
    );

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'language',
      themeName: themeName,
    );
  });

  goldenTest('Notifications sheet', (tester, theme, themeName) async {
    await pumpSheet(
      tester,
      theme,
      SettingType.notifications,
      preferences: {'settings_notifications_enabled': true},
    );

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'notifications',
      themeName: themeName,
    );
  });

  goldenTest('Daily reminder sheet', (tester, theme, themeName) async {
    await pumpSheet(
      tester,
      theme,
      SettingType.reminder,
      preferences: {
        'settings_notifications_enabled': true,
        'settings_reminder_minutes': 8 * 60 + 30,
      },
    );

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'reminder',
      themeName: themeName,
    );
  });

  goldenTest('Reset progress sheet', (tester, theme, themeName) async {
    await pumpSheet(tester, theme, SettingType.resetProgress);

    await tester.tap(find.text('Reset progress').last);
    await pumpFor(tester, const Duration(milliseconds: 300));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'reset',
      themeName: themeName,
    );
  });

  goldenTest('Export and sync sheet', (tester, theme, themeName) async {
    await pumpSheet(
      tester,
      theme,
      SettingType.exportSyncData,
      backupStorage: FakeBackupStorage(),
    );

    await tester.tap(find.text('Back up to iCloud'));
    await pumpFor(tester, const Duration(milliseconds: 300));

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'export',
      themeName: themeName,
    );
  });

  goldenTest('Subscription sheet', (tester, theme, themeName) async {
    await pumpSheet(tester, theme, SettingType.subscription);

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'subscription',
      themeName: themeName,
    );
  });

  goldenTest('Subscription sheet as supporter', (
    tester,
    theme,
    themeName,
  ) async {
    await pumpSheet(
      tester,
      theme,
      SettingType.subscription,
      purchases: FakePurchasesService(isSupporter: true),
    );

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'subscription_supporter',
      themeName: themeName,
    );
  });

  goldenTest('Donation sheet', (tester, theme, themeName) async {
    await pumpSheet(tester, theme, SettingType.donation);

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'donation',
      themeName: themeName,
    );
  });

  goldenTest('Changelog sheet', (tester, theme, themeName) async {
    await pumpSheet(tester, theme, SettingType.seeChangelog);

    await expectScreenGolden(
      tester,
      screen: 'settings',
      name: 'changelog',
      themeName: themeName,
    );
  });
}
