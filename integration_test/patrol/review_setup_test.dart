import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hikou/main.dart';
import 'package:patrol/patrol.dart';

void main() {
  patrolTest(
    'Test review setup page',
    ($) async {
      await $.pumpWidgetAndSettle(ProviderScope(child: const HikouApp()));

      expect($(#counterText).text, '1');
      // await $(FloatingActionButton).tap();

      // expect($(#counterText).text, '1');
      // await $(FloatingActionButton).tap();
      // expect($(#counterText).text, '2');
    },
  );
}
