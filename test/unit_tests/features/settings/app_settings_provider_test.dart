import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';
import 'package:japanana/features/settings/data/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../golden/golden_fakes.dart';

const _texts = (title: 'title', body: 'body');

Future<(ProviderContainer, FakeReminderService, SharedPreferences)> _setUp({
  Map<String, Object> values = const {},
  bool grantPermission = true,
}) async {
  SharedPreferences.setMockInitialValues(values);
  final prefs = await SharedPreferences.getInstance();
  final reminders = FakeReminderService(grantPermission: grantPermission);
  final container = ProviderContainer(
    overrides: [
      preferencesProvider.overrideWithValue(prefs),
      reminderServiceProvider.overrideWithValue(reminders),
    ],
  );
  addTearDown(container.dispose);
  return (container, reminders, prefs);
}

void main() {
  test('defaults to following the device', () async {
    final (container, _, _) = await _setUp();

    final settings = container.read(appSettingsProvider);

    expect(settings.themeMode, ThemeMode.system);
    expect(settings.language, AppLanguage.system);
    expect(settings.notificationsEnabled, isFalse);
    expect(settings.reminderTime, isNull);
  });

  test('restores saved settings', () async {
    final (container, _, _) = await _setUp(
      values: {
        'settings_theme_mode': 'dark',
        'settings_language': 'japanese',
        'settings_notifications_enabled': true,
        'settings_reminder_minutes': 8 * 60 + 30,
      },
    );

    final settings = container.read(appSettingsProvider);

    expect(settings.themeMode, ThemeMode.dark);
    expect(settings.language.locale, const Locale('ja'));
    expect(settings.notificationsEnabled, isTrue);
    expect(settings.reminderTime, const TimeOfDay(hour: 8, minute: 30));
  });

  test('persists theme and language', () async {
    final (container, _, prefs) = await _setUp();
    final notifier = container.read(appSettingsProvider.notifier);

    await notifier.setThemeMode(ThemeMode.light);
    await notifier.setLanguage(AppLanguage.english);

    expect(prefs.getString('settings_theme_mode'), 'light');
    expect(prefs.getString('settings_language'), 'english');
  });

  test('turning on the reminder enables notifications and schedules it',
      () async {
    final (container, reminders, _) = await _setUp();

    final allowed = await container
        .read(appSettingsProvider.notifier)
        .setReminderTime(const TimeOfDay(hour: 20, minute: 0), texts: _texts);

    expect(allowed, isTrue);
    expect(container.read(appSettingsProvider).notificationsEnabled, isTrue);
    expect(reminders.scheduled, const TimeOfDay(hour: 20, minute: 0));
  });

  test('denied permission keeps notifications and the reminder off', () async {
    final (container, reminders, _) = await _setUp(grantPermission: false);

    final allowed = await container
        .read(appSettingsProvider.notifier)
        .setReminderTime(const TimeOfDay(hour: 20, minute: 0), texts: _texts);

    expect(allowed, isFalse);
    expect(container.read(appSettingsProvider).notificationsEnabled, isFalse);
    expect(container.read(appSettingsProvider).reminderTime, isNull);
    expect(reminders.scheduled, isNull);
  });

  test('turning notifications off cancels the reminder', () async {
    final (container, reminders, _) = await _setUp(
      values: {
        'settings_notifications_enabled': true,
        'settings_reminder_minutes': 9 * 60,
      },
    );
    reminders.scheduled = const TimeOfDay(hour: 9, minute: 0);

    await container
        .read(appSettingsProvider.notifier)
        .setNotificationsEnabled(enabled: false, texts: _texts);

    expect(reminders.scheduled, isNull);
  });
}
