import 'package:flutter/material.dart';
import 'package:japanana/core/extensions.dart';

enum SettingType {
  language,
  theme,
  appIcon,
  notifications,
  subscription,
  reminder,
  resetProgress,
  exportSyncData,
  sendFeedback,
  donation,
  followOnX,
  website,
  privacyPolicy,
  termsOfUse,
  rateTheApp,
  otherApps,
  seeChangelog;

  String label(BuildContext context) => switch (this) {
        SettingType.language => context.l10n.settingLanguage,
        SettingType.theme => context.l10n.settingTheme,
        SettingType.appIcon => context.l10n.settingAppIcon,
        SettingType.notifications => context.l10n.settingNotifications,
        SettingType.subscription => context.l10n.settingSubscription,
        SettingType.reminder => context.l10n.settingReminder,
        SettingType.resetProgress => context.l10n.settingResetProgress,
        SettingType.exportSyncData => context.l10n.settingExportSync,
        SettingType.sendFeedback => context.l10n.settingSendFeedback,
        SettingType.donation => context.l10n.settingDonation,
        SettingType.followOnX => context.l10n.settingFollowOnX,
        SettingType.website => context.l10n.settingWebsite,
        SettingType.privacyPolicy => context.l10n.settingPrivacyPolicy,
        SettingType.termsOfUse => context.l10n.settingTermsOfUse,
        SettingType.rateTheApp => context.l10n.settingRateTheApp,
        SettingType.otherApps => context.l10n.settingOtherApps,
        SettingType.seeChangelog => context.l10n.settingChangelog,
      };

  IconData get icon => switch (this) {
        SettingType.language => Icons.translate,
        SettingType.theme => Icons.palette,
        SettingType.appIcon => Icons.auto_awesome,
        SettingType.notifications => Icons.notifications_outlined,
        SettingType.subscription => Icons.workspace_premium,
        SettingType.reminder => Icons.alarm_outlined,
        SettingType.resetProgress => Icons.refresh,
        SettingType.exportSyncData => Icons.cloud_sync_outlined,
        SettingType.sendFeedback => Icons.feedback_outlined,
        SettingType.donation => Icons.favorite_outlined,
        SettingType.followOnX => Icons.close, // X icon
        SettingType.website => Icons.web_outlined,
        SettingType.privacyPolicy => Icons.privacy_tip_outlined,
        SettingType.termsOfUse => Icons.gavel_outlined,
        SettingType.rateTheApp => Icons.star_outline,
        SettingType.otherApps => Icons.apps_outlined,
        SettingType.seeChangelog => Icons.history_outlined,
      };

  /// Whether tapping the setting leaves the app (link, email or store)
  /// instead of opening a sheet.
  bool get isExternal => switch (this) {
        SettingType.sendFeedback ||
        SettingType.followOnX ||
        SettingType.website ||
        SettingType.privacyPolicy ||
        SettingType.termsOfUse ||
        SettingType.rateTheApp ||
        SettingType.otherApps =>
          true,
        _ => false,
      };
}
