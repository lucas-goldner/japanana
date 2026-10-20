import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/features/settings/data/reminder_service.dart';

const _themeModeKey = 'settings_theme_mode';
const _languageKey = 'settings_language';
const _notificationsKey = 'settings_notifications_enabled';
const _reminderMinutesKey = 'settings_reminder_minutes';

enum AppLanguage {
  system(null),
  english(Locale('en')),
  japanese(Locale('ja'));

  const AppLanguage(this.locale);

  /// Locale to force, or null to follow the device.
  final Locale? locale;
}

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.language = AppLanguage.system,
    this.notificationsEnabled = false,
    this.reminderTime,
  });

  final ThemeMode themeMode;
  final AppLanguage language;
  final bool notificationsEnabled;

  /// Time of the daily reminder, or null when the reminder is off.
  final TimeOfDay? reminderTime;

  AppSettings copyWith({
    ThemeMode? themeMode,
    AppLanguage? language,
    bool? notificationsEnabled,
    TimeOfDay? Function()? reminderTime,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        language: language ?? this.language,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        reminderTime: reminderTime != null ? reminderTime() : this.reminderTime,
      );
}

/// Text of the daily reminder notification, resolved by the caller so the
/// notifier doesn't need a [BuildContext].
typedef ReminderTexts = ({String title, String body});

final appSettingsProvider =
    NotifierProvider<AppSettingsNotifier, AppSettings>(AppSettingsNotifier.new);

class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final prefs = ref.watch(preferencesProvider);
    final reminderMinutes = prefs.getInt(_reminderMinutesKey);
    return AppSettings(
      themeMode: ThemeMode.values.asNameMap()[prefs.getString(_themeModeKey)] ??
          ThemeMode.system,
      language: AppLanguage.values.asNameMap()[prefs.getString(_languageKey)] ??
          AppLanguage.system,
      notificationsEnabled: prefs.getBool(_notificationsKey) ?? false,
      reminderTime: reminderMinutes == null
          ? null
          : TimeOfDay(
              hour: reminderMinutes ~/ 60,
              minute: reminderMinutes % 60,
            ),
    );
  }

  Future<void> setThemeMode(ThemeMode themeMode) async {
    state = state.copyWith(themeMode: themeMode);
    await ref
        .read(preferencesProvider)
        .setString(_themeModeKey, themeMode.name);
  }

  Future<void> setLanguage(AppLanguage language) async {
    state = state.copyWith(language: language);
    await ref.read(preferencesProvider).setString(_languageKey, language.name);
  }

  /// Turns notifications on or off. Turning them on asks for permission and
  /// returns false when it was denied.
  Future<bool> setNotificationsEnabled({
    required bool enabled,
    required ReminderTexts texts,
  }) async {
    final reminders = ref.read(reminderServiceProvider);
    if (enabled && !await reminders.requestPermission()) {
      return false;
    }

    state = state.copyWith(notificationsEnabled: enabled);
    await ref.read(preferencesProvider).setBool(_notificationsKey, enabled);
    await _syncReminder(texts);
    return true;
  }

  /// Sets the daily reminder time, or turns the reminder off with null.
  /// Turning the reminder on also turns notifications on, so it returns false
  /// when notification permission was denied.
  Future<bool> setReminderTime(
    TimeOfDay? time, {
    required ReminderTexts texts,
  }) async {
    if (time != null && !state.notificationsEnabled) {
      final allowed = await setNotificationsEnabled(
        enabled: true,
        texts: texts,
      );
      if (!allowed) return false;
    }

    state = state.copyWith(reminderTime: () => time);
    final prefs = ref.read(preferencesProvider);
    if (time == null) {
      await prefs.remove(_reminderMinutesKey);
    } else {
      await prefs.setInt(_reminderMinutesKey, time.hour * 60 + time.minute);
    }
    await _syncReminder(texts);
    return true;
  }

  Future<void> _syncReminder(ReminderTexts texts) async {
    final reminders = ref.read(reminderServiceProvider);
    final time = state.reminderTime;
    if (state.notificationsEnabled && time != null) {
      await reminders.scheduleDaily(time, title: texts.title, body: texts.body);
    } else {
      await reminders.cancelDaily();
    }
  }
}
