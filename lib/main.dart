import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanana/core/application/lecture_provider.dart';
import 'package:japanana/core/presentation/hikou_theme.dart';
import 'package:japanana/core/router.dart';

void main() {
  final widgetsFlutterBinding = WidgetsFlutterBinding.ensureInitialized()
    ..deferFirstFrame();
  runApp(ProviderScope(child: JapananaApp(widgetsFlutterBinding)));
}

class JapananaApp extends ConsumerStatefulWidget {
  const JapananaApp(this.widgetsFlutterBinding, {super.key});
  final WidgetsBinding widgetsFlutterBinding;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _JapananaAppState();
}

class _JapananaAppState extends ConsumerState<JapananaApp> {
  Future<void>? _appLoader;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _appLoader ??= _loadApp(ref);
  }

  Future<void> _loadApp(WidgetRef ref) async =>
      ref.read(lectureProvider.notifier).fetchLectures();

  @override
  Widget build(BuildContext context) => FutureBuilder(
        future: _loadApp(ref),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            widget.widgetsFlutterBinding.allowFirstFrame();

            return MaterialApp.router(
              restorationScopeId: 'japanana',
              routerConfig: router,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              debugShowCheckedModeBanner: false,
              title: 'Japanana',
              theme: lightTheme,
              darkTheme: darkTheme,
            );
          }

          return const SizedBox.shrink();
        },
      );
}
