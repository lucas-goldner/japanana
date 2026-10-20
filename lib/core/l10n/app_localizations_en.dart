// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get helloWorld => 'Hello World!';

  @override
  String get appTitle => 'Japanana';

  @override
  String get n2Grammar => 'N2 grammar';

  @override
  String get n3Grammar => 'N3 grammar';

  @override
  String get n4Grammar => 'N4 grammar';

  @override
  String get conversational => 'Conversation grammar';

  @override
  String get writing => 'Writing grammar';

  @override
  String get randomizeCards => 'Randomize cards';

  @override
  String get repeatFailedCards => 'Repeat failed cards';

  @override
  String get startReview => 'Start review';

  @override
  String get usages => 'Usages';

  @override
  String get examples => 'Examples';

  @override
  String get translations => 'Translations';

  @override
  String get extras => 'Extras';

  @override
  String congratsOnFinising(String review) {
    return 'Congrats you finished $review!';
  }

  @override
  String get startNextReview => 'Start next review';

  @override
  String get lectureList => 'Lecture list';

  @override
  String get next => 'Next';

  @override
  String get richtig => 'Correct';

  @override
  String get falsch => 'Wrong';

  @override
  String get remember => 'Remember';

  @override
  String get rememberedSection => 'Grammar to remember';

  @override
  String get forget => 'Forget';

  @override
  String letsTalkAbout(String title) {
    return 'Let\'s talk about $title';
  }

  @override
  String get whichKindOfUsage => 'Which kind of usage?';

  @override
  String get dontForgetAboutTheseCases => 'Don\'t forget about these cases:';

  @override
  String get tryToGuess => 'Try to guess';

  @override
  String get statistics => 'Statistics';

  @override
  String get noMistakesYet => 'No mistakes yet!';

  @override
  String get keepPracticing => 'Keep practicing to track your progress';

  @override
  String get mistakes => 'Mistakes:';

  @override
  String get lastMistake => 'Last mistake:';

  @override
  String get selectYourLecture => 'Select your Lecture';

  @override
  String get continueReview => 'CONTINUE';

  @override
  String completedLectures(int count) {
    return '$count completed';
  }

  @override
  String get recentMistakes => 'Recent Mistakes';

  @override
  String get writingShort => 'Writing';

  @override
  String get conversationalShort => 'Talk';

  @override
  String get n2Short => 'N2';

  @override
  String get n3Short => 'N3';

  @override
  String get n4Short => 'N4';

  @override
  String get rememberedShort => 'Saved';

  @override
  String get recentMistakesShort => 'Mistakes';

  @override
  String get settings => 'Settings';

  @override
  String get settingLanguage => 'Language';

  @override
  String get settingTheme => 'Theme';

  @override
  String get settingNotifications => 'Notifications';

  @override
  String get settingSubscription => 'Subscription';

  @override
  String get settingReminder => 'Daily Reminder';

  @override
  String get settingResetProgress => 'Reset Progress';

  @override
  String get settingExportSync => 'Export & Sync';

  @override
  String get settingSendFeedback => 'Send Feedback';

  @override
  String get settingDonation => 'Donation';

  @override
  String get settingFollowOnX => 'Follow on X';

  @override
  String get settingWebsite => 'Website';

  @override
  String get settingPrivacyPolicy => 'Privacy Policy';

  @override
  String get settingTermsOfUse => 'Terms of Use';

  @override
  String get settingRateTheApp => 'Rate the App';

  @override
  String get settingOtherApps => 'Other Apps';

  @override
  String get settingChangelog => 'See Changelog';

  @override
  String get languageSystem => 'Same as device';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get themeSystem => 'Same as device';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String get notificationsDescription =>
      'Get a nudge when it is time to review.';

  @override
  String get notificationsEnabled => 'Allow notifications';

  @override
  String get notificationsDenied =>
      'Notifications are turned off for Japanana. Turn them on in your device settings.';

  @override
  String get reminderDescription =>
      'Pick a time and Japanana reminds you every day.';

  @override
  String get reminderEnabled => 'Remind me every day';

  @override
  String get reminderTime => 'Reminder time';

  @override
  String get reminderNotificationTitle => 'Time for Japanese!';

  @override
  String get reminderNotificationBody =>
      'A few grammar cards are waiting for you.';

  @override
  String get resetDescription =>
      'Deletes your mistakes, saved lectures and unfinished reviews. This cannot be undone.';

  @override
  String get resetButton => 'Reset progress';

  @override
  String get resetConfirm => 'Yes, delete everything';

  @override
  String get resetDone => 'Your progress was reset.';

  @override
  String get exportDescription =>
      'Back up your mistakes, saved lectures and unfinished reviews, or move them to another device.';

  @override
  String get exportFile => 'Export backup file';

  @override
  String get importFile => 'Import backup file';

  @override
  String get iCloudBackup => 'Back up to iCloud';

  @override
  String get iCloudRestore => 'Restore from iCloud';

  @override
  String get backupSaved => 'Backup saved.';

  @override
  String get backupRestored => 'Backup restored.';

  @override
  String get backupFailed =>
      'That did not work. Check the file or your iCloud connection and try again.';

  @override
  String get subscriptionDescription =>
      'Become a Japanana Supporter to help keep the app growing. You get a supporter badge as a thank you.';

  @override
  String get subscriptionActive => 'You are a Japanana Supporter. Thank you!';

  @override
  String get subscriptionMonthly => 'Monthly';

  @override
  String get subscriptionYearly => 'Yearly';

  @override
  String get restorePurchases => 'Restore purchases';

  @override
  String get storeUnavailable =>
      'The store is not available right now. Try again later.';

  @override
  String get donationDescription =>
      'Enjoying Japanana? Leave a tip to support development.';

  @override
  String get donationThanks => 'Thank you so much for your support!';

  @override
  String get supporterBadge => 'Supporter';

  @override
  String get close => 'Close';

  @override
  String get feedbackSubject => 'Japanana feedback';

  @override
  String get feedbackBody => 'Hi! Here is my feedback:';

  @override
  String get linkFailed => 'Could not open the link.';

  @override
  String changelogVersion(String version) {
    return 'Version $version';
  }

  @override
  String get iCloudEmpty => 'There is no iCloud backup yet.';

  @override
  String get statsDayStreak => 'day streak';

  @override
  String statsLongestStreak(int days) {
    String _temp0 = intl.Intl.pluralLogic(
      days,
      locale: localeName,
      other: 'Longest: $days days',
      one: 'Longest: 1 day',
    );
    return '$_temp0';
  }

  @override
  String get statsCardsReviewed => 'Cards reviewed';

  @override
  String get statsFirstTryAccuracy => 'First-try accuracy';

  @override
  String get statsMinutesStudied => 'Minutes studied';

  @override
  String get statsLecturesMastered => 'Lectures mastered';

  @override
  String statsVsLastWeek(String change) {
    return '$change vs last week';
  }

  @override
  String get statsActivity => 'Activity';

  @override
  String get statsLess => 'Less';

  @override
  String get statsMore => 'More';

  @override
  String get statsCardsPerDay => 'Cards per day';

  @override
  String get statsLast7Days => '7 days';

  @override
  String get statsLast30Days => '30 days';

  @override
  String get statsCorrect => 'Correct';

  @override
  String get statsWrong => 'Wrong';

  @override
  String get statsMastery => 'Mastery by book';

  @override
  String get statsMastered => 'Mastered';

  @override
  String get statsLearning => 'Learning';

  @override
  String get statsUnseen => 'New';

  @override
  String get statsAccuracyByWeek => 'First-try accuracy by week';

  @override
  String get statsThisWeek => 'This week';

  @override
  String statsWeeksAgo(int count) {
    return '$count weeks ago';
  }

  @override
  String get statsWeakSpots => 'Weak spots';

  @override
  String get statsMostMissed => 'Most missed';

  @override
  String get statsMixedUp => 'Often mixed up';

  @override
  String statsTimes(int count) {
    return '$count×';
  }

  @override
  String statsWrongShare(String percent) {
    return '$percent wrong';
  }

  @override
  String get statsSeeAll => 'See all';

  @override
  String get statsReviewWeakSpots => 'Review weak spots';

  @override
  String get timeJustNow => 'Just now';

  @override
  String timeMinutesAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count minutes ago',
      one: '1 minute ago',
    );
    return '$_temp0';
  }

  @override
  String timeHoursAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hours ago',
      one: '1 hour ago',
    );
    return '$_temp0';
  }

  @override
  String timeDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days ago',
      one: '1 day ago',
    );
    return '$_temp0';
  }

  @override
  String get statsNotEnoughData => 'Not enough data yet. Keep reviewing!';
}
