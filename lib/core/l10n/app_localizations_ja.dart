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
      'Japananaサポーターになってアプリの成長を応援してね。お礼にサポーターバッジ、すべてのNanaアプリアイコン、ホーム画面ウィジェットが使えます。';

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

  @override
  String get onbHookBubble => '（バスが来なかったから！）';

  @override
  String get onbHookTitle => '教科書は日本語を教えてくれる。';

  @override
  String get onbHookTitle2 => 'Japananaは日本語を*話せる*ようにしてくれる。';

  @override
  String get onbGetStarted => 'はじめる';

  @override
  String get onbContinue => '次へ';

  @override
  String get onbGoalTitle => '日本語を学ぶ理由は？';

  @override
  String get onbGoalSubtitle => '一番大事なものを選んでね。';

  @override
  String get onbGoalTalk => '友達や家族と話したい';

  @override
  String get onbGoalTravel => '旅行で固まらずに話したい';

  @override
  String get onbGoalAnime => 'アニメやドラマを字幕なしで';

  @override
  String get onbGoalWork => '日本で働く・暮らす';

  @override
  String get onbGoalJlpt => 'JLPTに合格したい';

  @override
  String get onbLevelTitle => '今の日本語のレベルは？';

  @override
  String get onbLevelSubtitle => 'スワイプして選んでね。気楽にどうぞ。';

  @override
  String get onbLevelN5 => '始めたばかり';

  @override
  String get onbLevelN4 => '基礎はOK、会話はまだ不安';

  @override
  String get onbLevelN3 => '読めるけど、話すのは難しい';

  @override
  String get onbLevelN2 => 'あと少し';

  @override
  String get onbLevelN1 => '細かいところを磨きたい';

  @override
  String get onbLevelConfirm => 'これが私';

  @override
  String get onbYearsTitle => 'どのくらい勉強してる？';

  @override
  String get onbYearsLead => '勉強歴';

  @override
  String onbYearsUnit(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '年',
      zero: '1年未満',
    );
    return '$_temp0';
  }

  @override
  String get onbGapTitle => '日本語で話しかけられたら…';

  @override
  String get onbGapFreeze => '固まる';

  @override
  String get onbGapTranslate => '頭の中で翻訳';

  @override
  String get onbGapNatural => '自然に答える';

  @override
  String get onbGapFreezeLabel => '固まって少し焦る';

  @override
  String get onbGapTranslateLabel => 'まず頭の中で翻訳する';

  @override
  String get onbGapNaturalLabel => '自然に答えられる';

  @override
  String get onbPainsTitle => 'これ、あなたのこと？';

  @override
  String get onbPainsSubtitle => '当てはまったら右にスワイプ。';

  @override
  String get onbPainCantSpeak => '読めるのに、話せない。';

  @override
  String get onbPainTextbook => '本物の日本語は教科書と全然違う。';

  @override
  String get onbPainForget => '覚えた文法を一週間で忘れる。';

  @override
  String get onbPainMixUp => '似た文法をよく混同する。';

  @override
  String get onbPainAgree => 'わかる！';

  @override
  String get onbMathPointsLead => '日本語には';

  @override
  String get onbMathPointsTail => '個の、実際に耳にする文法があります。';

  @override
  String get onbMathAloneLead => '教科書だけだと、自然な会話まで';

  @override
  String get onbMathWithLead => 'Japananaで1日10分なら：';

  @override
  String get onbMonthsAway => 'か月';

  @override
  String get onbMonths => 'か月';

  @override
  String get onbMathNote => 'レベルと1日10分をもとにした目安です。';

  @override
  String get onbMathCta => 'どうやって？';

  @override
  String get onbFixTitle => 'Japananaならこう解決';

  @override
  String get onbFixCantSpeak => '会話形式のチャットで練習';

  @override
  String get onbFixTextbook => '実際に使われる形で文法を学ぶ';

  @override
  String get onbFixForget => '忘れる前に苦手が戻ってくる';

  @override
  String get onbFixMixUp => '混同している組み合わせを見つける';

  @override
  String get onbCompareTitle => '「いつか」じゃなく「もうすぐ」話せる';

  @override
  String get onbCompareSubtitle => '自然な会話に慣れるまでの時間';

  @override
  String get onbCompareAlone => '教科書だけ';

  @override
  String get onbCompareWith => 'Japananaと一緒';

  @override
  String onbMonthsShort(int count) {
    return '$countか月';
  }

  @override
  String get onbProofTitle => 'あなたのような学習者';

  @override
  String get onbProofSample => 'サンプルレビュー';

  @override
  String get onbReview1 => 'パートナーの家族が夕食で話していることが、やっとわかるようになった。';

  @override
  String get onbReview1Tag => 'パートナーと会話';

  @override
  String get onbReview2 => '混同ペアの機能が怖いほど正確。苦手がバレてた。';

  @override
  String get onbReview2Tag => 'アニメ好き';

  @override
  String get onbReview3 => '1日10分で、やっと話す力が読む力に追いついた。';

  @override
  String get onbReview3Tag => 'JLPT N3';

  @override
  String get onbRhythmTitle => '短い時間で、大きな前進';

  @override
  String get onbRhythmSubtitle => '1日に何分、日本語に使える？';

  @override
  String get onbMinPerDay => '分 / 日';

  @override
  String get onbRhythmCta => '毎日のペースを決める';

  @override
  String get onbReminderTitle => '毎晩、あなたの日本語を';

  @override
  String get onbReminderSubtitle => 'やさしいリマインダーで続けやすく。時間はいつでも変えられます。';

  @override
  String onbReminderCta(String time) {
    return '$timeにリマインド';
  }

  @override
  String get onbNotNow => '今はしない';

  @override
  String get onbBuildingTitle => '自然な日本語への道をつくっています';

  @override
  String onbBuildingStep1(String level) {
    return '$levelレベルに合わせた文法を選択';
  }

  @override
  String get onbBuildingStep2 => '教科書が飛ばすところを探す';

  @override
  String onbBuildingStep3(int minutes) {
    return '1日$minutes分のプランを作成';
  }

  @override
  String get onbDemoTitle => 'はじめての会話';

  @override
  String get onbDemoGood => 'いいね！ネイティブもそう使います 🎉';

  @override
  String get onbSnapshotTitle => '最高の第一歩';

  @override
  String get onbStampBottom => 'はじめての会話';

  @override
  String get onbSnapshotFirstTry => '一発で';

  @override
  String get onbSnapshotRight => '正解';

  @override
  String get onbSnapshotMissed => 'もう少し';

  @override
  String get onbSnapshotLevel => 'あなたのレベル';

  @override
  String get onbSnapshotWatch => '気をつけたい文法';

  @override
  String get onbSnapshotNext => '次の文法';

  @override
  String get onbShareStamp => 'スタンプをシェア';

  @override
  String onbShareText(String title) {
    return 'Japananaではじめての日本語会話をしました：$title 🍌';
  }

  @override
  String get onbSeePlan => 'プランを見る';

  @override
  String get onbPlanTitle => 'プランができました';

  @override
  String get onbPlanSubtitle => '自然な会話ができるのは';

  @override
  String onbPlanToday(String level) {
    return '今日 · $level';
  }

  @override
  String get onbPlanGoal => '自然な会話';

  @override
  String get onbPlanCta => 'はじめよう';

  @override
  String get onbPaywallTitle => '自信をもって日本語を話そう';

  @override
  String get onbTrialToday => '今日';

  @override
  String get onbTrialTodayText => 'すべてのレッスンとプランが使い放題';

  @override
  String get onbTrialDay5 => '5日目';

  @override
  String get onbTrialDay5Text => '無料期間が終わる前にお知らせします';

  @override
  String get onbTrialDay7 => '7日目';

  @override
  String get onbTrialDay7Text => '無料期間終了。それまでならいつでも解約OK';

  @override
  String get onbBestValue => 'おすすめ';

  @override
  String get onbStartTrial => '1週間無料で始める';

  @override
  String get onbMaybeLater => 'あとで';

  @override
  String get reviewModeChoose => '選んで';

  @override
  String get reviewModeSwipe => 'スワイプ';

  @override
  String get reviewModeGap => '穴埋め';

  @override
  String get reviewModeMeaning => 'どういう意味？';

  @override
  String get reviewModePairs => 'どっち？';

  @override
  String get reviewModeMemory => '神経衰弱';

  @override
  String get reviewModeLightning => 'スピード勝負';

  @override
  String reviewSwipePrompt(String title) {
    return 'この使い方は$titleに合う？';
  }

  @override
  String get reviewSwipeFits => '合う';

  @override
  String get reviewSwipeNope => '違う';

  @override
  String get reviewSwipeHint => '合えば右、違えば左へスワイプ';

  @override
  String reviewSwipeActual(String title, String usage) {
    return '$titleの使い方：$usage';
  }

  @override
  String get reviewGapPrompt => 'どの文法が入る？';

  @override
  String get reviewGapHint => 'チップをタップするか、ドラッグして入れてね';

  @override
  String get reviewMeaningPrompt => 'この文はどういう意味？';

  @override
  String get reviewPairsBadge => 'よく混同する組み合わせ';

  @override
  String get reviewPairsPrompt => 'これを言うならどっちの文法？';

  @override
  String get reviewMemorySubtitle => '直近の文法と使い方をペアにしよう。';

  @override
  String get reviewMemoryMoves => '手数';

  @override
  String get reviewMemoryTime => '時間';

  @override
  String get reviewMemoryPairs => 'ペア';

  @override
  String get reviewMemoryMismatch => 'ペアじゃないよ。もう一回！';

  @override
  String reviewMemoryDone(int pairs, int moves) {
    return '$moves手で$pairsペア完成';
  }

  @override
  String get reviewPerfect => 'パーフェクト';

  @override
  String get reviewSkip => 'スキップ';

  @override
  String get reviewContinue => '次へ';

  @override
  String get reviewLightningSubtitle => '30秒でできるだけたくさん答えよう。';

  @override
  String get reviewLightningStart => 'スタート';

  @override
  String get reviewLightningScore => 'スコア';

  @override
  String reviewLightningBest(int score) {
    return 'ベスト $score';
  }

  @override
  String reviewLightningResult(int right, int score) {
    return '$right問正解・スコア $score';
  }

  @override
  String get reviewLightningNewBest => '自己ベスト更新！';

  @override
  String get reviewSummaryCards => 'カード';

  @override
  String get reviewSummaryFirstTry => '一発正解';

  @override
  String get reviewSummaryBestCombo => '最高コンボ';

  @override
  String get reviewSummaryMistakes => '間違えた文法';

  @override
  String get reviewSummaryMistakesHint => 'タップするとその問題に戻れます。';

  @override
  String get reviewSummaryNoMistakes => 'ミスなし。完璧！';

  @override
  String get reviewShareRecap => '振り返りをシェア';

  @override
  String get recapTitle => '今日の振り返り';

  @override
  String get recapHighlights => '学んだこと';

  @override
  String get recapTagline => '教科書の先の日本語へ';

  @override
  String get recapShareVideo => '動画をシェア';

  @override
  String get recapShareImage => '画像をシェア';

  @override
  String recapRendering(int percent) {
    return '動画を作成中… $percent%';
  }

  @override
  String recapShareText(int cards, int firstTry) {
    return 'Japananaで日本語を勉強：文法カード$cards枚、一発正解率$firstTry% 🍌';
  }

  @override
  String get recapFailed => '動画を作れませんでした。もう一度試してね。';

  @override
  String get settingAppIcon => 'アプリアイコン';

  @override
  String get appIconDescription => '好きなNanaを選んでね。ホーム画面のアイコンがすぐに変わります。';

  @override
  String get appIconSparkle => 'キラキラ';

  @override
  String get appIconFocusLines => '集中線';

  @override
  String get appIconDon => 'ドン!';

  @override
  String get appIconTalk => 'ば!';

  @override
  String get appIconSticker => 'ウインク';

  @override
  String get appIconSensei => '先生';

  @override
  String get appIconFailed => 'アイコンを変更できませんでした。もう一度試してね。';

  @override
  String get appIconSupporterPerk => 'デフォルトのNanaは無料。ほかのアイコンはサポーター特典です。';

  @override
  String get widgetDayStreak => '日連続';

  @override
  String get widgetCardsToday => '枚・今日';

  @override
  String get widgetStudyToday => '今日も勉強して記録をキープ！';

  @override
  String get widgetGrammarOfDay => '今日の文法';

  @override
  String get widgetThisWeek => '今週';

  @override
  String get widgetSupporterPerk => 'サポーター特典';

  @override
  String get widgetOpenToUnlock => 'Japananaでサポーターになるとウィジェットが使えます。';
}
