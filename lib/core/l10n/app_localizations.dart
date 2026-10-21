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

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'…because the bus didn\'t come!'**
  String get onbHookBubble;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Textbooks teach you Japanese.'**
  String get onbHookTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Japanana teaches you to *speak* it.'**
  String get onbHookTitle2;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Get started'**
  String get onbGetStarted;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get onbContinue;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Why are you learning Japanese?'**
  String get onbGoalTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Pick the one that matters most.'**
  String get onbGoalSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Talk with friends & family'**
  String get onbGoalTalk;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Travel without freezing up'**
  String get onbGoalTravel;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Anime & dramas without subtitles'**
  String get onbGoalAnime;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Work or live in Japan'**
  String get onbGoalWork;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Pass the JLPT'**
  String get onbGoalJlpt;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Where is your Japanese today?'**
  String get onbLevelTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Swipe to your level. No pressure.'**
  String get onbLevelSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Just starting'**
  String get onbLevelN5;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Basics down, conversations shaky'**
  String get onbLevelN4;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I read okay, speaking is hard'**
  String get onbLevelN3;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Almost there'**
  String get onbLevelN2;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Polishing the details'**
  String get onbLevelN1;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'That\'s me'**
  String get onbLevelConfirm;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'How long have you been studying?'**
  String get onbYearsTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I\'ve been learning for'**
  String get onbYearsLead;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{less than a year} =1{year} other{years}}'**
  String onbYearsUnit(int count);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Someone speaks Japanese to you. You…'**
  String get onbGapTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Freeze'**
  String get onbGapFreeze;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Translate in my head'**
  String get onbGapTranslate;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Answer naturally'**
  String get onbGapNatural;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I freeze and panic a little'**
  String get onbGapFreezeLabel;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I translate in my head first'**
  String get onbGapTranslateLabel;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I answer naturally'**
  String get onbGapNaturalLabel;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Do these sound like you?'**
  String get onbPainsTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Swipe right if it\'s you.'**
  String get onbPainsSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I can read it, but I can\'t say it.'**
  String get onbPainCantSpeak;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Real Japanese sounds nothing like my textbook.'**
  String get onbPainTextbook;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I forget grammar a week after learning it.'**
  String get onbPainForget;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I mix up grammar that looks the same.'**
  String get onbPainMixUp;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'ME TOO'**
  String get onbPainAgree;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Japanese has'**
  String get onbMathPointsLead;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'grammar points you\'ll actually hear.'**
  String get onbMathPointsTail;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Learning from textbooks alone, real conversations are'**
  String get onbMathAloneLead;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'With Japanana, 10 minutes a day:'**
  String get onbMathWithLead;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'months away.'**
  String get onbMonthsAway;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'months.'**
  String get onbMonths;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Estimate based on your level and 10 minutes a day.'**
  String get onbMathNote;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Show me how'**
  String get onbMathCta;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Here\'s how we fix that'**
  String get onbFixTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Practise in real conversation-style chats'**
  String get onbFixCantSpeak;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Grammar the way people actually use it'**
  String get onbFixTextbook;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Weak spots come back before you forget'**
  String get onbFixForget;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Japanana spots your mixed-up pairs'**
  String get onbFixMixUp;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Speak sooner, not someday'**
  String get onbCompareTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Time until you\'re comfortable in real conversations'**
  String get onbCompareSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Textbook alone'**
  String get onbCompareAlone;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'With Japanana'**
  String get onbCompareWith;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'{count} mo'**
  String onbMonthsShort(int count);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Learners like you'**
  String get onbProofTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Sample reviews'**
  String get onbProofSample;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Finally I understand what my partner\'s family actually says at dinner.'**
  String get onbReview1;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Talks with partner'**
  String get onbReview1Tag;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'The mixed-up pairs thing is scary accurate. It knew my weak spots.'**
  String get onbReview2;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Anime fan'**
  String get onbReview2Tag;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Ten minutes a day and my speaking finally caught up with my reading.'**
  String get onbReview3;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'JLPT N3'**
  String get onbReview3Tag;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Small time, big progress'**
  String get onbRhythmTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'How much time can you give Japanese each day?'**
  String get onbRhythmSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'MIN / DAY'**
  String get onbMinPerDay;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Set my daily rhythm'**
  String get onbRhythmCta;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Your Japanese, every evening'**
  String get onbReminderTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'A gentle nudge keeps you going. You can change the time anytime.'**
  String get onbReminderSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Remind me at {time}'**
  String onbReminderCta(String time);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get onbNotNow;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Building your path to natural Japanese'**
  String get onbBuildingTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Matching grammar to your {level} level'**
  String onbBuildingStep1(String level);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Finding the gaps textbooks skip'**
  String get onbBuildingStep2;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Planning {minutes} minutes a day'**
  String onbBuildingStep3(int minutes);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Your first conversation'**
  String get onbDemoTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Nice! That\'s how natives use it 🎉'**
  String get onbDemoGood;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'A great first step'**
  String get onbSnapshotTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'FIRST CONVERSATION'**
  String get onbStampBottom;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'First try'**
  String get onbSnapshotFirstTry;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Right'**
  String get onbSnapshotRight;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Almost'**
  String get onbSnapshotMissed;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Your level'**
  String get onbSnapshotLevel;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Watch out for'**
  String get onbSnapshotWatch;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Next up'**
  String get onbSnapshotNext;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Share my stamp'**
  String get onbShareStamp;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'I just had my first Japanese conversation on Japanana: {title} 🍌'**
  String onbShareText(String title);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'See my plan'**
  String get onbSeePlan;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Your plan is ready'**
  String get onbPlanTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Natural conversations by'**
  String get onbPlanSubtitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Today · {level}'**
  String onbPlanToday(String level);

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Natural conversations'**
  String get onbPlanGoal;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Let\'s go'**
  String get onbPlanCta;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Speak Japanese with confidence'**
  String get onbPaywallTitle;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get onbTrialToday;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Every lesson and your full plan unlocked'**
  String get onbTrialTodayText;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Day 5'**
  String get onbTrialDay5;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'We\'ll remind you before your trial ends'**
  String get onbTrialDay5Text;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Day 7'**
  String get onbTrialDay7;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Your trial ends. Cancel anytime before'**
  String get onbTrialDay7Text;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Best value'**
  String get onbBestValue;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Start my free week'**
  String get onbStartTrial;

  /// Onboarding
  ///
  /// In en, this message translates to:
  /// **'Maybe later'**
  String get onbMaybeLater;
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
