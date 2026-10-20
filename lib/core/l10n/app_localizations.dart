import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// The conventional newborn programmer greeting
  ///
  /// In en, this message translates to:
  /// **'Hello World!'**
  String get helloWorld;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Japanana'**
  String get appTitle;

  /// No description provided for @n2Grammar.
  ///
  /// In en, this message translates to:
  /// **'N2 grammar'**
  String get n2Grammar;

  /// No description provided for @n3Grammar.
  ///
  /// In en, this message translates to:
  /// **'N3 grammar'**
  String get n3Grammar;

  /// No description provided for @n4Grammar.
  ///
  /// In en, this message translates to:
  /// **'N4 grammar'**
  String get n4Grammar;

  /// No description provided for @conversational.
  ///
  /// In en, this message translates to:
  /// **'Conversation grammar'**
  String get conversational;

  /// No description provided for @writing.
  ///
  /// In en, this message translates to:
  /// **'Writing grammar'**
  String get writing;

  /// No description provided for @randomizeCards.
  ///
  /// In en, this message translates to:
  /// **'Randomize cards'**
  String get randomizeCards;

  /// No description provided for @repeatFailedCards.
  ///
  /// In en, this message translates to:
  /// **'Repeat failed cards'**
  String get repeatFailedCards;

  /// No description provided for @startReview.
  ///
  /// In en, this message translates to:
  /// **'Start review'**
  String get startReview;

  /// No description provided for @usages.
  ///
  /// In en, this message translates to:
  /// **'Usages'**
  String get usages;

  /// No description provided for @examples.
  ///
  /// In en, this message translates to:
  /// **'Examples'**
  String get examples;

  /// No description provided for @translations.
  ///
  /// In en, this message translates to:
  /// **'Translations'**
  String get translations;

  /// No description provided for @extras.
  ///
  /// In en, this message translates to:
  /// **'Extras'**
  String get extras;

  /// Congratulation message for finishing review
  ///
  /// In en, this message translates to:
  /// **'Congrats you finished {review}!'**
  String congratsOnFinising(String review);

  /// No description provided for @startNextReview.
  ///
  /// In en, this message translates to:
  /// **'Start next review'**
  String get startNextReview;

  /// No description provided for @lectureList.
  ///
  /// In en, this message translates to:
  /// **'Lecture list'**
  String get lectureList;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @richtig.
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get richtig;

  /// No description provided for @falsch.
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get falsch;

  /// No description provided for @remember.
  ///
  /// In en, this message translates to:
  /// **'Remember'**
  String get remember;

  /// No description provided for @rememberedSection.
  ///
  /// In en, this message translates to:
  /// **'Grammar to remember'**
  String get rememberedSection;

  /// No description provided for @forget.
  ///
  /// In en, this message translates to:
  /// **'Forget'**
  String get forget;

  /// Introduction message for a grammar topic
  ///
  /// In en, this message translates to:
  /// **'Let\'s talk about {title}'**
  String letsTalkAbout(String title);

  /// Question asking about usage type
  ///
  /// In en, this message translates to:
  /// **'Which kind of usage?'**
  String get whichKindOfUsage;

  /// Message before showing extra cases
  ///
  /// In en, this message translates to:
  /// **'Don\'t forget about these cases:'**
  String get dontForgetAboutTheseCases;

  /// Button text to guess translation
  ///
  /// In en, this message translates to:
  /// **'Try to guess'**
  String get tryToGuess;

  /// Statistics page title
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// Message when no mistakes have been made
  ///
  /// In en, this message translates to:
  /// **'No mistakes yet!'**
  String get noMistakesYet;

  /// Encouragement message when no mistakes
  ///
  /// In en, this message translates to:
  /// **'Keep practicing to track your progress'**
  String get keepPracticing;

  /// Label for mistake count
  ///
  /// In en, this message translates to:
  /// **'Mistakes:'**
  String get mistakes;

  /// Label for last mistake date
  ///
  /// In en, this message translates to:
  /// **'Last mistake:'**
  String get lastMistake;

  /// Title for lecture selection page
  ///
  /// In en, this message translates to:
  /// **'Select your Lecture'**
  String get selectYourLecture;

  /// Button text to continue existing review
  ///
  /// In en, this message translates to:
  /// **'CONTINUE'**
  String get continueReview;

  /// Shows count of completed lectures
  ///
  /// In en, this message translates to:
  /// **'{count} completed'**
  String completedLectures(int count);

  /// Title for recent mistakes lecture type
  ///
  /// In en, this message translates to:
  /// **'Recent Mistakes'**
  String get recentMistakes;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'Writing'**
  String get writingShort;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'Talk'**
  String get conversationalShort;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'N2'**
  String get n2Short;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'N3'**
  String get n3Short;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'N4'**
  String get n4Short;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'Saved'**
  String get rememberedShort;

  /// Short lecture type title shown on a book spine
  ///
  /// In en, this message translates to:
  /// **'Mistakes'**
  String get recentMistakesShort;

  /// Title of the settings screen
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingLanguage;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingTheme;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settingNotifications;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get settingSubscription;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Daily Reminder'**
  String get settingReminder;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Reset Progress'**
  String get settingResetProgress;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Export & Sync'**
  String get settingExportSync;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Send Feedback'**
  String get settingSendFeedback;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get settingDonation;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Follow on X'**
  String get settingFollowOnX;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get settingWebsite;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get settingPrivacyPolicy;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Terms of Use'**
  String get settingTermsOfUse;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Rate the App'**
  String get settingRateTheApp;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'Other Apps'**
  String get settingOtherApps;

  /// Settings item
  ///
  /// In en, this message translates to:
  /// **'See Changelog'**
  String get settingChangelog;

  /// Language option that follows the device
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get languageSystem;

  /// Language option, always written in English
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// Language option, always written in Japanese
  ///
  /// In en, this message translates to:
  /// **'日本語'**
  String get languageJapanese;

  /// Theme option that follows the device
  ///
  /// In en, this message translates to:
  /// **'Same as device'**
  String get themeSystem;

  /// Theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// Theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// Explains the notifications setting
  ///
  /// In en, this message translates to:
  /// **'Get a nudge when it is time to review.'**
  String get notificationsDescription;

  /// Switch label
  ///
  /// In en, this message translates to:
  /// **'Allow notifications'**
  String get notificationsEnabled;

  /// Shown when notification permission was denied
  ///
  /// In en, this message translates to:
  /// **'Notifications are turned off for Japanana. Turn them on in your device settings.'**
  String get notificationsDenied;

  /// Explains the daily reminder setting
  ///
  /// In en, this message translates to:
  /// **'Pick a time and Japanana reminds you every day.'**
  String get reminderDescription;

  /// Switch label
  ///
  /// In en, this message translates to:
  /// **'Remind me every day'**
  String get reminderEnabled;

  /// Label of the reminder time button
  ///
  /// In en, this message translates to:
  /// **'Reminder time'**
  String get reminderTime;

  /// Title of the daily reminder notification
  ///
  /// In en, this message translates to:
  /// **'Time for Japanese!'**
  String get reminderNotificationTitle;

  /// Body of the daily reminder notification
  ///
  /// In en, this message translates to:
  /// **'A few grammar cards are waiting for you.'**
  String get reminderNotificationBody;

  /// Explains what resetting deletes
  ///
  /// In en, this message translates to:
  /// **'Deletes your mistakes, saved lectures and unfinished reviews. This cannot be undone.'**
  String get resetDescription;

  /// Button that starts the reset
  ///
  /// In en, this message translates to:
  /// **'Reset progress'**
  String get resetButton;

  /// Button that confirms the reset
  ///
  /// In en, this message translates to:
  /// **'Yes, delete everything'**
  String get resetConfirm;

  /// Shown after resetting
  ///
  /// In en, this message translates to:
  /// **'Your progress was reset.'**
  String get resetDone;

  /// Explains export and sync
  ///
  /// In en, this message translates to:
  /// **'Back up your mistakes, saved lectures and unfinished reviews, or move them to another device.'**
  String get exportDescription;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Export backup file'**
  String get exportFile;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Import backup file'**
  String get importFile;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Back up to iCloud'**
  String get iCloudBackup;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Restore from iCloud'**
  String get iCloudRestore;

  /// Shown after a backup succeeded
  ///
  /// In en, this message translates to:
  /// **'Backup saved.'**
  String get backupSaved;

  /// Shown after a restore succeeded
  ///
  /// In en, this message translates to:
  /// **'Backup restored.'**
  String get backupRestored;

  /// Shown when backup or restore failed
  ///
  /// In en, this message translates to:
  /// **'That did not work. Check the file or your iCloud connection and try again.'**
  String get backupFailed;

  /// Explains the supporter subscription
  ///
  /// In en, this message translates to:
  /// **'Become a Japanana Supporter to help keep the app growing. You get a supporter badge as a thank you.'**
  String get subscriptionDescription;

  /// Shown when the subscription is active
  ///
  /// In en, this message translates to:
  /// **'You are a Japanana Supporter. Thank you!'**
  String get subscriptionActive;

  /// Subscription period
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get subscriptionMonthly;

  /// Subscription period
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get subscriptionYearly;

  /// Button
  ///
  /// In en, this message translates to:
  /// **'Restore purchases'**
  String get restorePurchases;

  /// Shown when purchases cannot be loaded
  ///
  /// In en, this message translates to:
  /// **'The store is not available right now. Try again later.'**
  String get storeUnavailable;

  /// Explains the tip jar
  ///
  /// In en, this message translates to:
  /// **'Enjoying Japanana? Leave a tip to support development.'**
  String get donationDescription;

  /// Shown after a tip
  ///
  /// In en, this message translates to:
  /// **'Thank you so much for your support!'**
  String get donationThanks;

  /// Badge shown to supporters
  ///
  /// In en, this message translates to:
  /// **'Supporter'**
  String get supporterBadge;

  /// Button that closes a sheet
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Subject of the feedback email
  ///
  /// In en, this message translates to:
  /// **'Japanana feedback'**
  String get feedbackSubject;

  /// First line of the feedback email
  ///
  /// In en, this message translates to:
  /// **'Hi! Here is my feedback:'**
  String get feedbackBody;

  /// Shown when a link could not be opened
  ///
  /// In en, this message translates to:
  /// **'Could not open the link.'**
  String get linkFailed;

  /// Heading of a changelog entry
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String changelogVersion(String version);

  /// Shown when restoring from iCloud finds no backup
  ///
  /// In en, this message translates to:
  /// **'There is no iCloud backup yet.'**
  String get iCloudEmpty;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'day streak'**
  String get statsDayStreak;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'{days, plural, =1{Longest: 1 day} other{Longest: {days} days}}'**
  String statsLongestStreak(int days);

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Cards reviewed'**
  String get statsCardsReviewed;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'First-try accuracy'**
  String get statsFirstTryAccuracy;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Minutes studied'**
  String get statsMinutesStudied;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Lectures mastered'**
  String get statsLecturesMastered;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'{change} vs last week'**
  String statsVsLastWeek(String change);

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get statsActivity;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Less'**
  String get statsLess;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get statsMore;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Cards per day'**
  String get statsCardsPerDay;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'7 days'**
  String get statsLast7Days;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get statsLast30Days;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Correct'**
  String get statsCorrect;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Wrong'**
  String get statsWrong;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Mastery by book'**
  String get statsMastery;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Mastered'**
  String get statsMastered;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Learning'**
  String get statsLearning;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get statsUnseen;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'First-try accuracy by week'**
  String get statsAccuracyByWeek;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get statsThisWeek;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'{count} weeks ago'**
  String statsWeeksAgo(int count);

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Weak spots'**
  String get statsWeakSpots;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Most missed'**
  String get statsMostMissed;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Often mixed up'**
  String get statsMixedUp;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'{count}×'**
  String statsTimes(int count);

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'{percent} wrong'**
  String statsWrongShare(String percent);

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get statsSeeAll;

  /// Statistics screen
  ///
  /// In en, this message translates to:
  /// **'Review weak spots'**
  String get statsReviewWeakSpots;

  /// Relative time
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get timeJustNow;

  /// Relative time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 minute ago} other{{count} minutes ago}}'**
  String timeMinutesAgo(int count);

  /// Relative time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 hour ago} other{{count} hours ago}}'**
  String timeHoursAgo(int count);

  /// Relative time
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day ago} other{{count} days ago}}'**
  String timeDaysAgo(int count);

  /// Shown in a statistics chart that has no data yet
  ///
  /// In en, this message translates to:
  /// **'Not enough data yet. Keep reviewing!'**
  String get statsNotEnoughData;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
