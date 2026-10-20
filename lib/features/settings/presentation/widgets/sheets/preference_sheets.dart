import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:japanana/core/extensions.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/presentation/widgets/neo_button.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';
import 'package:japanana/features/settings/presentation/widgets/sheet_parts.dart';

/// Reminder time preselected when the daily reminder is first turned on.
const _kDefaultReminderTime = TimeOfDay(hour: 20, minute: 0);

ReminderTexts _reminderTexts(BuildContext context) => (
      title: context.l10n.reminderNotificationTitle,
      body: context.l10n.reminderNotificationBody,
    );

class LanguageSheet extends ConsumerWidget {
  const LanguageSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider).language;
    final l10n = context.l10n;

    return SheetColumn(
      children: [
        for (final language in AppLanguage.values)
          ChoiceTile(
            label: switch (language) {
              AppLanguage.system => l10n.languageSystem,
              AppLanguage.english => l10n.languageEnglish,
              AppLanguage.japanese => l10n.languageJapanese,
            },
            leading: language == AppLanguage.system ? Icons.smartphone : null,
            selected: language == selected,
            onTap: () =>
                ref.read(appSettingsProvider.notifier).setLanguage(language),
          ),
      ],
    );
  }
}

class ThemeSheet extends ConsumerWidget {
  const ThemeSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(appSettingsProvider).themeMode;
    final l10n = context.l10n;

    return SheetColumn(
      children: [
        for (final mode in ThemeMode.values)
          ChoiceTile(
            label: switch (mode) {
              ThemeMode.system => l10n.themeSystem,
              ThemeMode.light => l10n.themeLight,
              ThemeMode.dark => l10n.themeDark,
            },
            leading: switch (mode) {
              ThemeMode.system => Icons.smartphone,
              ThemeMode.light => Icons.light_mode,
              ThemeMode.dark => Icons.dark_mode,
            },
            selected: mode == selected,
            onTap: () =>
                ref.read(appSettingsProvider.notifier).setThemeMode(mode),
          ),
      ],
    );
  }
}

class NotificationsSheet extends HookConsumerWidget {
  const NotificationsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(appSettingsProvider).notificationsEnabled;
    final denied = useState(false);

    Future<void> toggle({required bool value}) async {
      final allowed = await ref
          .read(appSettingsProvider.notifier)
          .setNotificationsEnabled(
            enabled: value,
            texts: _reminderTexts(context),
          );
      denied.value = !allowed;
    }

    return SheetColumn(
      children: [
        SheetDescription(context.l10n.notificationsDescription),
        SwitchTile(
          label: context.l10n.notificationsEnabled,
          value: enabled,
          onChanged: (value) => toggle(value: value),
        ),
        if (denied.value)
          SheetMessage(
            context.l10n.notificationsDenied,
            tone: SheetMessageTone.error,
          ),
      ],
    );
  }
}

class ReminderSheet extends HookConsumerWidget {
  const ReminderSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final time = settings.notificationsEnabled ? settings.reminderTime : null;
    final denied = useState(false);

    Future<void> setTime(TimeOfDay? value) async {
      final allowed = await ref
          .read(appSettingsProvider.notifier)
          .setReminderTime(value, texts: _reminderTexts(context));
      denied.value = !allowed;
    }

    Future<void> pickTime() async {
      final picked = await showTimePicker(
        context: context,
        initialTime: time ?? _kDefaultReminderTime,
      );
      if (picked != null && context.mounted) await setTime(picked);
    }

    return SheetColumn(
      children: [
        SheetDescription(context.l10n.reminderDescription),
        SwitchTile(
          label: context.l10n.reminderEnabled,
          value: time != null,
          onChanged: (on) => setTime(on ? _kDefaultReminderTime : null),
        ),
        if (time != null)
          NeoButton(
            onPressed: pickTime,
            minHeight: 56,
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    context.l10n.reminderTime,
                    style: TextStyle(
                      fontFamily: context.textTheme.notoSansJPFont,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  MaterialLocalizations.of(context).formatTimeOfDay(time),
                  style: TextStyle(
                    fontFamily: context.textTheme.notoSansJPFont,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.edit, color: context.neo.onCard, size: 20),
              ],
            ),
          ),
        if (denied.value)
          SheetMessage(
            context.l10n.notificationsDenied,
            tone: SheetMessageTone.error,
          ),
      ],
    );
  }
}
