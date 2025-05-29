// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get helloWorld => 'こんにちは!';

  @override
  String get appTitle => 'Japanana';

  @override
  String get n2Grammar => 'N2関してる文法';

  @override
  String get n3Grammar => 'N3関してる文法';

  @override
  String get n4Grammar => 'N4関してる文法';

  @override
  String get conversational => '会話には使っている文法';

  @override
  String get writing => '作文にいい文法';

  @override
  String get randomizeCards => 'カードをシャッフル';

  @override
  String get repeatFailedCards => '間違ったカードを繰り返す';

  @override
  String get startReview => '復習を始める';

  @override
  String get usages => '使い方';

  @override
  String get examples => '例';

  @override
  String get translations => '翻訳';

  @override
  String get extras => 'ボーナス';

  @override
  String congratsOnFinising(String review) {
    return 'おめでとうございます！ $reviewを済みました！';
  }

  @override
  String get startNextReview => '次の復習を始める';

  @override
  String get lectureList => 'リスト';

  @override
  String get next => '次';

  @override
  String get richtig => '正しい';

  @override
  String get falsch => '間違った';

  @override
  String get remember => '保存';

  @override
  String get rememberedSection => '保存した文法';

  @override
  String get forget => '忘れる';
}
