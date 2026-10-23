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
      'Become a Japanana Supporter to help keep the app growing. As a thank you, you get a supporter badge, every Nana app icon and the home screen widgets.';

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

  @override
  String get onbHookBubble => '…because the bus didn\'t come!';

  @override
  String get onbHookTitle => 'Textbooks teach you Japanese.';

  @override
  String get onbHookTitle2 => 'Japanana teaches you to *speak* it.';

  @override
  String get onbGetStarted => 'Get started';

  @override
  String get onbContinue => 'Continue';

  @override
  String get onbGoalTitle => 'Why are you learning Japanese?';

  @override
  String get onbGoalSubtitle => 'Pick the one that matters most.';

  @override
  String get onbGoalTalk => 'Talk with friends & family';

  @override
  String get onbGoalTravel => 'Travel without freezing up';

  @override
  String get onbGoalAnime => 'Anime & dramas without subtitles';

  @override
  String get onbGoalWork => 'Work or live in Japan';

  @override
  String get onbGoalJlpt => 'Pass the JLPT';

  @override
  String get onbLevelTitle => 'Where is your Japanese today?';

  @override
  String get onbLevelSubtitle => 'Swipe to your level. No pressure.';

  @override
  String get onbLevelN5 => 'Just starting';

  @override
  String get onbLevelN4 => 'Basics down, conversations shaky';

  @override
  String get onbLevelN3 => 'I read okay, speaking is hard';

  @override
  String get onbLevelN2 => 'Almost there';

  @override
  String get onbLevelN1 => 'Polishing the details';

  @override
  String get onbLevelConfirm => 'That\'s me';

  @override
  String get onbYearsTitle => 'How long have you been studying?';

  @override
  String get onbYearsLead => 'I\'ve been learning for';

  @override
  String onbYearsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'years',
      one: 'year',
      zero: 'less than a year',
    );
    return '$_temp0';
  }

  @override
  String get onbGapTitle => 'Someone speaks Japanese to you. You…';

  @override
  String get onbGapFreeze => 'Freeze';

  @override
  String get onbGapTranslate => 'Translate in my head';

  @override
  String get onbGapNatural => 'Answer naturally';

  @override
  String get onbGapFreezeLabel => 'I freeze and panic a little';

  @override
  String get onbGapTranslateLabel => 'I translate in my head first';

  @override
  String get onbGapNaturalLabel => 'I answer naturally';

  @override
  String get onbPainsTitle => 'Do these sound like you?';

  @override
  String get onbPainsSubtitle => 'Swipe right if it\'s you.';

  @override
  String get onbPainCantSpeak => 'I can read it, but I can\'t say it.';

  @override
  String get onbPainTextbook =>
      'Real Japanese sounds nothing like my textbook.';

  @override
  String get onbPainForget => 'I forget grammar a week after learning it.';

  @override
  String get onbPainMixUp => 'I mix up grammar that looks the same.';

  @override
  String get onbPainAgree => 'ME TOO';

  @override
  String get onbMathPointsLead => 'Japanese has';

  @override
  String get onbMathPointsTail => 'grammar points you\'ll actually hear.';

  @override
  String get onbMathAloneLead =>
      'Learning from textbooks alone, real conversations are';

  @override
  String get onbMathWithLead => 'With Japanana, 10 minutes a day:';

  @override
  String get onbMonthsAway => 'months away.';

  @override
  String get onbMonths => 'months.';

  @override
  String get onbMathNote =>
      'Estimate based on your level and 10 minutes a day.';

  @override
  String get onbMathCta => 'Show me how';

  @override
  String get onbFixTitle => 'Here\'s how we fix that';

  @override
  String get onbFixCantSpeak => 'Practise in real conversation-style chats';

  @override
  String get onbFixTextbook => 'Grammar the way people actually use it';

  @override
  String get onbFixForget => 'Weak spots come back before you forget';

  @override
  String get onbFixMixUp => 'Japanana spots your mixed-up pairs';

  @override
  String get onbCompareTitle => 'Speak sooner, not someday';

  @override
  String get onbCompareSubtitle =>
      'Time until you\'re comfortable in real conversations';

  @override
  String get onbCompareAlone => 'Textbook alone';

  @override
  String get onbCompareWith => 'With Japanana';

  @override
  String onbMonthsShort(int count) {
    return '$count mo';
  }

  @override
  String get onbProofTitle => 'Learners like you';

  @override
  String get onbProofSample => 'Sample reviews';

  @override
  String get onbReview1 =>
      'Finally I understand what my partner\'s family actually says at dinner.';

  @override
  String get onbReview1Tag => 'Talks with partner';

  @override
  String get onbReview2 =>
      'The mixed-up pairs thing is scary accurate. It knew my weak spots.';

  @override
  String get onbReview2Tag => 'Anime fan';

  @override
  String get onbReview3 =>
      'Ten minutes a day and my speaking finally caught up with my reading.';

  @override
  String get onbReview3Tag => 'JLPT N3';

  @override
  String get onbRhythmTitle => 'Small time, big progress';

  @override
  String get onbRhythmSubtitle =>
      'How much time can you give Japanese each day?';

  @override
  String get onbMinPerDay => 'MIN / DAY';

  @override
  String get onbRhythmCta => 'Set my daily rhythm';

  @override
  String get onbReminderTitle => 'Your Japanese, every evening';

  @override
  String get onbReminderSubtitle =>
      'A gentle nudge keeps you going. You can change the time anytime.';

  @override
  String onbReminderCta(String time) {
    return 'Remind me at $time';
  }

  @override
  String get onbNotNow => 'Not now';

  @override
  String get onbBuildingTitle => 'Building your path to natural Japanese';

  @override
  String onbBuildingStep1(String level) {
    return 'Matching grammar to your $level level';
  }

  @override
  String get onbBuildingStep2 => 'Finding the gaps textbooks skip';

  @override
  String onbBuildingStep3(int minutes) {
    return 'Planning $minutes minutes a day';
  }

  @override
  String get onbDemoTitle => 'Your first conversation';

  @override
  String get onbDemoGood => 'Nice! That\'s how natives use it 🎉';

  @override
  String get onbSnapshotTitle => 'A great first step';

  @override
  String get onbStampBottom => 'FIRST CONVERSATION';

  @override
  String get onbSnapshotFirstTry => 'First try';

  @override
  String get onbSnapshotRight => 'Right';

  @override
  String get onbSnapshotMissed => 'Almost';

  @override
  String get onbSnapshotLevel => 'Your level';

  @override
  String get onbSnapshotWatch => 'Watch out for';

  @override
  String get onbSnapshotNext => 'Next up';

  @override
  String get onbShareStamp => 'Share my stamp';

  @override
  String onbShareText(String title) {
    return 'I just had my first Japanese conversation on Japanana: $title 🍌';
  }

  @override
  String get onbSeePlan => 'See my plan';

  @override
  String get onbPlanTitle => 'Your plan is ready';

  @override
  String get onbPlanSubtitle => 'Natural conversations by';

  @override
  String onbPlanToday(String level) {
    return 'Today · $level';
  }

  @override
  String get onbPlanGoal => 'Natural conversations';

  @override
  String get onbPlanCta => 'Let\'s go';

  @override
  String get onbPaywallTitle => 'Speak Japanese with confidence';

  @override
  String get onbTrialToday => 'Today';

  @override
  String get onbTrialTodayText => 'Every lesson and your full plan unlocked';

  @override
  String get onbTrialDay5 => 'Day 5';

  @override
  String get onbTrialDay5Text => 'We\'ll remind you before your trial ends';

  @override
  String get onbTrialDay7 => 'Day 7';

  @override
  String get onbTrialDay7Text => 'Your trial ends. Cancel anytime before';

  @override
  String get onbBestValue => 'Best value';

  @override
  String get onbStartTrial => 'Start my free week';

  @override
  String get onbMaybeLater => 'Maybe later';

  @override
  String get reviewModeChoose => 'Pick one';

  @override
  String get reviewModeSwipe => 'Swipe it';

  @override
  String get reviewModeGap => 'Fill the gap';

  @override
  String get reviewModeMeaning => 'What does it mean?';

  @override
  String get reviewModePairs => 'Which one is it?';

  @override
  String get reviewModeMemory => 'Memory break';

  @override
  String get reviewModeLightning => 'Lightning round';

  @override
  String reviewSwipePrompt(String title) {
    return 'Does this usage fit $title?';
  }

  @override
  String get reviewSwipeFits => 'Fits';

  @override
  String get reviewSwipeNope => 'Nope';

  @override
  String get reviewSwipeHint => 'Swipe right if it fits, left if it doesn\'t';

  @override
  String reviewSwipeActual(String title, String usage) {
    return '$title is used for: $usage';
  }

  @override
  String get reviewGapPrompt => 'Which grammar completes the sentence?';

  @override
  String get reviewGapHint => 'Tap or drag a chip into the gap';

  @override
  String get reviewMeaningPrompt => 'What does this sentence mean?';

  @override
  String get reviewPairsBadge => 'You mix these up';

  @override
  String get reviewPairsPrompt => 'Which grammar would you use to say this?';

  @override
  String get reviewMemorySubtitle =>
      'Match each grammar point from your last cards to its usage.';

  @override
  String get reviewMemoryMoves => 'Moves';

  @override
  String get reviewMemoryTime => 'Time';

  @override
  String get reviewMemoryPairs => 'Pairs';

  @override
  String get reviewMemoryMismatch => 'Not a pair. Try again!';

  @override
  String reviewMemoryDone(int pairs, int moves) {
    return 'All $pairs pairs in $moves moves';
  }

  @override
  String get reviewPerfect => 'Perfect';

  @override
  String get reviewSkip => 'Skip';

  @override
  String get reviewContinue => 'Continue';

  @override
  String get reviewLightningSubtitle => '30 seconds. Swipe as many as you can.';

  @override
  String get reviewLightningStart => 'Start';

  @override
  String get reviewLightningScore => 'Score';

  @override
  String reviewLightningBest(int score) {
    return 'Best $score';
  }

  @override
  String reviewLightningResult(int right, int score) {
    return '$right right · score $score';
  }

  @override
  String get reviewLightningNewBest => 'New best!';

  @override
  String get reviewSummaryCards => 'Cards';

  @override
  String get reviewSummaryFirstTry => 'First try';

  @override
  String get reviewSummaryBestCombo => 'Best combo';

  @override
  String get reviewSummaryMistakes => 'Your mistakes';

  @override
  String get reviewSummaryMistakesHint => 'Tap one to jump back to it.';

  @override
  String get reviewSummaryNoMistakes => 'No mistakes. Perfect session!';

  @override
  String get reviewShareRecap => 'Share my recap';

  @override
  String get recapTitle => 'Session recap';

  @override
  String get recapHighlights => 'What I learned';

  @override
  String get recapTagline => 'Japanese beyond textbooks';

  @override
  String get recapShareVideo => 'Share video';

  @override
  String get recapShareImage => 'Share image';

  @override
  String recapRendering(int percent) {
    return 'Making your video… $percent%';
  }

  @override
  String recapShareText(int cards, int firstTry) {
    return 'My Japanese session on Japanana: $cards grammar cards, $firstTry% right on the first try 🍌';
  }

  @override
  String get recapFailed => 'Couldn\'t make the video. Try again.';

  @override
  String get settingAppIcon => 'App Icon';

  @override
  String get appIconDescription =>
      'Pick the Nana that suits you. Your home screen icon changes right away.';

  @override
  String get appIconSparkle => 'Sparkle';

  @override
  String get appIconFocusLines => 'Focus lines';

  @override
  String get appIconDon => 'ドン!';

  @override
  String get appIconTalk => 'ば!';

  @override
  String get appIconSticker => 'Wink';

  @override
  String get appIconSensei => 'Sensei';

  @override
  String get appIconFailed => 'Couldn\'t change the icon. Try again.';

  @override
  String get appIconSupporterPerk =>
      'The default Nana is free. The other icons come with the supporter subscription.';

  @override
  String get widgetDayStreak => 'day streak';

  @override
  String get widgetCardsToday => 'cards today';

  @override
  String get widgetStudyToday => 'Study today to keep it!';

  @override
  String get widgetGrammarOfDay => 'Grammar of the day';

  @override
  String get widgetThisWeek => 'This week';

  @override
  String get widgetSupporterPerk => 'Supporter perk';

  @override
  String get widgetOpenToUnlock =>
      'Become a supporter in Japanana to unlock widgets.';
}
