import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/clock_provider.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';
import 'package:japanana/features/settings/application/store_provider.dart';
import 'package:japanana/features/statistics/application/study_stats_provider.dart';
import 'package:japanana/features/widgets/data/widget_service.dart';
import 'package:japanana/features/widgets/domain/widget_snapshot.dart';

final widgetSnapshotProvider = Provider<WidgetSnapshot>(
  (ref) {
    final language = ref.watch(appSettingsProvider).language.locale ??
        PlatformDispatcher.instance.locale;
    return WidgetSnapshot.from(
      stats: ref.watch(studyStatsProvider),
      lectures: ref.watch(lectureProvider),
      isSupporter: ref.watch(storeProvider).value?.isSupporter ?? false,
      now: ref.watch(clockProvider)(),
      l10n: lookupAppLocalizations(
        Locale(language.languageCode == 'ja' ? 'ja' : 'en'),
      ),
    );
  },
  dependencies: [
    appSettingsProvider,
    studyStatsProvider,
    lectureProvider,
    storeProvider,
    clockProvider,
  ],
);

/// Keeps the widgets up to date while the app runs. Watched by the app root.
final widgetSyncProvider = Provider<void>(
  (ref) {
    if (!ref.watch(widgetServiceProvider).isSupported) return;
    ref.listen(
      widgetSnapshotProvider,
      (previous, next) {
        if (previous != next) ref.read(widgetServiceProvider).update(next);
      },
      fireImmediately: true,
    );
  },
  dependencies: [widgetSnapshotProvider, widgetServiceProvider],
);
