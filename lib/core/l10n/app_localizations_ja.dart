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

  @override
  String letsTalkAbout(String title) {
    return '$titleについて話しましょう';
  }

  @override
  String get whichKindOfUsage => 'どの使い方？';

  @override
  String get dontForgetAboutTheseCases => 'この場合も忘れないで：';

  @override
  String get tryToGuess => '推測してみて';

  @override
  String get statistics => '統計';

  @override
  String get noMistakesYet => 'まだ間違いはありません！';

  @override
  String get keepPracticing => '練習を続けて進歩を追跡しましょう';

  @override
  String get mistakes => '間違い：';

  @override
  String get lastMistake => '最後の間違い：';

  @override
  String get selectYourLecture => '講義を選択してください';

  @override
  String get continueReview => '続行';

  @override
  String completedLectures(int count) {
    return '$count完了';
  }

  @override
  String get recentMistakes => '最近の間違い';

  @override
  String get writingShort => '作文';

  @override
  String get conversationalShort => '会話';

  @override
  String get n2Short => 'N2';

  @override
  String get n3Short => 'N3';

  @override
  String get n4Short => 'N4';

  @override
  String get rememberedShort => '保存';

  @override
  String get recentMistakesShort => '間違い';

  @override
  String get settings => '設定';

  @override
  String get settingLanguage => '言語';

  @override
  String get settingTheme => 'テーマ';

  @override
  String get settingNotifications => '通知';

  @override
  String get settingSubscription => 'サブスク';

  @override
  String get settingReminder => '毎日のリマインダー';

  @override
  String get settingResetProgress => '進捗をリセット';

  @override
  String get settingExportSync => 'エクスポートと同期';

  @override
  String get settingSendFeedback => 'フィードバック';

  @override
  String get settingDonation => '寄付';

  @override
  String get settingFollowOnX => 'Xでフォロー';

  @override
  String get settingWebsite => 'ウェブサイト';

  @override
  String get settingPrivacyPolicy => 'プライバシーポリシー';

  @override
  String get settingTermsOfUse => '利用規約';

  @override
  String get settingRateTheApp => 'アプリを評価';

  @override
  String get settingOtherApps => '他のアプリ';

  @override
  String get settingChangelog => '変更履歴';

  @override
  String get languageSystem => '端末の設定に合わせる';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageJapanese => '日本語';

  @override
  String get themeSystem => '端末の設定に合わせる';

  @override
  String get themeLight => 'ライト';

  @override
  String get themeDark => 'ダーク';

  @override
  String get notificationsDescription => '復習の時間になったらお知らせします。';

  @override
  String get notificationsEnabled => '通知を許可';

  @override
  String get notificationsDenied => 'Japananaの通知がオフになっています。端末の設定でオンにしてください。';

  @override
  String get reminderDescription => '時間を選ぶと、毎日リマインドします。';

  @override
  String get reminderEnabled => '毎日リマインドする';

  @override
  String get reminderTime => 'リマインダーの時間';

  @override
  String get reminderNotificationTitle => '日本語の時間です！';

  @override
  String get reminderNotificationBody => '文法カードがあなたを待っています。';

  @override
  String get resetDescription => '間違い、保存した講義、途中の復習をすべて削除します。元に戻すことはできません。';

  @override
  String get resetButton => '進捗をリセット';

  @override
  String get resetConfirm => 'はい、すべて削除します';

  @override
  String get resetDone => '進捗をリセットしました。';

  @override
  String get exportDescription => '間違い、保存した講義、途中の復習をバックアップしたり、別の端末に移したりできます。';

  @override
  String get exportFile => 'バックアップを書き出す';

  @override
  String get importFile => 'バックアップを読み込む';

  @override
  String get iCloudBackup => 'iCloudにバックアップ';

  @override
  String get iCloudRestore => 'iCloudから復元';

  @override
  String get backupSaved => 'バックアップを保存しました。';

  @override
  String get backupRestored => 'バックアップを復元しました。';

  @override
  String get backupFailed => 'うまくいきませんでした。ファイルまたはiCloudの接続を確認して、もう一度お試しください。';

  @override
  String get subscriptionDescription =>
      'Japananaサポーターになって、アプリの成長を応援してください。お礼にサポーターバッジが付きます。';

  @override
  String get subscriptionActive => 'Japananaサポーターです。ありがとうございます！';

  @override
  String get subscriptionMonthly => '月額';

  @override
  String get subscriptionYearly => '年額';

  @override
  String get restorePurchases => '購入を復元';

  @override
  String get storeUnavailable => '現在ストアを利用できません。しばらくしてからお試しください。';

  @override
  String get donationDescription => 'Japananaを楽しんでいますか？チップで開発を応援してください。';

  @override
  String get donationThanks => '応援ありがとうございます！';

  @override
  String get supporterBadge => 'サポーター';

  @override
  String get close => '閉じる';

  @override
  String get feedbackSubject => 'Japananaへのフィードバック';

  @override
  String get feedbackBody => 'こんにちは！フィードバックです：';

  @override
  String get linkFailed => 'リンクを開けませんでした。';

  @override
  String changelogVersion(String version) {
    return 'バージョン $version';
  }

  @override
  String get iCloudEmpty => 'iCloudにはまだバックアップがありません。';

  @override
  String get statsDayStreak => '日連続';

  @override
  String statsLongestStreak(int days) {
    return '最長：$days日';
  }

  @override
  String get statsCardsReviewed => '復習したカード';

  @override
  String get statsFirstTryAccuracy => '一発正解率';

  @override
  String get statsMinutesStudied => '学習時間（分）';

  @override
  String get statsLecturesMastered => '習得した講義';

  @override
  String statsVsLastWeek(String change) {
    return '先週比 $change';
  }

  @override
  String get statsActivity => 'アクティビティ';

  @override
  String get statsLess => '少';

  @override
  String get statsMore => '多';

  @override
  String get statsCardsPerDay => '1日のカード数';

  @override
  String get statsLast7Days => '7日';

  @override
  String get statsLast30Days => '30日';

  @override
  String get statsCorrect => '正解';

  @override
  String get statsWrong => '不正解';

  @override
  String get statsMastery => '本ごとの習得度';

  @override
  String get statsMastered => '習得';

  @override
  String get statsLearning => '学習中';

  @override
  String get statsUnseen => '未学習';

  @override
  String get statsAccuracyByWeek => '週ごとの一発正解率';

  @override
  String get statsThisWeek => '今週';

  @override
  String statsWeeksAgo(int count) {
    return '$count週間前';
  }

  @override
  String get statsWeakSpots => '苦手なところ';

  @override
  String get statsMostMissed => 'よく間違える文法';

  @override
  String get statsMixedUp => 'よく混同する組み合わせ';

  @override
  String statsTimes(int count) {
    return '$count回';
  }

  @override
  String statsWrongShare(String percent) {
    return '$percent不正解';
  }

  @override
  String get statsSeeAll => 'すべて見る';

  @override
  String get statsReviewWeakSpots => '苦手を復習する';

  @override
  String get timeJustNow => 'たった今';

  @override
  String timeMinutesAgo(int count) {
    return '$count分前';
  }

  @override
  String timeHoursAgo(int count) {
    return '$count時間前';
  }

  @override
  String timeDaysAgo(int count) {
    return '$count日前';
  }

  @override
  String get statsNotEnoughData => 'まだデータが足りません。復習を続けましょう！';
}
