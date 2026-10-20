import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/random_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/lecture_repository.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/core/domain/lecture.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/features/settings/data/backup_storage.dart';
import 'package:japanana/features/settings/data/external_actions.dart';
import 'package:japanana/features/settings/data/purchases_service.dart';
import 'package:japanana/features/settings/data/reminder_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'golden_fakes.dart';
import 'golden_fixtures.dart';

/// Logical size of an iPhone 15 screen.
const kGoldenScreenSize = Size(393, 852);
const _kGoldenPixelRatio = 2.0;

/// Theme variants every screen golden is rendered in.
final goldenThemes = <String, ThemeData>{
  'light': lightTheme,
  'dark': darkTheme,
};

/// Loads the app fonts before any golden test runs.
void setUpGoldens() => setUpAll(loadAppFonts);

/// Loads every font declared in the FontManifest (app fonts and the
/// MaterialIcons font) so goldens show real glyphs instead of boxes.
Future<void> loadAppFonts() async {
  final manifest = await rootBundle.loadString('FontManifest.json');
  final fonts = json.decode(manifest) as List<dynamic>;
  for (final font in fonts.cast<Map<String, dynamic>>()) {
    final family = (font['family'] as String).replaceFirst('packages/', '');
    final loader = FontLoader(family);
    for (final asset in (font['fonts'] as List<dynamic>)
        .cast<Map<String, dynamic>>()) {
      loader.addFont(rootBundle.load(asset['asset'] as String));
    }
    await loader.load();
  }
}

class _FixtureLectureRepository implements LectureRepository {
  const _FixtureLectureRepository(this.lectures);
  final List<Lecture> lectures;

  @override
  Future<List<Lecture>> fetchLectures({
    String? assetsPath,
    List<String>? lecturesToRememberIds,
  }) async =>
      lectures;
}

class _FixtureLectureNotifier extends LectureNotifier {
  _FixtureLectureNotifier(this.lectures)
      : super(_FixtureLectureRepository(lectures));
  final List<Lecture> lectures;

  @override
  List<Lecture> build() => lectures;
}

/// Pumps [screen] in a phone sized surface with fixture data and the given
/// [theme].
///
/// [preferences] seeds SharedPreferences, e.g. with mistakes or sessions.
Future<void> pumpGoldenScreen(
  WidgetTester tester, {
  required Widget screen,
  required ThemeData theme,
  Map<String, Object> preferences = const {},
  List<Lecture>? lectures,
  PurchasesService? purchases,
  BackupStorage? backupStorage,
  ReminderService? reminders,
  Locale locale = const Locale('en'),
}) async {
  // Cached asset futures belong to the previous test's fake async zone and
  // never complete in this one.
  rootBundle.clear();
  SharedPreferences.setMockInitialValues(preferences);
  final prefs = await SharedPreferences.getInstance();

  tester.view
    ..physicalSize = kGoldenScreenSize * _kGoldenPixelRatio
    ..devicePixelRatio = _kGoldenPixelRatio
    ..padding = const FakeViewPadding(
      top: 59 * _kGoldenPixelRatio,
      bottom: 34 * _kGoldenPixelRatio,
    )
    ..viewPadding = const FakeViewPadding(
      top: 59 * _kGoldenPixelRatio,
      bottom: 34 * _kGoldenPixelRatio,
    );
  addTearDown(tester.view.reset);

  final fixtureLectures = lectures ?? goldenLectures;
  final rememberedIds = prefs.getStringList(
        'needToRememberLectures',
      ) ??
      [];

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(prefs),
        purchasesServiceProvider
            .overrideWithValue(purchases ?? FakePurchasesService()),
        backupStorageProvider
            .overrideWithValue(backupStorage ?? FakeBackupStorage()),
        reminderServiceProvider
            .overrideWithValue(reminders ?? FakeReminderService()),
        externalActionsProvider.overrideWithValue(FakeExternalActions()),
        sharedPreferencesProvider.overrideWithValue(
          SharedPreferencesRepositoryImpl(prefs),
        ),
        lectureProvider.overrideWith(
          () => _FixtureLectureNotifier(
            fixtureLectures
                .map(
                  (lecture) => rememberedIds.contains(lecture.id)
                      ? lecture.copyWith(
                          types: [...lecture.types, LectureType.remember],
                        )
                      : lecture,
                )
                .toList(),
          ),
        ),
        randomProvider.overrideWithValue(Random(42)),
        clockProvider.overrideWithValue(() => goldenNow),
      ],
      child: MaterialApp(
        theme: theme,
        debugShowCheckedModeBanner: false,
        locale: locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    ),
  );
}

/// Advances the clock in small steps so chained animations and delayed
/// futures complete. Screens with endless animations never settle, so
/// `pumpAndSettle` can't be used.
Future<void> pumpFor(WidgetTester tester, Duration duration) async {
  const step = Duration(milliseconds: 50);
  var elapsed = Duration.zero;
  while (elapsed < duration) {
    await tester.pump(step);
    elapsed += step;
  }
}

/// Compares the whole screen against `goldens/<screen>/<name>_<theme>.png`.
Future<void> expectScreenGolden(
  WidgetTester tester, {
  required String screen,
  required String name,
  required String themeName,
}) =>
    expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/$screen/${name}_$themeName.png'),
    );

/// Runs [body] once per entry of [goldenThemes].
///
/// Call [setUpGoldens] once in `main` before declaring golden tests.
void goldenTest(
  String description,
  Future<void> Function(WidgetTester tester, ThemeData theme, String themeName)
      body,
) {
  for (final MapEntry(key: themeName, value: theme) in goldenThemes.entries) {
    testWidgets(
      '$description ($themeName)',
      (tester) => body(tester, theme, themeName),
    );
  }
}
