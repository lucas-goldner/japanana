import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/preferences_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/core/l10n/app_localizations.dart';
import 'package:japanana/core/presentation/style/japanana_theme.dart';
import 'package:japanana/core/router.dart';
import 'package:japanana/features/settings/application/app_settings_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized().deferFirstFrame();
  runApp(const ProviderScope(child: JapananaApp()));
}

class JapananaApp extends ConsumerStatefulWidget {
  const JapananaApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JapananaAppState();
}

class _JapananaAppState extends ConsumerState<JapananaApp> {
  Future<SharedPreferences>? _appLoader;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLoader ??= _loadApp(ref);
  }

  Future<SharedPreferences> _loadApp(WidgetRef ref) =>
      SharedPreferences.getInstance();

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<SharedPreferences>(
        future: _appLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!WidgetsBinding.instance.firstFrameRasterized) {
              WidgetsBinding.instance.allowFirstFrame();
            }

            return ProviderScope(
              overrides: [
                preferencesProvider.overrideWithValue(snapshot.requireData),
                sharedPreferencesProvider.overrideWithValue(
                  SharedPreferencesRepositoryImpl(snapshot.requireData),
                ),
              ],
              child: Consumer(
                builder: (context, ref, _) {
                  final settings = ref.watch(appSettingsProvider);
                  return MaterialApp.router(
                    routerConfig: router,
                    localizationsDelegates:
                        AppLocalizations.localizationsDelegates,
                    supportedLocales: AppLocalizations.supportedLocales,
                    locale: settings.language.locale,
                    debugShowCheckedModeBanner: false,
                    title: 'Japanana',
                    theme: lightTheme,
                    darkTheme: darkTheme,
                    themeMode: settings.themeMode,
                  );
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
}
