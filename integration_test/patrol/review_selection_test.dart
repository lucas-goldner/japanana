import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/keys.dart';
import 'package:japanana/features/review_selection/domain/review_sections.dart';
import 'package:japanana/features/review_selection/presentation/widgets/review_selection_item.dart';
import 'package:japanana/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Test review selection page has all widgets',
    ($) async {
      await $.pumpWidgetAndSettle(
        ProviderScope(child: const HikouApp()),
      );
      expect($(K.reviewSelectionAppTitle).visible, equals(true));
      expect(
          $(ReviewSelectionItem), findsNWidgets(ReviewSections.values.length));
      expect($(Divider), findsNWidgets(ReviewSections.values.length - 1));
    },
  );

  patrolTest(
    'Test tap review selection page redirects to review setup page',
    ($) async {
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
      await $.tap($(BackButton));
      expect($(K.reviewSelectionAppTitle).visible, equals(true));
      expect(reviewSetup.visible, equals(false));
    },
  );

  patrolTest(
    'Test tap review selection page, setup and start review',
    ($) async {
      await $.pumpWidgetAndSettle(
        ProviderScope(child: const HikouApp()),
      );
      final selectionAppTitle = $(K.reviewSelectionAppTitle);
      expect(selectionAppTitle.visible, equals(true));
      final n3GrammarOption =
          $(K.getReviewSelectionItemTitleForReviewOption(ReviewSections.n3));
      expect(n3GrammarOption.visible, equals(true));
      await n3GrammarOption.tap();
      final reviewSetup = $(K.reviewSetupAppTitle);
      expect(reviewSetup.visible, equals(true));
      final startReviewSetupButton = $(K.startReviewButton);
      await startReviewSetupButton.tap();
      final inReviewTitleKey =
          $(K.getInReviewAppTitleForReviewOption(ReviewSections.n3));
      expect(inReviewTitleKey.visible, equals(true));
      await $.tap($(BackButton));
      expect(reviewSetup.visible, equals(true));
      await $.tap($(BackButton));
      expect(selectionAppTitle.visible, equals(true));
    },
  );
}
