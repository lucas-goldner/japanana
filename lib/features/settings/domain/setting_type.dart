import 'package:flutter/material.dart';

enum SettingType {
  language,
  theme,
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

  String get label => switch (this) {
        SettingType.language => 'Language',
        SettingType.theme => 'Theme',
        SettingType.notifications => 'Notifications',
        SettingType.subscription => 'Subscription',
        SettingType.reminder => 'Daily\nReminder',
        SettingType.resetProgress => 'Reset\nProgress',
        SettingType.exportSyncData => 'Export & Sync',
        SettingType.sendFeedback => 'Send\nFeedback',
        SettingType.donation => 'Donation',
        SettingType.followOnX => 'Follow on X',
        SettingType.website => 'Website',
        SettingType.privacyPolicy => 'Privacy\nPolicy',
        SettingType.termsOfUse => 'Terms of Use',
        SettingType.rateTheApp => 'Rate the App',
        SettingType.otherApps => 'Other\nApps',
        SettingType.seeChangelog => 'See\nChangelog',
      };

  IconData get icon => switch (this) {
        SettingType.language => Icons.translate,
        SettingType.theme => Icons.palette,
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

  VoidCallback getOnTap() => switch (this) {
        SettingType.language => () {
            // TODO(dev): Implement language selection
          },
        SettingType.theme => () {
            // TODO(dev): Implement theme selection
          },
        SettingType.notifications => () {
            // TODO(dev): Implement notification settings
          },
        SettingType.subscription => () {
            // TODO(dev): Implement subscription settings
          },
        SettingType.reminder => () {
            // TODO(dev): Implement daily reminder settings
          },
        SettingType.resetProgress => () {
            // TODO(dev): Implement reset progress
          },
        SettingType.exportSyncData => () {
            // TODO(dev): Implement export and sync data
          },
        SettingType.sendFeedback => () {
            // TODO(dev): Implement send feedback
          },
        SettingType.donation => () {
            // TODO(dev): Implement donation
          },
        SettingType.followOnX => () {
            // TODO(dev): Open X profile
          },
        SettingType.website => () {
            // TODO(dev): Open website
          },
        SettingType.privacyPolicy => () {
            // TODO(dev): Open privacy policy
          },
        SettingType.termsOfUse => () {
            // TODO(dev): Open terms of use
          },
        SettingType.rateTheApp => () {
            // TODO(dev): Open app store for rating
          },
        SettingType.otherApps => () {
            // TODO(dev): Open other apps
          },
        SettingType.seeChangelog => () {
            // TODO(dev): Show changelog
          },
      };
}
