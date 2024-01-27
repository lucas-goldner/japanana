import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/features/in_review/presentation/widgets/lecture_card.dart';
import 'package:hikou/features/review_selection/domain/review_sections.dart';
import 'package:hikou/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  Future<void> _goToInReviewScreen(PatrolIntegrationTester $) async {
    await $.pumpWidgetAndSettle(
      ProviderScope(child: const HikouApp()),
    );
    expect($(K.reviewSelectionAppTitle).visible, equals(true));
    final n3GrammarOption =
        $(K.getReviewSelectionItemTitleForReviewOption(ReviewSections.n3));
    expect(n3GrammarOption.visible, equals(true));
    await n3GrammarOption.tap();
    final reviewSetup = $(K.reviewSetupAppTitle);
    expect(reviewSetup.visible, equals(true));
    final startReviewSetupButton = $(K.startReviewButton);
    await startReviewSetupButton.tap();
    expect($(K.getInReviewAppTitleForReviewOption(ReviewSections.n3)).visible,
        equals(true));
  }

  patrolTest(
    'Test in review page has all widgets',
    ($) async {
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect(
          $(K.getReviewLectureCardExpandedContent(1)).visible, equals(false));
    },
  );

  patrolTest(
    'Test in review page and expands lecture card content',
    ($) async {
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect(
          $(K.getReviewLectureCardExpandedContent(1)).visible, equals(false));
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
