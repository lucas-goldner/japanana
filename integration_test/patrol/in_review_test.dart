import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/data/lecture_repository_impl.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/in_review/presentation/widgets/lecture_card.dart';
import 'package:japanana/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  Future<void> _goToInReviewScreen(PatrolIntegrationTester $) async {
    await $.pumpWidgetAndSettle(
      ProviderScope(child: HikouApp($.tester.binding)),
    );
    expect($(K.reviewSelectionAppTitle).visible, equals(true));
    final n3GrammarOption =
        $(K.getReviewSelectionItemTitleForReviewOption(LectureType.n3));
    expect(n3GrammarOption.visible, equals(true));
    await n3GrammarOption.tap();
    final reviewSetup = $(K.reviewSetupAppTitle);
    expect(reviewSetup.visible, equals(true));
    final startReviewSetupButton = $(K.startReviewButton);
    await startReviewSetupButton.tap();
    expect($(K.getInReviewAppTitleForReviewOption(LectureType.n3)).visible,
        equals(true));
    return null;
  }

  Future<int> getItemsOfLectures() async =>
      (await LectureRepositoryImpl().fetchLectures())
          .where((lec) => lec.types.contains(LectureType.n3))
          .toList()
          .length;

  patrolTest(
    'Test in review page has all widgets',
    ($) async {
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect(
          $(K.getReviewLectureCardExpandedContent(1)).visible, equals(false));
      expect($(K.progressIndicator).visible, equals(true));
      expect($(K.progressIndicatorLabel).visible, equals(true));
    },
  );

  patrolTest(
    'Test in review page and expands lecture card content',
    ($) async {
      final itemsOfLectures = await getItemsOfLectures();
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect(
          $(K.getReviewLectureCardExpandedContent(1)).visible, equals(false));
      expect(
          $(K.progressIndicatorLabel).text, equals("1 / ${itemsOfLectures}"));
      await $.tap($(LectureCard));
      await $.scrollUntilVisible(
          finder: $(K.getReviewLectureCardExpandedContent(1)));
      expect($(K.getReviewLectureCardExpandedContent(1)).visible, equals(true));
      await $.tap($(LectureCard));
      await $.scrollUntilVisible(
          finder: $(K.getReviewLectureCardExpandedContent(2)));
      expect($(K.getReviewLectureCardExpandedContent(2)).visible, equals(true));
    },
  );
}
