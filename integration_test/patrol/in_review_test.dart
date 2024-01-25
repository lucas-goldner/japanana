import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/core/keys.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';
import 'package:hikou/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  Future<void> _goToInReviewScreen(PatrolIntegrationTester $) async {
    await $.pumpWidgetAndSettle(
      ProviderScope(child: const HikouApp()),
    );
    expect($(K.reviewSetupAppTitle).visible, equals(true));
    final n3GrammarOption =
        $(K.getReviewSelectItemTitleForReviewOption(ReviewOptions.n3));
    expect(n3GrammarOption.visible, equals(true));
    await n3GrammarOption.tap();
    expect($(K.getInReviewAppTitleForReviewOption(ReviewOptions.n3)).visible,
        equals(true));
  }

  patrolTest(
    'Test in review page has all widgets',
    ($) async {
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect($(K.lectureCardExpandedContent).visible, equals(false));
    },
  );

  patrolTest(
    'Test in review page and expands lecture card content',
    ($) async {
      await _goToInReviewScreen($);
      expect($(K.inReviewCardStack).visible, equals(true));
      expect($(K.lectureCard).visible, equals(true));
      expect($(K.lectureCardTitle).visible, equals(true));
      expect($(K.lectureCardExpandedContent).visible, equals(false));
      await $(K.lectureCardTitle).tap();
      expect($(K.lectureCardExpandedContent).visible, equals(true));
    },
  );
}
