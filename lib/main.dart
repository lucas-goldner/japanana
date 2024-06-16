import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/presentation/hikou_theme.dart';
import 'package:japanana/core/router.dart';

void main() => runApp(const ProviderScope(child: HikouApp()));

class HikouApp extends ConsumerStatefulWidget {
  const HikouApp({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HikouAppState();
}

class _HikouAppState extends ConsumerState<HikouApp> {
  Future<void>? _appLoader;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _appLoader ??= _loadApp(ref);
  }

  Future<void> _loadApp(WidgetRef ref) async =>
      ref.read(lectureProvider.notifier).fetchLectures();

  @override
  Widget build(BuildContext context) => MaterialApp.router(
        restorationScopeId: 'japanana',
        routerConfig: router,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        debugShowCheckedModeBanner: false,
        title: 'Hikou',
        theme: lightTheme,
        darkTheme: darkTheme,
      );
}
