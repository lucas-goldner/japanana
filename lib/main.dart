import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hikou/core/data/lecture_repository.dart';
import 'package:hikou/core/domain/lecture.dart';
import 'package:hikou/core/presentation/hikou_theme.dart';
import 'package:hikou/features/home/presentation/home.dart';

void main() {
  runApp(const ProviderScope(child: HikouApp()));
}

class HikouApp extends StatefulWidget {
  const HikouApp({super.key});

  @override
  State<HikouApp> createState() => _HikouAppState();
}

class _HikouAppState extends State<HikouApp> {
  Future<void>? _appLoader;
  late final List<Lecture> _lectures;

  @override
  Future<void> didChangeDependencies() async {
    super.didChangeDependencies();
    _appLoader ??= _loadApp();
  }

  Future<void> _loadApp() async {
    _lectures = await LectureRepository().fetchLectures();
    print(_lectures);
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hikou',
        theme: theme,
        home: const Home(title: 'Hikou'),
      );
}
