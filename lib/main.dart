import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/application/shared_preferences_provider.dart';
import 'package:japanana/core/data/shared_preferences_repository.dart';
import 'package:japanana/core/data/shared_preferences_repository_impl.dart';
import 'package:japanana/core/presentation/japanana_theme.dart';
import 'package:japanana/core/router.dart';
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
  Future<SharedPreferencesRepository>? _appLoader;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _appLoader ??= _loadApp(ref);
  }

  Future<SharedPreferencesRepository> _loadApp(WidgetRef ref) async {
    final preferencesRepo = SharedPreferencesRepositoryImpl(
      await SharedPreferences.getInstance(),
    );
    await ref
        .read(lectureProvider.notifier)
        .fetchLectures(sharedPreferencesRepository: preferencesRepo);

    return preferencesRepo;
  }

  @override
  Widget build(BuildContext context) =>
      FutureBuilder<SharedPreferencesRepository>(
        future: _appLoader,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (!WidgetsBinding.instance.firstFrameRasterized) {
              WidgetsBinding.instance.allowFirstFrame();
            }

            return ProviderScope(
              overrides: [
                sharedPreferencesProvider.overrideWithValue(
                  snapshot.requireData,
                ),
              ],
              child: MaterialApp.router(
                restorationScopeId: 'japanana',
                routerConfig: router,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                debugShowCheckedModeBanner: false,
                title: 'Japanana',
                theme: lightTheme,
                darkTheme: darkTheme,
              ),
            );
          }

          return const SizedBox.shrink();
        },
      );
}
