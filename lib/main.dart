import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikou/core/application/lecture_provider.dart';
import 'package:hikou/core/presentation/hikou_theme.dart';
import 'package:hikou/features/home/presentation/home.dart';

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
      ref.read(lectureNotifierProvider.notifier).fetchLectures();

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hikou',
        theme: theme,
        home: const Home(),
      );
}
