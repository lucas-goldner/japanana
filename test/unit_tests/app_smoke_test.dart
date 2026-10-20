import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/features/review_selection/presentation/review_selection.dart';
import 'package:japanana/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app starts on the review selection screen', (tester) async {
    SharedPreferences.setMockInitialValues({'settings_theme_mode': 'dark'});
    final preferences = await SharedPreferences.getInstance();

    // Same provider setup as main().
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          preferencesProvider.overrideWithValue(preferences),
          sharedPreferencesProvider.overrideWithValue(
            SharedPreferencesRepositoryImpl(preferences),
          ),
        ],
        child: const JapananaApp(),
      ),
    );
    // Let the intro animations and their delayed callbacks finish.
    for (var i = 0; i < 140; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(tester.takeException(), isNull);
    expect(find.byType(ReviewSelection), findsOneWidget);
  });
}
