import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/features/review_setup/domain/review_options.dart';
import 'package:hikou/features/review_setup/presentation/widgets/review_select_item.dart';
import 'package:hikou/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Test review setup page has all widgets',
    ($) async {
      await $.pumpWidgetAndSettle(
        ProviderScope(child: const HikouApp()),
      );
      expect($(#review_setup_app_title).visible, equals(true));
      expect($(ReviewSelectItem), findsNWidgets(ReviewOptions.values.length));
      expect($(Divider), findsNWidgets(ReviewOptions.values.length - 1));
    },
  );

  patrolTest(
    'Test tap review setup page redirects to selected review page',
    ($) async {
      await $.pumpWidgetAndSettle(
        ProviderScope(child: const HikouApp()),
      );
      expect($(#review_setup_app_title).visible, equals(true));
      final n3GrammarOption =
          $(Key("review_select_item_title_${ReviewOptions.n3.name}"));
      expect(n3GrammarOption.visible, equals(true));
      await n3GrammarOption.tap();
      final inReviewTitleKey =
          $(Key("in_review_app_title_${ReviewOptions.n3.name}"));
      expect(inReviewTitleKey.visible, equals(true));
      await $.tap($(BackButton));
      expect($(#review_setup_app_title).visible, equals(true));
    },
  );
}