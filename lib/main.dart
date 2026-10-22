import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/onboarding/application/onboarding_provider.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';
import 'package:japanana/features/widgets/application/widget_sync_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Loaded before the first frame and provided at the root, so every
  // provider can read it synchronously.
  final preferences = await SharedPreferences.getInstance();
  runApp(
    ProviderScope(
      overrides: [
        preferencesProvider.overrideWithValue(preferences),
        sharedPreferencesProvider.overrideWithValue(
          SharedPreferencesRepositoryImpl(preferences),
        ),
      ],
      child: JapananaApp(
        router: createRouter(
          initialLocation: shouldShowOnboarding(preferences)
              ? AppRoutes.onboarding.path
              : null,
        ),
      ),
    ),
  );
}

class JapananaApp extends ConsumerWidget {
  const JapananaApp({required this.router, super.key});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    ref.watch(widgetSyncProvider);
    return MaterialApp.router(
      routerConfig: router,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: settings.language.locale,
      debugShowCheckedModeBanner: false,
      title: 'Japanana',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: settings.themeMode,
    );
  }
}
