import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hikou/core/hikou_theme.dart';
import 'package:hikou/features/home/presentation/home.dart';

void main() {
  runApp(const ProviderScope(child: HikouApp()));
}

class HikouApp extends StatelessWidget {
  const HikouApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Hikou',
        theme: theme,
        home: const Home(title: 'Hikou'),
      );
}
