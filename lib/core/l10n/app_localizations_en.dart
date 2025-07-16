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
}
